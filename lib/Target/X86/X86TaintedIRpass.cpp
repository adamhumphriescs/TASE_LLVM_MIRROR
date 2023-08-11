#include "X86.h"
#include "X86InstrInfo.h"
#include "X86TASE.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/GlobalVariable.h"
#include "llvm/Transforms/Utils/Cloning.h"
#include <fstream>
#include <vector> 
#include <string>
#include <type_traits>

using namespace llvm;
using namespace std;
using ValueToValueMapTy = ValueMap<const Value *, WeakTrackingVH>;

#define X86_TAINTED_IR_PASS_NAME "Dummy X86 reading tainted IR pass"

namespace {

class X86TaintedIR : public ModulePass {
    TASEAnalysis Analysis;
public:
    static char ID;

    X86TaintedIR() : ModulePass(ID) {
        initializeX86TaintedIRPass(*PassRegistry::getPassRegistry());
    }

    bool runOnModule(Module &M) override;

    StringRef getPassName() const override { return X86_TAINTED_IR_PASS_NAME; }
    void manualSVF(Module &M);
    void checkLibc (Instruction &Inst, std::vector<StringRef> functionNames, Module &M);
};

char X86TaintedIR::ID = 0;

void X86TaintedIR::checkLibc (Instruction &Inst, std::vector<StringRef> functionNames, Module &M){
	outs()<<"Inside the check of funs "<< Inst << "\n";
	if (isa<CallInst>(&Inst)) {
	    CallInst* cs;
	    cs = dyn_cast<CallInst>(&Inst);
	    Function *fun = cs->getCalledFunction();
	    if (fun ){
		StringRef funName = fun->getName();
		if (funName.find("_sara") == std::string::npos){
		  for(auto it = functionNames.begin(); it != functionNames.end(); ++it){
			StringRef tok = funName.substr(0, funName.find("_tase"));
			if (*it == tok){
			outs()<<"(changing name: "<< funName << "\n";
			std::string funSara = tok.str();
			funSara += StringRef("_sara");
			outs()<< "Function Name "<< funSara <<  "\n";
			//fun->setName (funSara);
			Function* FN =  cast<Function>(M.getOrInsertFunction (funSara, fun->getFunctionType()));
			//FN->setName(StringRef(funSara));
			outs()<<"Calling setCalledFunction\n";
			fflush(stdout);
			cs->setCalledFunction(FN); 
			outs() << "calling setName\n";
			fflush(stdout);
			//fun->setName (funName);
			}
		  }
		}
	    }
	} 
}

void X86TaintedIR::manualSVF(Module &M) {
	outs()<<"inside manual, opening file\n";
	std::vector<StringRef> functionNames {"sprintf","printf","fprintf","vasprintf","vsnprintf","puts","fwrite","write","putchar","isatty","fflush","fopen","a_ctz_64","a_clz_64","calloc","realloc","malloc","free","getc_unlocked","memcpy","fileno","fread","fread_unlocked","ferror","feof","fclose","exit","fseek","ftell","rewind","posix_fadvise", "freopen"};
	//TODO: add a check here that runs iteration if flag is set
	for (Function &F : M.functions()) {
	    for (BasicBlock &BB : F) {
		for (Instruction &Inst : BB){
		    if (Inst.getMetadata("tainted")) {
			//checkLibc(Inst, functionNames,M);
			Inst.setTainted(1);
			outs()<<"TAINTING INSTRUCTION \n";	
		    }		
		}
	    }
	}
	outs()<<"SVF Taint is set to: "<<Analysis.getUseTaintsara()<<"\n";
}

bool X86TaintedIR::runOnModule(Module &M) {
    if (Analysis.getUseTaintsara())
      	manualSVF(M);
    return false;
}

} // end of anonymous namespace



INITIALIZE_PASS(X86TaintedIR, "x86-tainted-ir",
    X86_TAINTED_IR_PASS_NAME,
    true, // is CFG only?
    true  // is analysis?
)

namespace llvm {

ModulePass *createX86TaintedIRPass() { return new X86TaintedIR(); }

}
