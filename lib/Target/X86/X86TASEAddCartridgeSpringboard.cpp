// Add TASE springboard prolog to each cartridge.
// Modeled functions get a special "always eject" header for the first cartridge
// with no other processing being performed.
// Regular instrumented functions have each of their cartridges instrumented.


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
#include "llvm/MC/MCCartridgeRecord.h"
#include "llvm/MC/MCContext.h"
#include "llvm/Pass.h"
#include "llvm/Support/Debug.h"
#include <algorithm>
#include <cassert>

using namespace llvm;

#define PASS_KEY "x86-tase-add-cartridge-springboard"
#define PASS_DESC "X86 TASE cartridge prolog addition pass."
#define DEBUG_TYPE PASS_KEY

bool TASESharedMode;
static cl::opt<bool, true> TASESharedModeFlag(
					"tase-shared",
					cl::desc("shared object mode for tase"),
					cl::location(TASESharedMode),
					cl::init(false));



namespace llvm {

void initializeX86TASEAddCartridgeSpringboardPassPass(PassRegistry &);
}

namespace {

class X86TASEAddCartridgeSpringboardPass : public MachineFunctionPass {
public:
  X86TASEAddCartridgeSpringboardPass() : MachineFunctionPass(ID),
    FirstMI(nullptr) {
    initializeX86TASEAddCartridgeSpringboardPassPass(
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
  const X86InstrInfo *TII;
  MachineInstr *FirstMI;

  TASEAnalysis Analysis;

  MCCartridgeRecord *EmitSpringboard(const char *label);
  MachineInstrBuilder InsertInstr(
      unsigned int opcode, unsigned int destReg = X86::NoRegister, MachineInstr *MI = nullptr);
  bool VerifySuccessors(MachineBasicBlock *succ, int level, int limit);//sara
  bool VerifyTaintedSuccessors(MachineBasicBlock *MBB);//sara
  bool isSafeToClobberEFLAGS(MachineBasicBlock &MBB, MachineBasicBlock::iterator I) const;
  bool isRaxLive(MachineBasicBlock &MBB, MachineBasicBlock::const_iterator I) const;
};

} // end anonymous namespace


char X86TASEAddCartridgeSpringboardPass::ID = 0;

bool X86TASEAddCartridgeSpringboardPass::isSafeToClobberEFLAGS( MachineBasicBlock &MBB, MachineBasicBlock::iterator I ) const {
	  return MBB.computeRegisterLiveness(&TII->getRegisterInfo(), X86::EFLAGS, I, 40) == MachineBasicBlock::LQR_Dead;
}
bool X86TASEAddCartridgeSpringboardPass::isRaxLive( MachineBasicBlock &MBB, MachineBasicBlock::const_iterator Before ) const {
  auto TRI = &TII->getRegisterInfo();
  unsigned Reg = X86::RAX;
  unsigned N = 40;
  // Try searching forwards from Before, looking for reads or defs.
  MachineBasicBlock::const_iterator I(Before);
  for (; I != MBB.end() && N > 0; ++I) {
    if (I->isDebugInstr())
      continue;
    --N;
    MachineOperandIteratorBase::PhysRegInfo Info = ConstMIOperands(*I).analyzePhysReg(Reg, TRI);
    // Register is live when we read it here.
    if (Info.Read)
      return true;
    // Register is dead if we can fully overwrite or clobber it here.
    // if (Info.FullyDefined || Info.Clobbered)
    if (Info.Defined || Info.Clobbered)
       return false;
  }
   // If we reached the end, it is safe to clobber Reg at the end of a block of
   //   // no successor has it live in.
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
      MachineOperandIteratorBase::PhysRegInfo Info = ConstMIOperands(*I).analyzePhysReg(Reg, TRI);
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
      // Register must be live if we read it
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

MachineInstrBuilder X86TASEAddCartridgeSpringboardPass::InsertInstr(
    unsigned int opcode, unsigned int destReg, MachineInstr *MI) {
  if (MI == nullptr) {
    MI = FirstMI;
  }
  assert(MI && "TASE: Unable to determine the instruction insertion location.");
  if (destReg == X86::NoRegister) {
    return BuildMI(*MI->getParent(), MI, MI->getDebugLoc(), TII->get(opcode));
  } else {
    return BuildMI(*MI->getParent(), MI, MI->getDebugLoc(), TII->get(opcode), destReg);
  }
}

//iterate through the succesors and return 1 if any tainted bb was found.
bool X86TASEAddCartridgeSpringboardPass::VerifyTaintedSuccessors( MachineBasicBlock *MBB){
    for ( MachineBasicBlock *MBBSucc : MBB->successors() ) {
	if ( MBBSucc->getTaint_sara() )
		return 1;
    }
}



//iterate through the succesors to verify if any is tainted.
//// return 1 if tainted bb is found
//// return 0 if no tainted bbs in path is found
bool X86TASEAddCartridgeSpringboardPass::VerifySuccessors(MachineBasicBlock *succ, int level, int limit){
    //Confirm that none of the upcoming bbs are tainted
  if ( VerifyTaintedSuccessors(succ) )
    return 1;		      

  //if we hit the next to last chosen level to search, then we can exit.
  //since we already confirmed the upcoming bbs are not tainted, and we hit the nodes
  //there is nothing more to do
  if ( (level+1) != limit ) {
    for ( MachineBasicBlock *next_succ : succ->successors() ) {
      //iterate through the successors, already knowing none are tainted, to verify
      //if they have any tainted successors.
      if ( VerifySuccessors(next_succ, level+1, limit) )
	return 1;
    }
  }

  return 0;
}



MCCartridgeRecord *X86TASEAddCartridgeSpringboardPass::EmitSpringboard(const char *label) {
  // We run after cartridge splitting - this guarantees that each machine block
  // has at least one instruction.  It also guarantees that every basic block
  // is a cartridge.  So just add the BB to our record along with a label
  // attached to the first instruction in the block.
  MachineBasicBlock *MBB = FirstMI->getParent();
  MachineFunction *MF = MBB->getParent();
  MCCartridgeRecord *cartridge = MF->getContext().createCartridgeRecord(MBB->getSymbol(), MF->getName());

  uint64_t taint_succ = 0;
  int limit = 2;
  int level = 0;
	  
  //if tainted flag is not set, then we want normal execution
  // thus, we will instrument every instr addressing memory
  //   //if files have not been analyzed as tainted, do not run transaction delay
  //     //keep it as og where TSX is set for every 16BB
  if (!Analysis.getUseTaintsara() || !Analysis.getUseDelayTran() || MBB->getTaint_sara() || VerifyTaintedSuccessors(MBB) ){
    taint_succ = 1; 

  //iterate through the successors of the main BB succesors until taint is found
  ////path= refers to the depth of the search
  ////level= refers to the level we are currently in
  } else {
    for ( MachineBasicBlock *MBBSucc : MBB->successors() ) {
      if ( VerifySuccessors(MBBSucc, level, limit) ) {
        taint_succ = 1; 
	break;
      }
    } 
  }
  //Set current basic block as tainted, meaning keep transaction open
  
  //We've added a bool field to MCCartridgeRecord called "flags_live".  Use it!
  //bool eflags_dead = TII->isSafeToClobberEFLAGS(*MBB, MachineBasicBlock::iterator(FirstMI));  
   bool eflags_dead = isSafeToClobberEFLAGS( *FirstMI->getParent(), MachineBasicBlock::iterator( FirstMI ) );
  cartridge->flags_live = !eflags_dead;
  
  InsertInstr(X86::LEA64r, TASE_REG_RET)
    .addReg(X86::RIP)           // base - attempt to use the locality of cartridgeBody.
    .addImm(1)                  // scale
    .addReg(X86::NoRegister)    // index
    .addSym(cartridge->Body())  // offset
    .addReg(X86::NoRegister);   // segment
  
  bool rax_live = isRaxLive( *MBB, MachineBasicBlock::iterator(FirstMI));
  //Directly jump to label.  Note that we use a special
  //TASE jmp symbol in X86InstrControl.td because it is defined as a jump
  //but NOT a branch/terminator.  This makes our calculations for cartridge
  //offsets easier later on in X86AsmPrinter.cpp
  
  if ( Analysis.getUseTestSara() ){
    
    InsertInstr( X86::MOV8mi )
      .addReg( X86::RIP )  // base
      .addImm( 1 ) // scale
      .addReg( X86::NoRegister ) // index
      .addExternalSymbol( "tran_taint" ) //offset
      .addReg( X86::NoRegister ) // segment
      .addImm(taint_succ);

    InsertInstr(X86::TASE_JMP_4)
      .addExternalSymbol(label);
    
  } else {
    
    if ( rax_live ) {
      InsertInstr( X86::MOV64mr )
        .addReg( X86::RIP ) // base
        .addImm( 1 )  // scale
        .addReg( X86::NoRegister ) // index
        .addExternalSymbol( "saved_rax" ) // offset
        .addReg( X86::NoRegister ) // segment
        .addReg( X86::RAX ); // src
    } else {
      InsertInstr( X86::MOV8mi )
	.addReg( X86::RIP )  // base
	.addImm( 1 ) // scale
	.addReg( X86::NoRegister ) // index
	.addExternalSymbol( "tran_temp" ) //offset
	.addReg( X86::NoRegister ) // segment
	.addImm(0);
    }

    InsertInstr( eflags_dead ? X86::NOOP : X86::LAHF );
  
    InsertInstr( X86::CMP8mi )
      .addReg( X86::RIP )  // base
      .addImm( 1 ) // scale
      .addReg( X86::NoRegister ) // index
      .addExternalSymbol( "tran_taint" ) //offset
      .addReg( X86::NoRegister ) // segment
      .addImm(1);

    std::string sym1, sym2;  

    if ( label == "sb_modeled" ) {
      sym1 = "sb_modeled_open";
      sym2 = "sb_modeled_closed";
    } else if ( taint_succ ) {
      sym1 = "sb_keepopen";
      sym2 = "sb_opentran";
    } else {
      sym1 = "sb_closetran";
      sym2 = "sb_keepclosed";
    }

    if ( TASESharedMode ) {
      InsertInstr( X86::TASE_JNE )
	.addExternalSymbol( sym1.c_str() );
      
      InsertInstr( X86::TASE_JMP_4 )
	.addExternalSymbol( sym2.c_str() );
    } else {
      InsertInstr( X86::TASE_JNE )
	.addExternalSymbol( sym1.c_str(), X86II::MO_PLT );
      
      InsertInstr( X86::TASE_JMP_4 )
	.addExternalSymbol( sym2.c_str(), X86II::MO_PLT );
    }
  }    
  
  //MachineInstr *cartridgeBodyPDMI = &firstMI;
  // DEBUG: Assert that we are in an RTM transaction to check springboard behavior.
  //MachineInstr *cartridgeBodyMI =
  //  BuildMI(*MBB, cartridgeBodyPDMI, cartridgeBodyPDMI->getDebugLoc(), TII->get(X86::XTEST));
  //BuildMI(*MBB, cartridgeBodyPDMI, cartridgeBodyPDMI->getDebugLoc(), TII->get(X86::JE_1))
  //  .addSym(cartridge->BodyPostDebug());
  //BuildMI(*MBB, cartridgeBodyPDMI, cartridgeBodyPDMI->getDebugLoc(), TII->get(X86::MOV64rm))
  //  .addReg(X86::RAX)
  //  .addReg(X86::NoRegister)  // base
  //  .addImm(1)                // scale
  //  .addReg(X86::NoRegister)  // index
  //  .addImm(0)                // offset
  //  .addReg(X86::NoRegister); // segment

  FirstMI->setPreInstrSymbol(*MF, cartridge->Body());
  //cartridgeBodyPDMI->setPreInstrSymbol(*MF, cartridge->BodyPostDebug());

  MBB->front().setPreInstrSymbol(*MF, cartridge->Cartridge());

  //Try to grab the first terminator

  bool foundTerm = false;
  for (auto MII = MBB->instr_begin(); MII != MBB->instr_end(); MII++) {
    if (MII->isTerminator()) {
      MII->setPostInstrSymbol(*MF, cartridge->End());
      foundTerm = true;
      break;
    }  
  }
  
  if (!foundTerm) 
    MBB->back().setPostInstrSymbol(*MF, cartridge->End());
  return cartridge;
}


bool X86TASEAddCartridgeSpringboardPass::runOnMachineFunction(MachineFunction &MF) {
  LLVM_DEBUG(dbgs() << "********** " << getPassName() << " : " << MF.getName()
                    << " **********\n");
  if (Analysis.getInstrumentationMode() == TIM_NONE) {
    return false;
  }
  //setting basic blocks as tainted or not based on their tainted instructions
  bool moduleIsTainted = 0;
  for ( MachineBasicBlock &MBB : MF ) {
    for (MachineInstr &MI : MBB) {
      if ( MI.getFlag( MachineInstr::MIFlag::tainted_inst_saratest ) ) {
	MBB.setTaint_sara(1);
	moduleIsTainted = 1;
	break;
      }
    }
  }
  if (1){ //!Analysis.getUseDelayTran()){
	  moduleIsTainted = 1;
  }

  Subtarget = &MF.getSubtarget<X86Subtarget>();
  TII = Subtarget->getInstrInfo();

  if (Analysis.isModeledFunction(MF.getName())) {
    LLVM_DEBUG(dbgs() << "TASE: Adding prolog to modeled function.\n");
    
    //Add model trap to top of modeled functions
    for (MachineBasicBlock &MBB : MF) {
      FirstMI = &MBB.front();
      if (FirstMI == &MF.front().front())
	EmitSpringboard("sb_modeled");
      else {
	if ( moduleIsTainted )
	  EmitSpringboard("sb_reopen");
	else	
 	  EmitSpringboard("sb_elide");
      }

    }

  } else {
    for (MachineBasicBlock &MBB : MF) {
      FirstMI = &MBB.front();
      if ( moduleIsTainted )
	 EmitSpringboard("sb_reopen");
      else
	 EmitSpringboard("sb_elide");
    }
  }
  FirstMI = nullptr;

  return true;
}

INITIALIZE_PASS(X86TASEAddCartridgeSpringboardPass, PASS_KEY, PASS_DESC, false, false)

FunctionPass *llvm::createX86TASEAddCartridgeSpringboard() {
  return new X86TASEAddCartridgeSpringboardPass();
}
