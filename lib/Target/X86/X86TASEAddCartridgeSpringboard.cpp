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
  bool VerifyTaintedSuccessors(MachineBasicBlock *MBB);//sa
};

} // end anonymous namespace


char X86TASEAddCartridgeSpringboardPass::ID = 0;

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
    for (MachineBasicBlock *MBBSucc : MBB->successors()){
	if (MBBSucc->getTaint_sara() )
		return 1;
    }
}


//iterate through the succesors to verify if any is tainted.
//// return 1 if tainted bb is found
//// return 0 if no tainted bbs in path is found
bool X86TASEAddCartridgeSpringboardPass::VerifySuccessors(MachineBasicBlock *succ, int level, int limit){
    //Confirm that none of the upcoming bbs are tainted
    if (VerifyTaintedSuccessors(succ))
      return 1;		      
    else {
      //if we hit the next to last chosen level to search, then we can exit.
      //since we already confirmed the upcoming bbs are not tainted, and we hit the nodes
      //there is nothing more to do
      if ((level+1)!=limit){
        for (MachineBasicBlock *next_succ : succ->successors()){
	  //iterate through the successors, already knowing none are tainted, to verify
	  //if they have any tainted successors.
	  if (VerifySuccessors(next_succ,level+1,limit))
	    return 1;
	}
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
  if (!Analysis.getUseTaintsara() || !Analysis.getUseDelayTran()){
    taint_succ = 1;
  }
  else if (MBB->getTaint_sara()){
	  taint_succ = 1;
  }
  //if main BB successors are found to be tainted, set injection variable 
  //// succ_taint flag and finish
  else if (VerifyTaintedSuccessors(MBB)){
    taint_succ = 1; 
  }
  //iterate through the successors of the main BB succesors until taint is found
  ////path= refers to the depth of the search
  ////level= refers to the level we are currently in
  else {
    for (MachineBasicBlock *MBBSucc : MBB->successors()){
      if (VerifySuccessors(MBBSucc, level,limit)){
        taint_succ = 1; 
	break;
      }
    } 
  }
  //Set current basic block as tainted, meaning keep transaction open
  
  //We've added a bool field to MCCartridgeRecord called "flags_live".  Use it!
  bool eflags_dead = TII->isSafeToClobberEFLAGS(*MBB, MachineBasicBlock::iterator(FirstMI));  
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
  
  
  InsertInstr( X86::MOV8mi )
	  .addReg( X86::RIP )  // base
	  .addImm( 1 ) // scale     
	  .addReg( X86::NoRegister ) // index  
 	  .addExternalSymbol( "tran_taint" ) //offset
	  .addReg( X86::NoRegister ) // segment
 	  .addImm(taint_succ) ;

 /*InsertInstr(X86::MOV64ri32, TASE_REG_TMP)
  	  .addImm(taint_succ);*/

  if(!TASESharedMode){
    auto &tmpinst = InsertInstr(X86::TASE_JMP_4)
      .addExternalSymbol(label);
  } else {
    auto &tmpinst = InsertInstr(X86::TASE_JMP_4)
    .addExternalSymbol(label, X86II::MO_PLT);
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
  for (MachineBasicBlock &MBB : MF) {
    for (MachineInstr &MI : MBB) {
      if (MI.getFlag(MachineInstr::MIFlag::tainted_inst_saratest)) {
	      MBB.setTaint_sara(1);
	      break;
      }
    }
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
      else 
	EmitSpringboard("sb_reopen");

    }

  } else {
    for (MachineBasicBlock &MBB : MF) {
      FirstMI = &MBB.front();
      EmitSpringboard("sb_reopen");
    }
  }
  FirstMI = nullptr;

  return true;
}

INITIALIZE_PASS(X86TASEAddCartridgeSpringboardPass, PASS_KEY, PASS_DESC, false, false)

FunctionPass *llvm::createX86TASEAddCartridgeSpringboard() {
  return new X86TASEAddCartridgeSpringboardPass();
}
