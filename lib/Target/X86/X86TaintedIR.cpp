#include "X86.h"
#include "X86InstrInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"


using namespace llvm;

#define X86_TAINTED_IR_PASS_NAME "Dummy X86 reading tainted IR pass"

namespace {
class X86TaintedIR : public MachineFunctionPass {
	public:		
		static char ID;
		X86TaintedIR() : MachineFunctionPass(ID) {
			initializeX86TaintedIRPass(*PassRegistry::getPassRegistry());
		}
		bool runOnMachineFunction(MachineFunction &MF) override;
		StringRef getPassName() const override { return X86_TAINTED_IR_PASS_NAME; }
};

char X86TaintedIR::ID = 0;
bool X86TaintedIR::runOnMachineFunction(MachineFunction &MF) {
	const Function &Func = MF.getFunction();
	Function &Fn = const_cast<Function &>(Func);
	for (BasicBlock &BB : Fn) {
		for (Instruction &Inst : BB)
		{
			if (Inst.getMetadata("tainted"))
			{
				Inst.setTainted(1);
				printf("tainted\n");
			}
		}

	}
	return false;
}

} // end of anonymous namespace

INITIALIZE_PASS(X86TaintedIR, "x86-tainted-ir",
		X86_TAINTED_IR_PASS_NAME,
		true, // is CFG only?
		true  // is analysis?
)

namespace llvm {

FunctionPass *createX86TaintedIRPass() { return new X86TaintedIR(); }

}

