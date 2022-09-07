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

MCCartridgeRecord *X86TASEAddCartridgeSpringboardPass::EmitSpringboard(const char *label) {
  // We run after cartridge splitting - this guarantees that each machine block
  // has at least one instruction.  It also guarantees that every basic block
  // is a cartridge.  So just add the BB to our record along with a label
  // attached to the first instruction in the block.
  MachineBasicBlock *MBB = FirstMI->getParent();
  MachineFunction *MF = MBB->getParent();
  MCCartridgeRecord *cartridge = MF->getContext().createCartridgeRecord(MBB->getSymbol(), MF->getName());


  
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
  if(!TASESharedMode){
    InsertInstr(X86::TASE_JMP_4)
      .addExternalSymbol(label);
  } else {
    InsertInstr(X86::TASE_JMP_4)
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
