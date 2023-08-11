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


extern bool tase_scout;

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

    MCCartridgeRecord *EmitSpringboard(const char *label, MachineBasicBlock &MBB, const bool taint_succ);
    MCCartridgeRecord *EmitSpringboard_scout(const char *label, MachineBasicBlock &MBB);
    MachineInstrBuilder InsertInstr(unsigned int opcode, unsigned int destReg = X86::NoRegister, MachineInstr *MI = nullptr);
    bool SearchTaintedSuccessors(const MachineBasicBlock * const succ, const int level, const int limit) const;//sara
    bool TaintedSuccessors(const MachineBasicBlock &MBB) const;//sara
    bool Tainted(const MachineBasicBlock &MBB) const;
    bool isSafeToClobberEFLAGS(const MachineBasicBlock &MBB, MachineBasicBlock::iterator I) const;
    bool isRaxLive(const MachineBasicBlock &MBB, MachineBasicBlock::const_iterator I) const;
  };

} // end anonymous namespace


char X86TASEAddCartridgeSpringboardPass::ID = 0;


bool X86TASEAddCartridgeSpringboardPass::isSafeToClobberEFLAGS( const MachineBasicBlock &MBB, MachineBasicBlock::iterator I ) const {
  return MBB.computeRegisterLiveness(&TII->getRegisterInfo(), X86::EFLAGS, I, 40) == MachineBasicBlock::LQR_Dead;
}


bool X86TASEAddCartridgeSpringboardPass::isRaxLive( const MachineBasicBlock &MBB, MachineBasicBlock::const_iterator Before ) const {
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


MachineInstrBuilder X86TASEAddCartridgeSpringboardPass::InsertInstr(unsigned int opcode, unsigned int destReg, MachineInstr *MI) {
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


//iterate through the succesors and return true if any tainted bb was found.
bool X86TASEAddCartridgeSpringboardPass::TaintedSuccessors( const MachineBasicBlock &MBB) const {
  for ( const MachineBasicBlock * const MBBSucc : MBB.successors() ){
    if ( MBBSucc->getTaint_sara() )
      return true;
  }
}


//iterate through the succesors to verify if any is tainted.
//// return 1 if tainted bb is found
//// return 0 if no tainted bbs in path is found
bool X86TASEAddCartridgeSpringboardPass::SearchTaintedSuccessors(const MachineBasicBlock * const succ, const int level, const int limit) const {
  //Confirm that none of the upcoming bbs are tainted  
  if ( TaintedSuccessors( *succ ) )
    return true;

  //if we hit the next to last chosen level to search, then we can exit.
  //since we already confirmed the upcoming bbs are not tainted, and we hit the nodes
  //there is nothing more to do
  if ( (level+1) != limit ) {
    for ( MachineBasicBlock *next_succ : succ->successors() ){
      //iterate through the successors, already knowing none are tainted, to verify
      //if they have any tainted successors.
      if ( SearchTaintedSuccessors( next_succ, level+1, limit ) )
	return true;
    }
  }

  return false;
}


bool X86TASEAddCartridgeSpringboardPass::Tainted(const MachineBasicBlock &MBB) const {
  //if tainted flag is not set, then we want normal execution
  // thus, we will instrument every instr addressing memory
  //   if files have not been analyzed as tainted, do not run transaction delay
  //   keep it as og where TSX is set for every 16BB
  if ( !Analysis.getUseTaintsara() || !Analysis.getUseDelayTran() || MBB.getTaint_sara() || TaintedSuccessors( MBB ) )
    return true;

  //iterate through the successors of the main BB succesors until taint is found
  //  path= refers to the depth of the search
  //  level= refers to the level we are currently in
  for ( MachineBasicBlock *MBBSucc : MBB.successors() ){
    if ( SearchTaintedSuccessors(MBBSucc, 0, 2) ){
      return true;
    }
  } 

  return false;
}


MCCartridgeRecord *X86TASEAddCartridgeSpringboardPass::EmitSpringboard(const char *label, MachineBasicBlock &MBB, const bool taint_succ) {
  // We run after cartridge splitting - this guarantees that each machine block
  // has at least one instruction.  It also guarantees that every basic block
  // is a cartridge.  So just add the BB to our record along with a label
  // attached to the first instruction in the block.
  MachineFunction *MF = MBB.getParent();
  MCCartridgeRecord *cartridge = MF->getContext().createCartridgeRecord(MBB.getSymbol(), MF->getName());

  bool eflags_dead = isSafeToClobberEFLAGS( *FirstMI->getParent(), MachineBasicBlock::iterator( FirstMI ) );
  cartridge->flags_live = !eflags_dead;

  InsertInstr(X86::LEA64r, TASE_REG_RET)
    .addReg(X86::RIP)           // base - attempt to use the locality of cartridgeBody.
    .addImm(1)                  // scale
    .addReg(X86::NoRegister)    // index
    .addSym(cartridge->Body())  // offset
    .addReg(X86::NoRegister);   // segment

  bool rax_live = isRaxLive( MBB, MachineBasicBlock::iterator(FirstMI) );
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
      .addImm( (uint64_t) taint_succ );

    InsertInstr(X86::TASE_JMP_4)
      .addExternalSymbol( label );

  } else {
    
    if (rax_live) {
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
	.addImm( 0 );
    }

    InsertInstr( eflags_dead ? X86::NOOP : X86::LAHF );

    InsertInstr(X86::CMP8mi)
      .addReg( X86::RIP )  // base
      .addImm( 1 ) // scale
      .addReg( X86::NoRegister ) // index
      .addExternalSymbol( "tran_taint" ) //offset
      .addReg( X86::NoRegister ) // segment
      .addImm( 1 ); 

    if ( std::string(label) == "sb_modeled" ){
      if( !TASESharedMode ){
	InsertInstr(X86::TASE_JNE)
	  .addExternalSymbol("sb_modeled_open");
	InsertInstr(X86::TASE_JMP_4)
	  .addExternalSymbol("sb_modeled_closed");
      } else {
	InsertInstr(X86::TASE_JNE)
	  .addExternalSymbol("sb_modeled_open",  X86II::MO_PLT);
	InsertInstr(X86::TASE_JMP_4)
	  .addExternalSymbol("sb_modeled_closed", X86II::MO_PLT);
      }

    } else {
      if ( taint_succ ){
	if( !TASESharedMode ){
	  InsertInstr(X86::TASE_JNE)
	    .addExternalSymbol("sb_keepopen");
	  InsertInstr(X86::TASE_JMP_4)
	    .addExternalSymbol("sb_opentran");
	} else {
	  InsertInstr(X86::TASE_JNE)
	    .addExternalSymbol("sb_keepopen", X86II::MO_PLT);
	  InsertInstr(X86::TASE_JMP_4)
	    .addExternalSymbol("sb_opentran", X86II::MO_PLT);
	}

      } else {
	if(!TASESharedMode){
	  InsertInstr(X86::TASE_JNE)
	    .addExternalSymbol("sb_closetran");
	  InsertInstr(X86::TASE_JMP_4)
	    .addExternalSymbol("sb_keepclosed");
	} else {
	  InsertInstr(X86::TASE_JNE)
	    .addExternalSymbol("sb_closetran", X86II::MO_PLT);
	  InsertInstr(X86::TASE_JMP_4)
	    .addExternalSymbol("sb_keepclosed", X86II::MO_PLT);
	}
      }
    }
  }    

  FirstMI->setPreInstrSymbol(*MF, cartridge->Body());
  MBB.front().setPreInstrSymbol(*MF, cartridge->Cartridge());

  //Try to grab the first terminator

  bool foundTerm = false;
  for (auto MII = MBB.instr_begin(); MII != MBB.instr_end(); MII++) {
    if (MII->isTerminator()) {
      MII->setPostInstrSymbol(*MF, cartridge->End());
      foundTerm = true;
      break;
    }  
  }

  if (!foundTerm) 
    MBB.back().setPostInstrSymbol(*MF, cartridge->End());
  return cartridge;
}


MCCartridgeRecord *X86TASEAddCartridgeSpringboardPass::EmitSpringboard_scout(const char *label, MachineBasicBlock &MBB) {
  // We run after cartridge splitting - this guarantees that each machine block
  // has at least one instruction.  It also guarantees that every basic block
  // is a cartridge.  So just add the BB to our record along with a label
  // attached to the first instruction in the block.
  MachineFunction *MF = MBB.getParent();
  MCCartridgeRecord *cartridge = MF->getContext().createCartridgeRecord(MBB.getSymbol(), MF->getName());

    //We've added a bool field to MCCartridgeRecord called "flags_live".  Use it!
  bool eflags_dead = TII->isSafeToClobberEFLAGS(MBB, MachineBasicBlock::iterator(FirstMI));  
  cartridge->flags_live = !eflags_dead;
  
  InsertInstr(X86::LEA64r, TASE_REG_RET)
    .addReg(X86::RIP)           // base - attempt to use the locality of cartridgeBody.
    .addImm(1)                  // scale
    .addReg(X86::NoRegister)    // index
    .addSym(cartridge->Body())  // offset
    .addReg(X86::NoRegister);   // segment

  //Directly jump to label.  Note that we use a special
  //TASE jmp symbol in X86InstrControl.td because it is defined as a jump
  //but NOT a branch/terminator.  This makes our calculations for cartridge
  //offsets easier later on in X86AsmPrinter.cpp
  if(!TASESharedMode){
    auto &tmpinst = InsertInstr(X86::TASE_JMP_4)
      .addExternalSymbol(label);
  } else {
    auto &tmpinst = InsertInstr(X86::TASE_JMP_4)
    .addExternalSymbol(label, X86II::MO_PLT);
  }

  FirstMI->setPreInstrSymbol(*MF, cartridge->Body());
  //cartridgeBodyPDMI->setPreInstrSymbol(*MF, cartridge->BodyPostDebug());

  MBB.front().setPreInstrSymbol(*MF, cartridge->Cartridge());

  //Try to grab the first terminator

  bool foundTerm = false;
  for (auto MII = MBB.instr_begin(); MII != MBB.instr_end(); MII++) {
    if (MII->isTerminator()) {
      MII->setPostInstrSymbol(*MF, cartridge->End());
      foundTerm = true;
      break;
    }  
  }
  
  if (!foundTerm) 
    MBB.back().setPostInstrSymbol(*MF, cartridge->End());
  return cartridge;
}


bool X86TASEAddCartridgeSpringboardPass::runOnMachineFunction(MachineFunction &MF) {
  LLVM_DEBUG(dbgs() << "********** " << getPassName() << " : " << MF.getName()
	     << " **********\n");
  if ( Analysis.getInstrumentationMode() == TIM_NONE ) {
    return false;
  }
  
  //setting basic blocks as tainted or not based on their tainted instructions
  bool moduleIsTainted = 0;
  for ( MachineBasicBlock &MBB : MF ) {
    for ( MachineInstr &MI : MBB ) {
      if ( MI.getFlag( MachineInstr::MIFlag::tainted_inst_saratest ) ) {
	MBB.setTaint_sara(1);
	moduleIsTainted = 1;
	break;
      }
    }
  }
  
  //  if (!Analysis.getUseDelayTran()){
  moduleIsTainted = 1;
    //  }

  Subtarget = &MF.getSubtarget<X86Subtarget>();
  TII = Subtarget->getInstrInfo();

  if ( Analysis.isModeledFunction(MF.getName()) ) {
    LLVM_DEBUG(dbgs() << "TASE: Adding prolog to modeled function.\n");

    //Add model trap to top of modeled functions
    for ( MachineBasicBlock &MBB : MF ) {
      FirstMI = &MBB.front();
      bool tainted = Tainted( MBB );

      if ( FirstMI == &MF.front().front() )
	if( tase_scout ) {
	  EmitSpringboard_scout( "sb_modeled", MBB );
	} else {
	  EmitSpringboard( "sb_modeled", MBB, tainted );
	}
      else {
	if ( tase_scout ) {
	  if ( tainted ) 
	    EmitSpringboard_scout( "sb_reopen", MBB );
	} else {
	  EmitSpringboard( moduleIsTainted ? "sb_reopen" : "sb_elide", MBB, tainted );
	}
      }
    }
    
  } else {
    for (MachineBasicBlock &MBB : MF) {
      FirstMI = &MBB.front();
      bool tainted = Tainted( MBB );
      if( tase_scout ) {
	if ( tainted )
	  EmitSpringboard_scout( "sb_reopen", MBB );
      } else {
	EmitSpringboard( moduleIsTainted ? "sb_reopen" : "sb_elide", MBB, tainted );
      }
    }
  }
  FirstMI = nullptr;

  return true;
}

INITIALIZE_PASS(X86TASEAddCartridgeSpringboardPass, PASS_KEY, PASS_DESC, false, false)

FunctionPass *llvm::createX86TASEAddCartridgeSpringboard() {
  return new X86TASEAddCartridgeSpringboardPass();
}
