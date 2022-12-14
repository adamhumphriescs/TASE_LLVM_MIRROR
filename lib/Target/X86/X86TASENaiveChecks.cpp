// Add TASE naive poison checking before each instruction that loads or stores.
// Does not use transactional hardware (TSX) at all.


#include "X86.h"
#include "X86InstrBuilder.h"
#include "X86InstrInfo.h"
#include "X86Subtarget.h"
#include "X86TASE.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/MC/MCCartridgeRecord.h"
#include "llvm/IR/DebugLoc.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include <algorithm>
#include <cassert>
#include <iostream>

using namespace llvm;

#define PASS_KEY "x86-tase-naive-checking"
#define PASS_DESC "X86 TASE naive poison checking."
#define DEBUG_TYPE PASS_KEY

extern bool TASESharedMode;
extern bool TASEParanoidControlFlow;
extern bool TASEStackGuard;
extern bool TASEUseAlignment;
// STATISTIC(NumCondBranchesTraced, "Number of conditional branches traced");

namespace llvm {
  void initializeX86TASENaiveChecksPassPass(PassRegistry &);
}

namespace {

class X86TASENaiveChecksPass : public MachineFunctionPass {
public:
  X86TASENaiveChecksPass() : MachineFunctionPass(ID),
    CurrentMI(nullptr),
    NextMII(nullptr)
  {
    initializeX86TASENaiveChecksPassPass(
        *PassRegistry::getPassRegistry());
  }

  StringRef getPassName() const override {
    return PASS_DESC;
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  MachineFunctionProperties getRequiredProperties() const override {
    return MachineFunctionProperties().set(
        MachineFunctionProperties::Property::NoVRegs);
  }

  /// Pass identification, replacement for typeid.
  static char ID;

private:
  const X86Subtarget *Subtarget;
//   MachineRegisterInfo *MRI;
  const X86InstrInfo *TII;
  const TargetRegisterInfo *TRI;
  MachineInstr *CurrentMI;
  MachineBasicBlock::instr_iterator NextMII;

  TASEAnalysis Analysis;
  void InstrumentInstruction(MachineInstr &MI);
  MachineInstrBuilder InsertInstr(unsigned int opcode, unsigned int destReg, bool before = true);
  MachineInstrBuilder InsertInstr(unsigned int opcode, bool before = true);
  bool isSafeToClobberEFLAGS(MachineBasicBlock &MBB, MachineBasicBlock::iterator I) const;
  bool isRaxLive(MachineBasicBlock &MBB, MachineBasicBlock::const_iterator I) const;
  void PoisonCheckReg(size_t size, unsigned int align = 0);
  void PoisonCheckStack(int64_t stackOffset);
  void PoisonCheckMem(size_t size);
  void PoisonCheckPushPop(bool push);
  void PoisonCheckRegInternal(size_t size, unsigned int reg, unsigned int acc_idx);
  void EmitSpringboard(MachineInstr *FirstMI, const char *label);
  void RotateAccumulator(size_t size, unsigned int acc_idx);
  unsigned int AllocateOffset(size_t size);
  unsigned int getAddrReg(unsigned Op);
};

} // end anonymous namespace


char X86TASENaiveChecksPass::ID = 0;


bool X86TASENaiveChecksPass::isSafeToClobberEFLAGS( MachineBasicBlock &MBB, MachineBasicBlock::iterator I ) const {
  return MBB.computeRegisterLiveness(&TII->getRegisterInfo(), X86::EFLAGS, I, 40) ==
           MachineBasicBlock::LQR_Dead;
}


bool X86TASENaiveChecksPass::isRaxLive( MachineBasicBlock &MBB, MachineBasicBlock::const_iterator Before ) const {
  auto TRI = &TII->getRegisterInfo();
  unsigned Reg = X86::RAX;
  unsigned N = 40;

  // Try searching forwards from Before, looking for reads or defs.
  MachineBasicBlock::const_iterator I(Before);
  for (; I != MBB.end() && N > 0; ++I) {
    if (I->isDebugInstr())
      continue;

    --N;

    MachineOperandIteratorBase::PhysRegInfo Info =
        ConstMIOperands(*I).analyzePhysReg(Reg, TRI);

    // Register is live when we read it here.
    if (Info.Read)
      return true;
    // Register is dead if we can fully overwrite or clobber it here.
    //    if (Info.FullyDefined || Info.Clobbered)
    if (Info.Defined || Info.Clobbered)
      return false;
  }

  // If we reached the end, it is safe to clobber Reg at the end of a block of
  // no successor has it live in.
  if (I == MBB.end()) {
    for (MachineBasicBlock *S : MBB.successors()) {
      for (const MachineBasicBlock::RegisterMaskPair &LI : S->liveins()) {
        if (TRI->regsOverlap(LI.PhysReg, Reg))
          return true;
      }
    }

    return false;
  }


  N = 40;

  // Start by searching backwards from Before, looking for kills, reads or defs.
  I = MachineBasicBlock::const_iterator(Before);
  // If this is the first insn in the block, don't search backwards.
  if (I != MBB.begin()) {
    do {
      --I;

      if (I->isDebugInstr())
        continue;

      --N;

      MachineOperandIteratorBase::PhysRegInfo Info =
          ConstMIOperands(*I).analyzePhysReg(Reg, TRI);

      // Defs happen after uses so they take precedence if both are present.

      // Register is dead after a dead def of the full register.
      if (Info.DeadDef)
        return false;
      // Register is (at least partially) live after a def.
      if (Info.Defined) {
        if (!Info.PartialDeadDef)
          return true;
        // As soon as we saw a partial definition (dead or not),
        // we cannot tell if the value is partial live without
        // tracking the lanemasks. We are not going to do this,
        // so fall back on the remaining of the analysis.
        break;
      }
      // Register is dead after a full kill or clobber and no def.
      if (Info.Killed || Info.Clobbered)
        return false;
      // Register must be live if we read it.
      if (Info.Read)
        return true;

    } while (I != MBB.begin() && N > 0);
  }

  // Did we get to the start of the block?
  if (I == MBB.begin()) {
    // If so, the register's state is definitely defined by the live-in state.
    for (const MachineBasicBlock::RegisterMaskPair &LI : MBB.liveins())
      if (TRI->regsOverlap(LI.PhysReg, Reg))
        return true;

    return false;
  }

  // At this point we have no idea of the liveness of the register.
  return true;
}

/*
// mostly taken from TaseDecorateCartridgePass
bool X86TASENaiveChecksPass::isRaxLive( MachineBasicBlock::const_iterator I ) const {

  auto *MBB = I->getParent();
  auto begin = MBB->begin();
  //  std::cout << "TASE: Checking Rax liveness of MBB \"" << MBB->getFullName() << "\", Opcode: " << std::hex << I->getOpcode() << std::dec << std::endl;

  auto Info = ConstMIOperands( *I ).analyzePhysReg( X86::RAX, TRI );
  //std::cout << "TASE: -- Info: { Read: " << Info.Read << ", Killed: " << Info.Killed << ", Defined: " <<
  //  Info.Defined << ", FullyDefined: " << Info.FullyDefined << ", Clobbered: " << Info.Clobbered << ", DeadDef: " <<
  //  Info.DeadDef << "}" << std::endl;

  if( Info.Defined || Info.Clobbered ) {
    return false;
  }
  if( I == begin ) {
    //  std::cout << "TASE: -- isLiveIn (0)" << std::endl;
    return MBB->isLiveIn( X86::RAX );
  }

  --I;

  for ( ; I != begin; --I ) {
    if ( I->isDebugInstr() ) continue;

    Info = ConstMIOperands( *I ).analyzePhysReg( X86::RAX, TRI );
    //std::cout << "TASE: -- Info: { Read: " << Info.Read << ", Killed: " << Info.Killed << ", Defined: " <<
    //  Info.Defined << ", FullyDefined: " << Info.FullyDefined << ", Clobbered: " << Info.Clobbered << ", DeadDef: " <<
    //  Info.DeadDef << "}" << std::endl;

    if ( Info.Read && Info.Killed ) {
      return false;
    } else if ( Info.Defined && Info.DeadDef ) {
      return false;
    } else if ( Info.Clobbered ) {
      return false;
    }
  }
  
  if( I == begin ) {
    Info = ConstMIOperands( *I ).analyzePhysReg( X86::RAX, TRI );
    //std::cout << "TASE: -- Info: { Read: " << Info.Read << ", Killed: " << Info.Killed << ", Defined: " <<
    //  Info.Defined << ", FullyDefined: " << Info.FullyDefined << ", Clobbered: " << Info.Clobbered << ", DeadDef: " <<
    //  Info.DeadDef << "}" << std::endl;

    if ( Info.Read && Info.Killed ) {
      return false;
    } else if ( Info.Defined && Info.DeadDef ) {
      return false;
    } else if ( Info.Clobbered ) {
      return false;
    }
  }
  
  //std::cout << "TASE: -- isLiveIn (1)" << std::endl;
  return MBB->isLiveIn( X86::RAX );
}
*/

void X86TASENaiveChecksPass::EmitSpringboard(MachineInstr *FirstMI, const char *label) {
  MachineBasicBlock *MBB = FirstMI->getParent();
  MachineFunction *MF = MBB->getParent();
  MCCartridgeRecord *cartridge = MF->getContext().createCartridgeRecord(MBB->getSymbol(), MF->getName());
  bool eflags_dead = isSafeToClobberEFLAGS(*MBB, MachineBasicBlock::iterator(FirstMI));
  cartridge->flags_live = !eflags_dead;
  CurrentMI = FirstMI;
  InsertInstr(X86::LEA64r, TASE_REG_RET)
    .addReg(X86::RIP)           // base - attempt to use the locality of cartridgeBody.                                          
    .addImm(1)                  // scale                                                                                         
    .addReg(X86::NoRegister)    // index                                                                                         
    .addImm(5)                  // offset
    .addReg(X86::NoRegister);   // segment
  
  if(!TASESharedMode){
    InsertInstr(X86::TASE_JMP_4)
      .addExternalSymbol(label);
  } else {
    InsertInstr(X86::TASE_JMP_4)
      .addExternalSymbol(label, X86II::MO_PLT);
  }

    FirstMI->setPreInstrSymbol(*MF, cartridge->Body());
  MBB->front().setPreInstrSymbol(*MF, cartridge->Cartridge());
  bool foundTerm = false;
  for (auto MII = MBB->instr_begin(); MII != MBB->instr_end(); MII++) {
    if (MII->isTerminator()) {
      MII->setPostInstrSymbol(*MF, cartridge->End());
      foundTerm = true;
      break;
    }
  }

  if (!foundTerm) {
    MBB->back().setPostInstrSymbol(*MF, cartridge->End());
  }
}


bool X86TASENaiveChecksPass::runOnMachineFunction(MachineFunction &MF) {
  LLVM_DEBUG(dbgs() << "********** " << getPassName() << " : " << MF.getName()
                    << " **********\n");

  if (Analysis.getInstrumentationMode() == TIM_NONE) {
    LLVM_DEBUG(dbgs() << "TASE: Skipping instrumentation by request.\n");
    return false;
  }

  Subtarget = &MF.getSubtarget<X86Subtarget>();
//   MRI = &MF.getRegInfo();
  TII = Subtarget->getInstrInfo();
  TRI = Subtarget->getRegisterInfo();
  
  bool modified = false;
  bool modeled = false;
  for (MachineBasicBlock &MBB : MF) {
    LLVM_DEBUG(dbgs() << "TASE: Analyzing taint for block " << MBB);
    // Every cartridge entry sequence is going to flush the accumulators.
    Analysis.ResetDataOffsets();


    if ( !MBB.empty() ) {
      LLVM_DEBUG(dbgs() << "TASE: Creating cartridge record");
      auto eflags_dead = isSafeToClobberEFLAGS(MBB, MachineBasicBlock::iterator(&MBB.front()));;
      auto *cartridge = MF.getContext().createCartridgeRecord(MBB.getSymbol(), MF.getName());

      cartridge->flags_live = !eflags_dead;

      LLVM_DEBUG(dbgs() << "TASE: Emitting CartridgeHead symbol");
      MBB.front().setPreInstrSymbol(MF, cartridge->Cartridge()); // create/emit CartridgeHead symbol
    } else {
      LLVM_DEBUG(dbgs() << "TASE: Skipping Cartridge creation since MBB is empty");
    }
    // In using this range, we use the super special property that a machine
    // instruction list obeys the iterator characteristics of list<
    // undocumented property that instr_iterator is not invalidated when
    // one inserts into the list.

    LLVM_DEBUG(dbgs() << "TASE: Checking Model status and looping over MBB instrs");
    modeled = Analysis.isModeledFunction( MF.getName() );
    for (MachineInstr &MI : MBB.instrs()) {
      if( modeled ) {
	if ( &MI == &MF.front().front() ) {
	  EmitSpringboard(&MI, "sb_modeled");
	} else if ( &MI == &MBB.front() ) {
	  EmitSpringboard(&MI, "sb_reopen");
	}
      }

      LLVM_DEBUG(dbgs() << "TASE: Analyzing taint for " << MI);
      if (MI.SkipInTASE) {
	continue;
      }

      if (Analysis.isSpecialInlineAsm(MI)) {
        continue;
      }
      if (MI.mayLoad() && MI.mayStore()) {
        errs() << "TASE: Somehow we have a CISC instruction! " << MI;
        llvm_unreachable("TASE: Please handle this instruction.");
      }
      // Only our RISC-like loads should have this set.
      if (!MI.mayLoad() && !MI.mayStore() && !MI.isCall() && !MI.isReturn() && !MI.hasUnmodeledSideEffects()) {
        // Non-memory instructions need no instrumentation.
        continue;
      }
      if (Analysis.isSafeInstr(MI.getOpcode())) {
        continue;
      }
      if (MI.hasUnmodeledSideEffects() && !Analysis.isMemInstr(MI.getOpcode())) {
        errs() << "TASE: An instruction with potentially unwanted side-effects is emitted. " << MI;
        continue;
      }
      if (!Analysis.isMemInstr(MI.getOpcode() )) {
	  MI.dump();
      }
      
      assert(Analysis.isMemInstr(MI.getOpcode()) && "TASE: Encountered an instruction we haven't handled.");
      if(MI.getFlag(MachineInstr::MIFlag::tainted_inst_saratest)){
	InstrumentInstruction(MI);
        modified = true;
      }
    }
  }
  return modified;
}

// Adapted from our capture taint pass.  Instrumentation expects to see only known instructions.
// We naively insert poison checks before all instuctions that read from or write to memory.

void X86TASENaiveChecksPass::InstrumentInstruction(MachineInstr &MI) {
  CurrentMI = &MI;
  NextMII = std::next(MachineBasicBlock::instr_iterator(MI));
    
  size_t size = Analysis.getMemFootprint(MI.getOpcode());
  switch (MI.getOpcode()) {
    default:
      MI.dump();
      llvm_unreachable("TASE: Unknown instructions.");
      break;
    case X86::FARCALL64:
      errs() << "TASE: FARCALL64?";
      MI.dump();
      //llvm_unreachable("TASE: Who's jumping across segmented code?");
      break;
    //case X86::POP64r:
      // Fast path
      //PoisonCheckReg(size, 8);
      //PoisonCheckStack(0); //New naive code!
      //PoisonCheckPushPop();
      //break;      
      //    case X86::POPF64:
      //      PoisonCheckStack(0);
      //      break;
    case X86::CALLpcrel16:
    case X86::CALL64pcrel32:
    case X86::CALL64r:
    case X86::CALL64r_NT:
    case X86::CALL64m:
      // Fixed addresses cannot be symbolic. Indirect calls are detected as
      // symbolic when their base address is loaded and calculated.
      // A stack push is performed during a call and since we don't sweep old
      // taint from the stacm values from the stack when returning from
      // previous functions,, we check to see if we are pushing into a
      // "symbolic" stack cell.
    case X86::PUSH64i8:
    case X86::PUSH64i32:
    case X86::PUSH64r:
    case X86::PUSHF64:
      PoisonCheckPushPop(true);
      break;
    case X86::RETQ:
      // We should not have a symbolic return address but we treat this as a
      // standard pop of the stack just in case.

      //If paranoid control flow is enabled, we've already inserted the check
      //for RET in an earlier pass.
      if (TASEParanoidControlFlow) {
	break;
      }
    case X86::POP16r:
    //case X86::POP32r: not enabled 64bit
    case X86::POP16rmr:
    //case X86::POP32rmr: not enabled 64 bit
    case X86::POP64r:
    case X86::POP64rmr:
    case X86::POPF64:
      //case X86::POP16rmm:
    //case X86::POP32rmm:
    //case X86::POP64rmm:// rmm -> memory destination, doesn't matter
      // Values are zero-extended during the push - so check the entire stack
      // slot for poison before the write.
      //PoisonCheckStack(-size);  //Should be the same for naive code.
      PoisonCheckPushPop(false);
      break;
    case X86::MOV8mi: case X86::MOV8mr: case X86::MOV8mr_NOREX: case X86::MOV8rm: case X86::MOV8rm_NOREX:
    case X86::MOVZX16rm8: case X86::MOVZX32rm8: case X86::MOVZX32rm8_NOREX: case X86::MOVZX64rm8:
    case X86::MOVSX16rm8: case X86::MOVSX32rm8: case X86::MOVSX32rm8_NOREX: case X86::MOVSX64rm8:
    case X86::PINSRBrm: case X86::VPINSRBrm:
      // For 8 bit memory accesses, we want access to the address so that we can
      // appropriately align it for our 2 byte poison check.
    case X86::MOV16mi: case X86::MOV16mr:
    case X86::MOV32mi: case X86::MOV32mr:
    case X86::MOV64mi32: case X86::MOV64mr:
    case X86::MOVSSmr: case X86::MOVLPSmr: case X86::MOVHPSmr:
    case X86::VMOVSSmr: case X86::VMOVLPSmr: case X86::VMOVHPSmr:
    case X86::MOVPDI2DImr: case X86::MOVSS2DImr:
    case X86::VMOVPDI2DImr: case X86::VMOVSS2DImr:
    case X86::MOVSDmr: case X86::MOVLPDmr: case X86::MOVHPDmr:
    case X86::VMOVSDmr: case X86::VMOVLPDmr: case X86::VMOVHPDmr:
    case X86::MOVPQIto64mr: case X86::MOVSDto64mr: case X86::MOVPQI2QImr:
    case X86::VMOVPQIto64mr: case X86::VMOVSDto64mr: case X86::VMOVPQI2QImr:
    case X86::MOVUPSmr: case X86::MOVUPDmr: case X86::MOVDQUmr:
    case X86::MOVAPSmr: case X86::MOVAPDmr: case X86::MOVDQAmr:
    case X86::VMOVUPSmr: case X86::VMOVUPDmr: case X86::VMOVDQUmr:
    case X86::VMOVAPSmr: case X86::VMOVAPDmr: case X86::VMOVDQAmr:
    case X86::PEXTRBmr: case X86::PEXTRWmr: case X86::PEXTRDmr: case X86::PEXTRQmr:
    case X86::VPEXTRBmr: case X86::VPEXTRWmr: case X86::VPEXTRDmr: case X86::VPEXTRQmr:
      PoisonCheckMem(size);  //Should be same for naive.
      break;
    case X86::MOV16rm: case X86::MOV32rm: case X86::MOV64rm:
    case X86::MOVZX32rm16: case X86::MOVZX64rm16:
    case X86::MOVSX32rm16: case X86::MOVSX64rm16: case X86::MOVSX64rm32:
    case X86::MOVSSrm: case X86::MOVLPSrm: case X86::MOVHPSrm:
    case X86::VMOVSSrm: case X86::VMOVLPSrm: case X86::VMOVHPSrm:
    case X86::MOVDI2PDIrm: case X86::MOVDI2SSrm:
    case X86::VMOVDI2PDIrm: case X86::VMOVDI2SSrm:
    case X86::MOVSDrm: case X86::MOVLPDrm: case X86::MOVHPDrm:
    case X86::VMOVSDrm: case X86::VMOVLPDrm: case X86::VMOVHPDrm:
    case X86::MOV64toPQIrm: case X86::MOV64toSDrm: case X86::MOVQI2PQIrm:
    case X86::VMOV64toPQIrm: case X86::VMOV64toSDrm: case X86::VMOVQI2PQIrm:
    case X86::MOVUPSrm: case X86::MOVUPDrm: case X86::MOVDQUrm:
    case X86::MOVAPSrm: case X86::MOVAPDrm: case X86::MOVDQArm:
    case X86::VMOVUPSrm: case X86::VMOVUPDrm: case X86::VMOVDQUrm:
    case X86::VMOVAPSrm: case X86::VMOVAPDrm: case X86::VMOVDQArm:
    case X86::PINSRWrm: case X86::PINSRDrm: case X86::PINSRQrm:
    case X86::VPINSRWrm: case X86::VPINSRDrm: case X86::VPINSRQrm:
    case X86::INSERTPSrm: case X86::VINSERTPSrm:
    case X86::PMOVSXBWrm: case X86::PMOVSXBDrm: case X86::PMOVSXBQrm:
    case X86::PMOVSXWDrm: case X86::PMOVSXWQrm: case X86::PMOVSXDQrm:
    case X86::PMOVZXBWrm: case X86::PMOVZXBDrm: case X86::PMOVZXBQrm:
    case X86::PMOVZXWDrm: case X86::PMOVZXWQrm: case X86::PMOVZXDQrm:
      //PoisonCheckReg(size);
      PoisonCheckMem(size); //Updated for naive.  Checks need to go before operation.
      break;
    //case X86::VMOVUPSYmr: case X86::VMOVUPDYmr: case X86::VMOVDQUYmr:
    //case X86::VMOVAPSYmr: case X86::VMOVAPDYmr: case X86::VMOVDQAYmr:
    //case X86::VMOVUPSYrm: case X86::VMOVUPDYrm: case X86::VMOVDQUYrm:
    //case X86::VMOVAPSYrm: case X86::VMOVAPDYrm: case X86::VMOVDQAYrm:
  }
  CurrentMI = nullptr;
}

MachineInstrBuilder X86TASENaiveChecksPass::InsertInstr(unsigned int opcode, bool before) {
  assert(CurrentMI && "TASE: Must only be called in the context of of instrumenting an instruction.");
  return BuildMI(*CurrentMI->getParent(),
      before ? MachineBasicBlock::instr_iterator(CurrentMI) : NextMII,
      CurrentMI->getDebugLoc(), TII->get(opcode));
}

MachineInstrBuilder X86TASENaiveChecksPass::InsertInstr(unsigned int opcode, unsigned int destReg, bool before) {
  assert(CurrentMI && "TASE: Must only be called in the context of of instrumenting an instruction.");
  return BuildMI(*CurrentMI->getParent(),
      before ? MachineBasicBlock::instr_iterator(CurrentMI) : NextMII,
      CurrentMI->getDebugLoc(), TII->get(opcode), destReg);
}


void X86TASENaiveChecksPass::PoisonCheckStack(int64_t stackOffset) {
  const size_t stackAlignment = 8;
  assert(stackOffset % stackAlignment == 0 && "TASE: Unaligned offset into the stack - must be multiple of 8");


  //For naive, just mirror the logic from PoisonCheckMem for now.
  //We can optimize by assuming that stack ops (e.g., push) are
  //always 2 byte aligned, but let's do that later.
  PoisonCheckMem(stackOffset);


  
  /*
  unsigned int acc_idx = AllocateOffset(stackAlignment);

  assert(Analysis.getInstrumentationMode() == TIM_SIMD);
  //TODO: If AVX is enabled, switch to VPINSR or something else.
  InsertInstr(TASE_PINSRrm[cLog2(stackAlignment)], TASE_REG_DATA)
    .addReg(TASE_REG_DATA)
    .addReg(X86::RSP)         // base
    .addImm(1)                // scale
    .addReg(X86::NoRegister)  // index
    .addImm(stackOffset)      // offset
    .addReg(X86::NoRegister)  // segment
    .addImm(acc_idx / stackAlignment)
    .cloneMemRefs(*CurrentMI);
  */
}

// check %rsp, push operand should be clear by invariant, pop doesn't have one
void X86TASENaiveChecksPass::PoisonCheckPushPop(bool push){
  SmallVector<MachineOperand, X86::AddrNumOperands> MOs;
  MOs.push_back( MachineOperand::CreateReg( TASE_REG_REFERENCE, false ) );

  bool eflags_dead = isSafeToClobberEFLAGS( *CurrentMI->getParent(), MachineBasicBlock::iterator( CurrentMI ) );
  bool rax_live = isRaxLive( *CurrentMI->getParent(), CurrentMI );

  auto Info = ConstMIOperands( *CurrentMI ).analyzePhysReg( X86::EFLAGS, TRI );
  bool defines_eflags = ( Info.Defined && !Info.DeadDef );
  if ( eflags_dead && !defines_eflags ) {
    // kill eflags after this instr
    InsertInstr(X86::XOR64rr, false)
      .addDef(TASE_REG_TMP)
      .addReg(TASE_REG_TMP, RegState::Undef)
      .addReg(TASE_REG_TMP, RegState::Undef);
  }
  
  // PUSH: rsp-8 -> r14, POP: rsp -> r14
  InsertInstr( X86::LEA64r, TASE_REG_TMP )
    .addReg( X86::RSP )
    .addImm( 1 )
    .addReg( X86::NoRegister )
    .addImm( push ? -8 : 0 )
    .addReg( X86::NoRegister );
  
  if ( !eflags_dead ) {    
      //We need to preserve flags.

      //For the naive case, we will
      //1. Move %rax into some memory location.  We call this "saved_rax"
      // in springboard.S (see 30-31 in springboard.S)
      //2. call lahf to save flags in rax.
      /*
      movq      %rax, saved_rax
      lahf
      */
      //LOGIC GOES HERE

    /* actually becomes:
       movq &saved_rax,%r15
       movq %rax,(%r15)
       lahf
    */
    
    if( rax_live ) {
      // rip-relative mov
      InsertInstr( X86::MOV64mr )
	.addReg( X86::RIP ) // base
	.addImm( 1 )  // scale
	.addReg( X86::NoRegister ) // index
	.addExternalSymbol( "saved_rax" ) // offset
	.addReg( X86::NoRegister ) // segment
	.addReg( X86::RAX ); // src
    }

    InsertInstr( X86::LAHF );

  }

  //And then later after we perform the poison check we'll restore flags....
  // Use TASE_REG_RET as a temporary register to hold offsets/indices.

  auto &tmpinst = InsertInstr( X86::SHR64r1, TASE_REG_TMP )
    .addReg( TASE_REG_TMP );
  tmpinst->getOperand(2).setIsDead();

  MOs.push_back( MachineOperand::CreateReg( TASE_REG_TMP, false ) );     // base
  MOs.push_back( MachineOperand::CreateImm( 1 ) );                       // scale
  MOs.push_back( MachineOperand::CreateReg( TASE_REG_TMP, false ) );     // index
  MOs.push_back( MachineOperand::CreateImm( 0 ) );                       // offset
  MOs.push_back(MachineOperand::CreateReg( X86::NoRegister, false ) );  // segment

      //For naive instrumentation -- we want to basically throw out the accumulator index logic
  //and always call the vcmpeqw no matter what after the load into the XMM register
  auto MIB = InsertInstr( X86::VPCMPEQWrm ) // false for isDef
  .addDef( TASE_REG_DATA );
  for ( auto& x : MOs ) {
    MIB.addAndUse( x );
  }

  //I guess we just always want to load the larger vpcmpeqwrm 128 bit value because that's easier.



  //Naive: Actually do the flags-clobbering cmp here if it hasn't happened earlier.
  //See sbm_compare_poison in sb_reopen in springboard.S
    
  // eflags <- ptest XMM_DATA, XMM_DATA
  InsertInstr(X86::PTESTrr)
    .add( MachineOperand::CreateReg( TASE_REG_DATA, false ) )
    .add( MachineOperand::CreateReg( TASE_REG_DATA, false) );

  InsertInstr(X86::MOV64ri32, TASE_REG_TMP)
    .addImm( !eflags_dead << 1 | rax_live ); // %r14 liveness flags for springboard
    
  
  //Naive: Actually do the JZ here
  //(Make sure flags and rax get restored if we go to the interpreter!  They need
  //to have their original pre-clobbered values!)
  //Jnz as per sb_reopen in springboard.S to sb_eject
  //Example of adding symbol is in our addCartridgeSpringboard pass.
  InsertInstr(X86::LEA64r, TASE_REG_RET)
    .addReg(X86::RIP)
    .addImm(1)
    .addReg(X86::NoRegister)
    .addImm( eflags_dead ? 6 : ( rax_live ? 14 : 7 ) ) // size of next (jmp) instr [6] + optional sahf/mov (1/7)
    .addReg(X86::NoRegister);
  
  auto &tmpinst2 = InsertInstr( X86::TASE_JE )
    .addExternalSymbol( "sb_eject" );

  tmpinst2->getOperand(1).setIsKill(); // implicit killed eflags

  //Naive: Restore flags and rax here
  //sahf, and then restore rax from saved_rax (see 123-4 in springboard.S)
  /*
    sahf
    movq        saved_rax , %rax
  */
  //LOGIC GOES HERE
  if( !eflags_dead ){
    InsertInstr( X86::SAHF );
  
    if ( rax_live ) {      
      InsertInstr( X86::MOV64rm, X86::RAX, true )
        .addReg( X86::RIP )  // base
        .addImm( 1 )             // scale 
        .addReg( X86::NoRegister ) // index
        .addExternalSymbol( "saved_rax" ) //offset
        .addReg( X86::NoRegister ); // segment
    }
  }
}


//For naive instrumentation mode, this function does the following.
//1: Save flags.  (see lines 30-31 in springboard.S)

//2: Grab the value to be checked (along with our alignment trick),
//and stuff it into an XMM register.  We're still using XMM checks
//because it makes checking 2-byte intervals easier.  I think we can
//largely recycle the old logic in PoisonCheckMem from X86TASECaptureTaint.cpp.

//3: Do a PCMPEQ for poison. (see lines 28-32 in springboard.S)

//4: PCMEPEQ doesn't actually modify flags, so do a PTEST (lines 28-32 in springboard.S) 

//5: JE to the interpreter (see lines 111-113 in springboard.S)

//6: Restore flags (see lines 131-132 in springboard.S)
void X86TASENaiveChecksPass::PoisonCheckMem(size_t size) {
  int addrOffset = X86II::getMemoryOperandNo( CurrentMI->getDesc().TSFlags );
  // addrOffset is -1 if we failed to find the operand.
  assert( addrOffset >= 0 && "TASE: Unable to determine instruction memory operand!" );
  addrOffset += X86II::getOperandBias( CurrentMI->getDesc() );

  SmallVector<MachineOperand,X86::AddrNumOperands> MOs;
  MOs.push_back( MachineOperand::CreateReg( TASE_REG_REFERENCE, false ) );
  // Stash our poison - use the given memory operands as our source.
  // We may get the mem_operands incorrect.  I believe we need to clear the
  // MachineMemOperand::MOStore flag and set the MOLoad flag but we're late
  // in the compilation process and mem_operands is mostly a hint anyway.
  // It is always legal to have instructions with no mem_operands - the
  // rest of the compiler should just deal with it extremely conservatively
  // in terms of alignment and volatility.
  //
  // We can optimize the aligned case a bit but usually, we just assume an
  // unaligned memory operand and re-align it to a 2-byte boundary.
  //
  bool eflags_dead = isSafeToClobberEFLAGS( *CurrentMI->getParent(), MachineBasicBlock::iterator( CurrentMI ) );
  bool rax_live = isRaxLive( *CurrentMI->getParent(), MachineBasicBlock::iterator( CurrentMI ) );
  
  if( eflags_dead ) {
    auto *MBB = CurrentMI->getParent();
    auto *MF = MBB->getParent();
    auto *cartridge = MF->getContext().createCartridgeRecord(MBB->getSymbol(), MF->getName());
    cartridge->flags_live = !eflags_dead;

    // kill eflags after this instr
    auto Info = ConstMIOperands( *CurrentMI ).analyzePhysReg( X86::EFLAGS, TRI );
    bool defines_eflags = ( Info.Defined && !Info.DeadDef );
    if ( !defines_eflags ) {
      InsertInstr(X86::XOR64rr, false)
	.addDef(TASE_REG_TMP)
	.addReg(TASE_REG_TMP, RegState::Undef)
	.addReg(TASE_REG_TMP, RegState::Undef);
    }
  }
   
  
  if ( size >= 16 ) {
    assert( Analysis.getInstrumentationMode() == TIM_SIMD && "TASE: GPR poisoning not implemented for SIMD registers." );
    assert( size == 16 && "TASE: Unimplemented. Handle YMM/ZMM SIMD instructions properly." );
    // TODO: Assert that the compiler only emits aligned XMM reads.
    MOs.append( CurrentMI->operands_begin() + addrOffset, CurrentMI->operands_begin() + addrOffset + X86::AddrNumOperands );
  } else {
    // Precalculate the address, align it to a two byte boundary and then
    // read double the size just to be safe.

    
    if ( CurrentMI->memoperands_begin() && TASEUseAlignment && CurrentMI->hasOneMemOperand() && size > 1 &&
        ( ( *CurrentMI->memoperands_begin() )->getAlignment() % 2 ) == 1 ) {
      size *= 2;
    }

    // If this address operand is just a register, we can skip the lea. Keeping the LEA is simpler here...
    //    unsigned int AddrReg = getAddrReg(addrOffset);
    //    if( AddrReg == X86::NoRegister ){
    //    AddrReg = TASE_REG_TMP;
    auto MIB = InsertInstr( X86::LEA64r, TASE_REG_TMP );
    for ( int i = 0; i < X86::AddrNumOperands; i++ ) {
      MIB.addAndUse( CurrentMI->getOperand( addrOffset + i ) );
    }
    //}

    if ( !eflags_dead ) {
      //We need to preserve flags.
      
      //For the naive case, if rax is live we will
      //1. Move %rax into some memory location.  We call this "saved_rax"
      // in springboard.S (see 30-31 in springboard.S)
      //2. call lahf to save flags in rax.
      /*
      movq      %rax, saved_rax
      lahf
      */
      if ( rax_live ) {
	InsertInstr( X86::MOV64mr )
	  .addReg( X86::RIP ) // base
	  .addImm( 1 )  // scale
	  .addReg( X86::NoRegister ) // index
	  .addExternalSymbol( "saved_rax" ) // offset
	  .addReg( X86::NoRegister ) // segment
	  .addReg( X86::RAX ); // src
      }
      InsertInstr( X86::LAHF );
      //And then later after we perform the poison check we'll restore flags....
    }
    // Use TASE_REG_RET as a temporary register to hold offsets/indices.
    auto &tmpinst = InsertInstr( X86::SHR64r1, TASE_REG_TMP )
      .addReg( TASE_REG_TMP );
    tmpinst->getOperand(2).setIsDead(); // flags dead-def

    // addrReg = r14 then
    // (%r14,%r14,1), which gives us %r14 + %r14 * 1 == addr - (addr % 2) -> aligned addr
    MOs.push_back( MachineOperand::CreateReg( TASE_REG_TMP, false ) );     // base
    MOs.push_back( MachineOperand::CreateImm( 1 ) );                       // scale
    MOs.push_back( MachineOperand::CreateReg( TASE_REG_TMP, false ) );     // index
    MOs.push_back( MachineOperand::CreateImm( 0 ) );                       // offset
    MOs.push_back( MachineOperand::CreateReg( X86::NoRegister, false ) );  // segment
  }


  //For naive instrumentation -- we want to basically throw out the accumulator index logic
  //and always call the vcmpeqw no matter what after the load into the XMM register

  // vpcmpeqwrm (%r14, %r14, 1), %xmm13, %xmm15 / vector compare mem w/ poison reference, store in %xmm15
  //I guess we just always want to load the larger vpcmpeqwrm 128 bit value because that's easier.
  auto MIB = InsertInstr( X86::VPCMPEQWrm, TASE_REG_DATA );
  for ( auto& x : MOs ) {
    MIB.addAndUse( x );
  }


  //Naive: Actually do the flags-clobbering cmp here if it hasn't happened earlier.
  //See sbm_compare_poison in sb_reopen in springboard.S

  // ptest XMM_DATA, XMM_DATA
  InsertInstr(X86::PTESTrr)
    .add( MachineOperand::CreateReg( TASE_REG_DATA, false ) )
    .add( MachineOperand::CreateReg( TASE_REG_DATA, false ) );

  InsertInstr(X86::MOV64ri32, TASE_REG_TMP)
    .addImm( !eflags_dead << 1 | rax_live ); // %r14 liveness flag for springboard    
  
  //Naive: Actually do the JNZ here
  //(Make sure flags and rax get restored if we go to the interpreter!  They need
  //to have their original pre-clobbered values!)
  //Jnz as per sb_reopen in springboard.S to sb_eject
  //Example of adding symbol is in our addCartridgeSpringboard pass.
  InsertInstr(X86::LEA64r, TASE_REG_RET)
    .addReg(X86::RIP)
    .addImm(1)
    .addReg(X86::NoRegister)
    .addImm( eflags_dead ? 6 : ( rax_live ? 14 : 7 ) ) // size of next (jmp) instr [6] + optional sahf/mov (1/7)
    .addReg(X86::NoRegister);

  auto &tmpinst = InsertInstr( X86::TASE_JE )
    .addExternalSymbol( "sb_eject" );

  tmpinst->getOperand(1).setIsKill();
  
  //Naive: Restore flags and rax here
  //sahf, and then restore rax from saved_rax (see 123-4 in springboard.S)
  /*
    sahf
    movq        saved_rax , %rax
  */
  //LOGIC GOES HERE
  if ( !eflags_dead ) {
    InsertInstr( X86::SAHF );

    if( rax_live ) {    
      InsertInstr( X86::MOV64rm, X86::RAX, true )
        .addReg( X86::RIP ) // base
        .addImm( 1 )  // scale
        .addReg( X86::NoRegister ) // index
        .addExternalSymbol( "saved_rax" ) // offset
        .addReg( X86::NoRegister ); // segment
    }
  }
}


unsigned int X86TASENaiveChecksPass::getAddrReg(unsigned Op) {
  auto Disp = CurrentMI->getOperand(Op + X86::AddrDisp);
  unsigned int AddrBase = CurrentMI->getOperand(Op + X86::AddrBaseReg).getReg();
  if (Disp.isImm() && Disp.getImm() == 0 &&
      CurrentMI->getOperand(Op + X86::AddrIndexReg).getReg() == X86::NoRegister &&
      CurrentMI->getOperand(Op + X86::AddrScaleAmt).getImm() == 1) {
    // Special case - check if we are reading address 0. Doesn't matter how we instrument this.
    if (AddrBase != X86::NoRegister) {
      return AddrBase;
    } else {
      LLVM_DEBUG(dbgs() << "TASE: Founds a zero address at instruction: " << *CurrentMI);
    }
  }
  return X86::NoRegister;
}

unsigned int X86TASENaiveChecksPass::AllocateOffset(size_t size) {
  int offset = -1;
  
  offset = Analysis.AllocateDataOffset(size);
  if (offset < 0) {
    InsertInstr(X86::PCMPEQWrr, TASE_REG_DATA)
        .addReg(TASE_REG_DATA)
      .addReg(TASE_REG_REFERENCE);
    InsertInstr(X86::PORrr, TASE_REG_ACCUMULATOR)
      .addReg(TASE_REG_ACCUMULATOR)
      .addReg(TASE_REG_DATA);
    Analysis.ResetDataOffsets();
    offset = Analysis.AllocateDataOffset(size);
  }
  
  assert(offset >= 0 && "TASE: Unable to acquire a register for poison instrumentation.");
  return offset;
}

INITIALIZE_PASS(X86TASENaiveChecksPass, PASS_KEY, PASS_DESC, false, false)

FunctionPass *llvm::createX86TASENaiveChecks() {
  return new X86TASENaiveChecksPass();
}
