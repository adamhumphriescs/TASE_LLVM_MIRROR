// Add TASE taint discovery instrumentation after every load or store
// instruction.


#include "X86.h"
#include "X86InstrBuilder.h"
#include "X86InstrInfo.h"
#include "X86Subtarget.h"
#include "X86TASE.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/IR/DebugLoc.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include <algorithm>
#include <cassert>
#include <iostream>
using namespace llvm;

#define PASS_KEY "x86-tase-capture-taint"
#define PASS_DESC "X86 TASE taint tracking instrumentation."
#define DEBUG_TYPE PASS_KEY

extern bool TASEParanoidControlFlow;
extern bool TASEStackGuard;
extern bool TaseAlign;
extern bool TaseYMM;
extern bool DWordPoison;

// STATISTIC(NumCondBranchesTraced, "Number of conditional branches traced");

namespace llvm {
  void initializeX86TASECaptureTaintPassPass(PassRegistry &);
}

namespace {

class X86TASECaptureTaintPass : public MachineFunctionPass {
public:
  X86TASECaptureTaintPass() : MachineFunctionPass(ID),
    CurrentMI(nullptr),
    NextMII(nullptr)
  {
    initializeX86TASECaptureTaintPassPass(
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
//   const TargetRegisterInfo *TRI;
  MachineInstr *CurrentMI;
  MachineBasicBlock::instr_iterator NextMII;
  TASEAnalysis Analysis;
  unsigned int referencereg;
  unsigned int datareg;
  unsigned int accreg;
  unsigned int cmpOPrr;
  unsigned int cmpOPrm;
  unsigned int orOP;
  unsigned int bytesPerSlot;
  
  void InstrumentInstruction(MachineInstr &MI);
  MachineInstrBuilder InsertInstr(unsigned int opcode, bool before = true);
  MachineInstrBuilder InsertInstr(unsigned int opcode, unsigned int destReg, bool before = true);

  void PoisonCheckReg(size_t size, unsigned int align = 0);
  void PoisonCheckStack(int64_t stackOffset);
  void PoisonCheckMem(size_t size);
  void PoisonCheckRegInternal(size_t size, unsigned int reg, unsigned int acc_idx);
  void RotateAccumulator(size_t size, unsigned int acc_idx);
  unsigned int getAddrReg(unsigned Op);
  unsigned int AllocateOffset(size_t size, const std::string &str);


// standard cases, same for XMM/YMM regardless of poison size
template<typename Vec>
bool insertStdElementMem(unsigned int acc_idx, size_t size, MachineInstrBuilder &MIB, Vec &MOs) {
  if( acc_idx == 0  && size == 4 ) {

    MIB = InsertInstr(X86::MOVSSrm, TASE_REG_DATA);
    return true;
    
  } else if( acc_idx == 0 && size == 8 ) {

    MIB = InsertInstr(X86::MOVSDrm, TASE_REG_DATA);
    return true;
    
  } else if ( acc_idx * bytesPerSlot == 8 && size == 8 ) {

    MIB = InsertInstr(X86::MOVHPSrm, TASE_REG_DATA);
    MOs.insert(MOs.begin(), MachineOperand::CreateReg(TASE_REG_DATA, false));
    return true;
    
  }

  return false;
}


// only called w/ TaseYMM
template<typename Vec>
void insertYMMElementMem(unsigned int acc_idx, size_t size, MachineInstrBuilder &MIB, Vec &MOs) {
  assert(acc_idx < (DWordPoison ? 16 : 32) || !(std::cerr << "TASE: Inserting into YMM register at index " << acc_idx <<" of " << (DWordPoison ? 16 : 32) << std::endl));

  if ( insertStdElementMem(acc_idx, size, MIB, MOs) ) {
    return;
    
  } else if ( acc_idx == 0 && size == 32 ) {  // AllocateDataOffset will reload, so do a direct comparison here
    
    MIB = InsertInstr(cmpOPrm, datareg);
    MOs.insert(MOs.begin(), MachineOperand::CreateReg(referencereg, false));

  } else if ( acc_idx == 0 && size == 16 ) {  // using the XMM VMOVDQU here. Does not zero the upper half of YMM
    MIB = InsertInstr(X86::VMOVDQUrm, TASE_REG_DATA);
    
  } else {
    unsigned int start = acc_idx * bytesPerSlot / size;

    if ( DWordPoison && size == 2 ) { // using XMMs here, so UPPER CASE registers

      MachineInstrBuilder MIB2 = InsertInstr(X86::PINSRWrm, TASE_REG_DATA);

      MIB2.addAndUse(MachineOperand::CreateReg(TASE_REG_DATA, false));
      for(unsigned int i = 0; i < MOs.size(); i++) {
	MIB2.addAndUse(MOs[i]);
      }
      MIB2.addAndUse(MachineOperand::CreateImm(start));
      
      start += 1;
    }

    MIB = InsertInstr(TASE_PINSRrm[cLog2(size)], TASE_REG_DATA);
    MOs.insert(MOs.begin(), MachineOperand::CreateReg(TASE_REG_DATA, false));
    MOs.push_back(MachineOperand::CreateImm(start));
  }
}


  // only called w/o TaseYMM
template<typename Vec>
void insertXMMElementMem(unsigned int acc_idx, size_t size, MachineInstrBuilder &MIB, Vec &MOs) {
  assert(acc_idx < (DWordPoison ? 8 : 16) || !(std::cerr << "TASE: Inserting into XMM register at index " << acc_idx <<" of " << (DWordPoison ? 8 : 16) << std::endl));
  assert(size <= 16 || !(std::cerr << "TASE: Inserting " << size << " bytes into XMM register" << std::endl));

  if ( insertStdElementMem(acc_idx, size, MIB, MOs) ) {
    return;
  } else if ( acc_idx == 0 && size == 16 ) {

    MIB = InsertInstr(cmpOPrm, datareg);
    MOs.insert(MOs.begin(), MachineOperand::CreateReg(referencereg, false));
    
  } else if( DWordPoison && size == 2 ) { // double the load. AllocateDataOffset doubles the request size in this case, no need to allocate again.                                           
    unsigned int start = acc_idx * bytesPerSlot / 2; // word offset for PINSRW

    MOs.insert(MOs.begin(), MachineOperand::CreateReg(datareg, false));
    MOs.push_back(MachineOperand::CreateImm(start));

    MachineInstrBuilder MIB2 = InsertInstr(X86::PINSRWrm, datareg);
    for(unsigned int i = 0; i < MOs.size(); i++) {
      MIB2.addAndUse(MOs[i]);
    }

    MIB = InsertInstr(X86::PINSRWrm, datareg);
    MOs.back() = MachineOperand::CreateImm(start+1);

  } else {
    unsigned int start = acc_idx * bytesPerSlot / size;

    MIB = InsertInstr(TASE_PINSRrm[cLog2(size)], datareg);
    MOs.insert(MOs.begin(), MachineOperand::CreateReg(datareg, false));
    MOs.push_back(MachineOperand::CreateImm(start));
  }
}

};

} // end anonymous namespace


char X86TASECaptureTaintPass::ID = 0;

bool X86TASECaptureTaintPass::runOnMachineFunction(MachineFunction &MF) {
  LLVM_DEBUG(dbgs() << "********** " << getPassName() << " : " << MF.getName()
                    << " **********\n");

  if (Analysis.getInstrumentationMode() == TIM_NONE) {
    LLVM_DEBUG(dbgs() << "TASE: Skipping instrumentation by requst.\n");
    return false;
  }

  referencereg = TaseYMM ? TASE_REG_YREFERENCE : TASE_REG_REFERENCE;  // 13
  datareg = TaseYMM ? TASE_REG_YDATA : TASE_REG_DATA;                 // 15
  accreg = TaseYMM ? TASE_REG_YACCUMULATOR : TASE_REG_ACCUMULATOR;    // 14

  cmpOPrr = DWordPoison ?
    (TaseYMM ? X86::VPCMPEQDYrr : X86::VPCMPEQDrr ) :
    (TaseYMM ? X86::VPCMPEQWYrr : X86::VPCMPEQWrr );
  
  cmpOPrm = DWordPoison ?
    (TaseYMM ? X86::VPCMPEQDYrm : X86::VPCMPEQDrm ) :
    (TaseYMM ? X86::VPCMPEQWYrm : X86::VPCMPEQWrm );
  
  orOP = TaseYMM ? X86::VPORYrr : X86::PORrr;

  bytesPerSlot = DWordPoison ? 4 : 2;
  
  Subtarget = &MF.getSubtarget<X86Subtarget>();
  TII = Subtarget->getInstrInfo();
  
  if (TASEStackGuard) {
    
    //Identify stackguard instructions and exempt them from instrumentation, as well as swap the canary value for our poison tag.
    
    //Assumption here is that a mov from %fs:0x28 is always going to uniquely identify loading the stackguard value,
    //since the linux distributions and libc implementations we use initialize the stack canaray value there.
    
    //Ideally, we could insert our own intrinsic within CodeGen/StackProtector.cpp for TASE but that would need to be carefully
    //written to survive all the LLVM instruction selection/scheduling and register allocation passes.
    
    for (MachineBasicBlock &MBB : MF) {
      for (MachineInstr &MI : MBB.instrs()) { 
	if (MI.getOpcode() == X86::MOV64rm) {
	  if (MI.getNumOperands() >= 6) {
	    MachineOperand m = MI.getOperand(5);
	    if (m.isReg()) {
	      if (m.getReg() == X86::FS) {

		MachineOperand off = MI.getOperand(4);
		if (off.getImm() == 0x28) {
		  printf("See 0x28 offset to fs.  Identified stack canary load. \n");
	      
		  MI.SkipInTASE = true;
		  MachineBasicBlock::instr_iterator NextMIItr = std::next(MachineBasicBlock::instr_iterator(MI));

		  //Instrument the write in the prologue in case the stack guard slot used to be a local symbolic variable.
		  //Don't instrument the load from the stack slot in the epilogue because TASE will already have caught
		  //reads from or writes to the stackguard slot in the body of the function via our standard instrumentation,
		  //and instrumenting the epilogue would always force a trap into TASE.
		  if (NextMIItr->mayLoad()) {
		    NextMIItr->SkipInTASE = true;
		  }
		
		  //Clobber fs load into dest register with poison.  We do this in the prologue before writing
		  //the instruction to store the canary value in the stackguard slot happens, and in the epilogue
		  //when we're loading the original canary value to determine if it has been modified.	     
		  //Todo -- Should we be using a different DebugLoc?
		  MachineInstrBuilder MIB = BuildMI(*MI.getParent(), NextMIItr, MI.getDebugLoc(), TII->get(X86::MOV64ri), MI.getOperand(0).getReg());
		  MIB.addImm(0xDEAD000000000000); //dead
		  MIB.getInstr()->SkipInTASE = true;
		  //Wipe the poison-handling reg if we're in the prologue.  Otherwise interpreter will
		  //get stuck with poison in reg.
		  if (NextMIItr->mayStore() ) {
		    MachineInstrBuilder ZeroReg = BuildMI(*MI.getParent(), std::next(NextMIItr), MI.getDebugLoc(), TII->get(X86::MOV64ri), MI.getOperand(0).getReg());
		    ZeroReg.addImm(0x0000000000000000);
		    ZeroReg->SkipInTASE = true;
		  }
		  //Wipe the stack protector slot if we're in the epilogue.
		  //Also wipe both registers used in the cmp because they'll have poison.
		  if (NextMIItr->mayLoad()) {
		    //Use our tase temp register for the stack guard slot wipe
		    MachineBasicBlock::instr_iterator CmpMIItr = std::next(NextMIItr);
		    MachineBasicBlock::instr_iterator JmpMIItr = std::next(CmpMIItr);
		    //Should be safe to clobber reg that was used for loading the fs-based canary value.
		    //Wipes the taint from the reg as a side effect.
		    //TODO: Double check
		    MachineInstrBuilder MIBWipeLoad = BuildMI(*(CmpMIItr->getParent()), JmpMIItr, MI.getDebugLoc(), TII->get(X86::MOV64ri), MI.getOperand(0).getReg());
		    MIBWipeLoad.addImm(0x0000000000000000);
		    MIBWipeLoad->SkipInTASE= true;

		    //Actually write into the stack guard slot.  Operand to access the guard slot might always be (%rsp), but in
		    //case it's not we grab the full memory operand form from the load instr.
		    int addrOffset = X86II::getMemoryOperandNo(NextMIItr->getDesc().TSFlags);// addrOffset is -1 if we failed to find the operand.
		    assert(addrOffset >= 0 && "TASE: Unable to determine instruction memory operand!");
		    addrOffset += X86II::getOperandBias(NextMIItr->getDesc());
		  
		    MachineInstrBuilder MIBWipeStore = BuildMI(*(CmpMIItr->getParent()), JmpMIItr, MI.getDebugLoc(), TII->get(X86::MOV64mr));
		  
		    for (int i = 0; i < X86::AddrNumOperands; i++) {
		      MIBWipeStore.addAndUse(NextMIItr->getOperand(addrOffset + i));
		    }
		    MIBWipeStore.addReg(MIBWipeLoad->getOperand(0).getReg());
		    MIBWipeStore->SkipInTASE = true;

		    //Wipe the reg that read the canary value from the stack
		    MachineInstrBuilder MIBWipeReg = BuildMI(*(CmpMIItr->getParent()), JmpMIItr, MI.getDebugLoc(), TII->get(X86::MOV64ri), NextMIItr->getOperand(0).getReg());
		    MIBWipeReg.addImm(0x0000000000000000);
		    MIBWipeReg->SkipInTASE = true;
		    
		    //Need to be careful with removing (rather than erasing/deleting) the FS load because we've copied its operands.
		    //MI.removeFromParent();
		  }	
		}
	      }
	    }
	  }
	}
      }
    }
  } //End TASE Stack guard logic---------------

  
  bool modified = false;
  for (MachineBasicBlock &MBB : MF) {
    LLVM_DEBUG(dbgs() << "TASE: Analyzing taint for block " << MBB);
    // Every cartridge entry sequence is going to flush the accumulators.
    Analysis.ResetDataOffsets();
    // In using this range, we use the super special property that a machine
    // instruction list obeys the iterator characteristics of list<
    // undocumented property that instr_iterator is not invalidated when
    // one inserts into the list.
    for (MachineInstr &MI : MBB.instrs()) {
      LLVM_DEBUG(dbgs() << "TASE: Analyzing taint for " << MI);
      if (MI.SkipInTASE) {
	continue;
      }

      if (Analysis.isSpecialInlineAsm(MI)) {
        continue;
      }
      if (MI.mayLoad() && MI.mayStore() && !(MI.getOpcode() == X86::VZEROALL || MI.getOpcode() == X86::VZEROUPPER) ) {
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
      if (MI.hasUnmodeledSideEffects() && !Analysis.isMemInstr(MI.getOpcode()) && !(MI.getOpcode() == X86::VZEROALL || MI.getOpcode() == X86::VZEROUPPER)) {
        errs() << "TASE: An instruction with potentially unwanted side-effects is emitted. " << MI;
        continue;
      }
      if ( !Analysis.isMemInstr(MI.getOpcode()) ) {
	  MI.dump();
      }
      //MI.print(outs());
      //outs()<<Analysis.isMemInstr(MI.getOpcode()) <<" " << MI.getOpcode() << "\n";      
      assert(Analysis.isMemInstr(MI.getOpcode()) || !(std::cerr << "TASE: Encountered an instruction we haven't handled: " << MI << std::endl));
      if(!Analysis.getUseSVF() || MI.getFlag(MachineInstr::MIFlag::tainted_inst_saratest)) {
	InstrumentInstruction(MI);
        modified = true;
      }
    }
  }
  return modified;
}

// Appends a poison check to load instructions and prepends a poison check to
// a store instructions. Expects to see only known instructions.
//
void X86TASECaptureTaintPass::InstrumentInstruction(MachineInstr &MI) {
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
    case X86::POP64r:
      // Fast path
      PoisonCheckReg(size, 8);
      break;
    case X86::RETQ:
      // We should not have a symbolic return address but we treat this as a
      // standard pop of the stack just in case.

      //If paranoid control flow is enabled, we've already inserted the check
      //for RET in an earlier pass.
      if (TASEParanoidControlFlow) {
	break;
      }
      
    case X86::POPF64:
      PoisonCheckStack(0);
      break;
    case X86::CALLpcrel16:
    case X86::CALL64pcrel32:
    case X86::CALL64r:
    case X86::CALL64r_NT:
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
      // Values are zero-extended during the push - so check the entire stack
      // slot for poison before the write.
      PoisonCheckStack(-size);
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
      
    case X86::VMOVUPSYmr: case X86::VMOVUPDYmr: case X86::VMOVDQUYmr:
    case X86::VMOVAPSYmr: case X86::VMOVAPDYmr: case X86::VMOVDQAYmr:

      
      PoisonCheckMem(size);
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

    case X86::VMOVUPSYrm: case X86::VMOVUPDYrm: case X86::VMOVDQUYrm:
    case X86::VMOVAPSYrm: case X86::VMOVAPDYrm: case X86::VMOVDQAYrm:
      PoisonCheckReg(size);
      break;
      
  }
  CurrentMI = nullptr;
}

MachineInstrBuilder X86TASECaptureTaintPass::InsertInstr(unsigned int opcode, bool before) {
  assert(CurrentMI && "TASE: Must only be called in the context of of instrumenting an instruction.");
  return Analysis.InsertInstr(CurrentMI, NextMII, TII, opcode, before);
}

MachineInstrBuilder X86TASECaptureTaintPass::InsertInstr(unsigned int opcode, unsigned int destReg, bool before) {
  assert(CurrentMI && "TASE: Must only be called in the context of of instrumenting an instruction.");
  return Analysis.InsertInstr(CurrentMI, NextMII, TII, opcode, destReg, before);
}

void X86TASECaptureTaintPass::PoisonCheckStack(int64_t stackOffset) {
  const size_t stackAlignment = 8;
  assert(stackOffset % stackAlignment == 0 && "TASE: Unaligned offset into the stack - must be multiple of 8");
  unsigned int acc_idx = AllocateOffset(stackAlignment, "PoisonCheckStack");

  assert(Analysis.getInstrumentationMode() == TIM_SIMD);
  //TODO: If AVX is enabled, switch to VPINSR or something else.
  
  InsertInstr(X86::PINSRQrm, TASE_REG_DATA)
    .addReg(TASE_REG_DATA)
    .addReg(X86::RSP)         // base
    .addImm(1)                // scale
    .addReg(X86::NoRegister)  // index
    .addImm(stackOffset)      // offset
    .addReg(X86::NoRegister)  // segment
    .addImm( acc_idx * bytesPerSlot / stackAlignment ) // QWORD-offset
    .cloneMemRefs(*CurrentMI);
}



void X86TASECaptureTaintPass::PoisonCheckMem(size_t size) {
  int addrOffset = X86II::getMemoryOperandNo(CurrentMI->getDesc().TSFlags);
  // addrOffset is -1 if we failed to find the operand.
  assert(addrOffset >= 0 && "TASE: Unable to determine instruction memory operand!");
  addrOffset += X86II::getOperandBias(CurrentMI->getDesc());

  SmallVector<MachineOperand,X86::AddrNumOperands> MOs;

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
  if (size >= 16) {
    assert(Analysis.getInstrumentationMode() == TIM_SIMD && "TASE: GPR poisoning not implemented for SIMD registers.");
    assert((size == 16 || (TaseYMM && size <= 32)) || !(std::cerr << "TASE: Unimplemented. Handle YMM/ZMM SIMD instructions properly. TaseYMM = " << (TaseYMM ? "1" : "0") << " size = " << size << std::endl));
    // TODO: Assert that the compiler only emits aligned XMM reads.
    MOs.append(CurrentMI->operands_begin() + addrOffset, CurrentMI->operands_begin() + addrOffset + X86::AddrNumOperands);
  } else {
    // Precalculate the address, align it to a two byte boundary and then
    // read double the size just to be safe.

    if( TaseAlign || size == 1 ) { // no single-byte checks...
      if (CurrentMI->memoperands_begin()  && CurrentMI->hasOneMemOperand() && size > 1) {
	llvm::MachineMemOperand* const mmo = *(CurrentMI->memoperands_begin());
	unsigned alignment = mmo->getAlignment();
	if ( (alignment % 2 ) != 1) {
	  CurrentMI->MustBeTASEAligned = true;
	}
      }

      if (!CurrentMI->MustBeTASEAligned) {
	size *= 2;
      }
    }
    // If this address operand is just a register, we can skip the lea. But don't do this if
    // EFLAGS is dead and we want to not emit shrx.

    bool eflags_dead = TII->isSafeToClobberEFLAGS(*CurrentMI->getParent(), MachineBasicBlock::iterator(CurrentMI));

    MachineInstrBuilder MIB = InsertInstr(X86::LEA64r, TASE_REG_TMP);
    for (int i = 0; i < X86::AddrNumOperands; i++) {
      MIB.addAndUse(CurrentMI->getOperand(addrOffset + i));
    }


    if ( TaseAlign ) {
      if (eflags_dead) {
	auto &tmpinst = InsertInstr(X86::SHR64r1, TASE_REG_TMP)
	  .addReg(TASE_REG_TMP);
	tmpinst->getOperand(2).setIsDead();
      } else {
	// Use TASE_REG_RET as a temporary register to hold offsets/indices.
	InsertInstr(X86::MOV32ri, getX86SubSuperRegister(TASE_REG_RET, 4 * 8))
	  .addImm(1);
	InsertInstr(X86::SHRX64rr, TASE_REG_TMP)
	  .addReg(TASE_REG_TMP)
	  .addReg(TASE_REG_RET);
      }
    
      MOs.push_back(MachineOperand::CreateReg(TASE_REG_TMP, false));     // base
      MOs.push_back(MachineOperand::CreateImm(1));                       // scale
      MOs.push_back(MachineOperand::CreateReg(TASE_REG_TMP, false));     // index
      MOs.push_back(MachineOperand::CreateImm(0));                       // offset
      MOs.push_back(MachineOperand::CreateReg(X86::NoRegister, false));  // segment
    } else {
      MOs.push_back( MachineOperand::CreateReg( TASE_REG_TMP, false ) );
      MOs.push_back( MachineOperand::CreateImm( 1 ) );
      MOs.push_back( MachineOperand::CreateReg( X86::NoRegister, false ) );
      MOs.push_back( MachineOperand::CreateImm( 0 ) );
      MOs.push_back( MachineOperand::CreateReg( X86::NoRegister, false ) );
    }
  }

  
  unsigned int acc_idx = AllocateOffset(size, "PoisonCheckMem");  
  MachineInstrBuilder MIBa;
  if ( TaseYMM ) {
    insertYMMElementMem(acc_idx, size, MIBa, MOs);
  } else {
    insertXMMElementMem(acc_idx, size, MIBa, MOs);
  }

  assert(MIBa.getInstr()->getDesc().Opcode != X86::RETQ || !(std::cerr << "TASE: MIBa opcode(" << (MIBa.getInstr()->getDesc().Opcode) << ") is X86::RETQ(" << X86::RETQ << "). Should be one of: ["
							     << cmpOPrm << ","
							     << X86::MOVSSrm << ","
							     << X86::MOVSDrm << ","
							     << X86::MOVHPSrm << ","
							     << TASE_PINSRrm[0] << ","
							     << TASE_PINSRrm[1] <<  ","
							     << TASE_PINSRrm[2] << ","
							     << TASE_PINSRrm[3] << "].\nacc_idx was " << acc_idx << ", size was " << size  << std::endl));
  
  for (unsigned int i = 0; i < MOs.size(); i++) {
    MIBa.addAndUse(MOs[i]);
  }

  if ( (TaseYMM && size == 32) || (!TaseYMM && size == 16) ) { // filled, OR into data and reset.
    InsertInstr(orOP, accreg)
      .addReg(accreg)
      .addReg(datareg);
    Analysis.ResetDataOffsets();
  }
}


// Mem -> GPR or XMM
// Optimized fast-path case where we can simply check the value from a destination register.
// Clobbers the bottom byte of the temporary register.
void X86TASECaptureTaintPass::PoisonCheckReg(size_t size, unsigned int align) {

  // TODO: Handle all stack accesses which we know are aligned.
  if (align >= 2) {
   // Partial register transfers from XMM are slow - just check the entire thing at once.
   if (Analysis.isXmmDestInstr(CurrentMI->getOpcode())) size = 16;
   if (Analysis.isYmmDestInstr(CurrentMI->getOpcode())) size = 32;
   
   unsigned int acc_idx = AllocateOffset(size, "PoisonCheckReg");
   PoisonCheckRegInternal(size, CurrentMI->getOperand(0).getReg(), acc_idx);
  } else {
    PoisonCheckMem(size);
  }
}


// X86::MOVDI2PDIrr  4byte int to XMM, MOVD
// X86::MOV64toPQIrr 8byte int to XMM, MOVQ
// TASE_PINSRrr[cLog2(size)] cLog2(size) int to XMM, PINSRB/W/D/Q
void X86TASECaptureTaintPass::PoisonCheckRegInternal(size_t size, unsigned int reg, unsigned int acc_idx) {
  assert(reg != X86::NoRegister);
  assert(Analysis.getInstrumentationMode() == TIM_SIMD);
  
  reg = getX86SubSuperRegister(reg, size * 8);    

  if (acc_idx == 0 && size == 4) {
    InsertInstr(X86::MOVDI2PDIrr, TASE_REG_DATA, false).addReg(reg);
 
  } else if (acc_idx == 0 && size == 8) {
    
    InsertInstr(X86::MOV64toPQIrr, TASE_REG_DATA, false).addReg(reg);
    
  } else {
    
    unsigned int start = acc_idx * bytesPerSlot/size;  // imm8 here is a word offset into the XMM register.
      
    if( DWordPoison && size == 2 ) {  // special case - promote to size 4 by loading twice. No second alloc needed - size promoted in AllocateDataOffset
      InsertInstr(TASE_PINSRrr[cLog2(size)], TASE_REG_DATA, false)
	.addReg(TASE_REG_DATA)
	.addReg(reg)
	.addImm(start);

      start += 1;
	
    }
      
    InsertInstr(TASE_PINSRrr[cLog2(size)], TASE_REG_DATA, false)
      .addReg(TASE_REG_DATA)
      .addReg(reg)
      .addImm(start);  // imm8 is the offset in terms of the size. QWORD -> QWORD offset \in [0,1], DWORD -> DWORD offset \in [0,1,2,3].
  }
}


unsigned int X86TASECaptureTaintPass::getAddrReg(unsigned Op) {
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


unsigned int X86TASECaptureTaintPass::AllocateOffset(size_t size, const std::string &str) {
  return Analysis.AllocateOffset(CurrentMI, NextMII, TII, cmpOPrr, orOP, datareg, accreg, referencereg, size, str);
}

INITIALIZE_PASS(X86TASECaptureTaintPass, PASS_KEY, PASS_DESC, false, false)

FunctionPass *llvm::createX86TASECaptureTaint() {
  return new X86TASECaptureTaintPass();
}
