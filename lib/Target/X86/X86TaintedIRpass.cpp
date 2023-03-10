#include "X86.h"
#include "X86InstrInfo.h"
#include "X86TASE.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/GlobalVariable.h"
#include <fstream>
#include <vector> 
#include <string>
#include <type_traits>
// SVF includes
#include "SVF/Util/Options.h"
#include "SVF/Graphs/SVFG.h"
#include "SVF/WPA/Andersen.h"
#include "SVF/SVF-LLVM/LLVMUtil.h"
#include "SVF/SVF-LLVM/SVFIRBuilder.h"

using namespace llvm;
using namespace std;
using namespace SVF;

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
    Set<NodeID> SymVal_succesors (const VFGNode* vNode, SVFG* vfg);
    const VFGNode* verify_succ(const VFGNode* vNode, Set<NodeID> &visited);
    const VFGNode* iterate_predecessors(const VFGNode* vNode, Set<NodeID> &visited);
    const VFGNode* find_defSymVal (Value* val, SVFG* vfg);
    CallInst* find_callSite(Module* mM);
    void taint_instructions_sara (CallInst* cs, Value* val, ICFG* icfg,  Module* mM, Set<NodeID> icfgIDs, Function * Fn, bool &set , bool &beginTaint);
    void taint_functions_sara (SVFG* vfg, ICFG* icfg, Module* mM);
    void manualSVF(Module &M);
    void checkLibc (Instruction &Inst, std::vector<std::string> functionNames);
};

char X86TaintedIR::ID = 0;

Set<NodeID> X86TaintedIR::SymVal_succesors (const VFGNode* vNode, SVFG* vfg){
    SVFIR* pag = SVFIR::getPAG();
    Set<NodeID> visited;
    FIFOWorkList<const VFGNode*> worklist;
    Set<NodeID> icfgIDs;
    worklist.push(vNode);
    visited.insert(vNode->getId());
    icfgIDs.insert(vNode->getICFGNode()->getId());

    auto* moduleset = LLVMModuleSet::getLLVMModuleSet();
    
    /// Traverse along VFG
    while (!worklist.empty())
    {
        const VFGNode* vNode = worklist.pop();
        for (VFGNode::const_iterator it = vNode->OutEdgeBegin(), eit =
                    vNode->OutEdgeEnd(); it != eit; ++it)
        {
            bool constant = 1;
            const VFGEdge* edge = *it;
            NodeID succID = edge->getDstID();
            VFGNode* succNode = edge->getDstNode();
            NodeID icfgID = succNode->getICFGNode()->getId() ;
            
            outs()<< "succNode"<< succNode->toString() <<" and THE ICFGNode " << succNode->getICFGNode()->toString() <<"\n";
            
            //If a tainted variable gets overwritten with constant data, 
            //then taint it but do not traverse any further down this path.
            if (StmtSVFGNode* stmtNode = dyn_cast<StmtSVFGNode>(succNode)) {   
                if (SVFUtil::isa<StoreStmt>(stmtNode->getPAGEdge())){
                    const SVFInstruction* svfinstr = stmtNode->getInst();
		    const Instruction* instr = moduleset->getInstruction(svfinstr);
		    
                    Value* val = instr->getOperand(0);
		    
                    PAGNode* pNode = pag->getGNode(pag->getValueNode(moduleset->getSVFValue(val)));
                    if (pNode->isConstDataOrAggDataButNotNullPtr())
                    {
                         constant = 0;
                         icfgIDs.insert(icfgID);
                         outs()<< "It is constant Data: "<< instr;
                    }  
                }
            }
            if (visited.find(succID) == visited.end() && constant) 
            {
                visited.insert(succID);
                worklist.push(succNode);
                icfgIDs.insert(icfgID);
                outs()<<"Inserting Node "<< succNode->toString() <<" \n";   
            } 
        }
    }
    return icfgIDs;
}

const VFGNode* X86TaintedIR::verify_succ(const VFGNode* vNode, Set<NodeID> &visited)
{
    outs()<<"Printing vnode in verifysucc " <<vNode->toString()<< "\n";
    for (VFGNode::const_iterator it = vNode->OutEdgeBegin(), eit =
                vNode->OutEdgeEnd(); it != eit; ++it)
    {
        VFGEdge* edge = *it;
        NodeID succID = edge->getDstID();
        VFGNode* succNode = edge->getDstNode();
        outs()<<"Printing succNode in verifysucc" <<succNode->toString()<< "\n"; 
        if (edge->isDirectVFGEdge() && (visited.find(succID) == visited.end())){
            if (StmtSVFGNode* stmtNode = dyn_cast<StmtSVFGNode>(succNode)) {   
                if (SVFUtil::isa<StoreStmt>(stmtNode->getPAGEdge())){
                    visited.insert(succID);
                    outs()<<"Printing store succNode in verifysucc" <<succNode->toString()<< "\n"; 
                    return succNode;
                }
            }
        }  
    }
    return vNode;   
}

const VFGNode* X86TaintedIR::iterate_predecessors(const VFGNode* vNode, Set<NodeID> &visited)
{
    
    FIFOWorkList<const VFGNode*> worklist;
    worklist.push(vNode);
    /// Traverse along VFG
    while (!worklist.empty())
    {  
        vNode = worklist.pop();
        outs()<<"Printing vnode in iterate" <<vNode->toString()<< "\n";
        for (VFGNode::const_iterator it = vNode->InEdgeBegin(), eit =
                    vNode->InEdgeEnd(); it != eit; ++it)
        {
            VFGEdge* edge = *it;
            NodeID prevID = edge->getSrcID();
            VFGNode* prevNode = edge->getSrcNode();
            if ((visited.find(prevID) == visited.end()) && edge->isDirectVFGEdge())
            {  
                visited.insert(prevID);
                worklist.push(prevNode);
                outs()<<"Printing pushed worklist " <<prevNode->toString()<< "\n"; 
            }
        }    
    }
    return vNode;   
}

const VFGNode* X86TaintedIR::find_defSymVal (Value* val, SVFG* vfg){
    SVFIR* pag = SVFIR::getPAG();
    auto* moduleset = LLVMModuleSet::getLLVMModuleSet();

    PAGNode* pNode = pag->getGNode(pag->getValueNode(moduleset->getSVFValue(val)));
    const VFGNode* temp;
    Set<NodeID> visited;
    const VFGNode* vNode = vfg->getDefSVFGNode(pNode);
    temp = iterate_predecessors(vNode, visited);
    outs()<<"Printing temp node " <<temp->toString()<< "\n";
    vNode = verify_succ( temp, visited);
    outs()<<"Printing verification node " <<vNode->toString()<< "\n";
    while (temp != vNode)
    {
        temp = iterate_predecessors(vNode, visited);
        outs()<<"Printing while inside temp node " <<temp->toString()<< "\n";
        vNode = verify_succ(temp, visited);
        outs()<<"Printing while inside verification node " <<vNode->toString()<< "\n";
    }

    outs()<<"Printing first node " <<vNode->toString()<< "\n";
    return vNode;
}

CallInst* X86TaintedIR::find_callSite(Module* mM){
    printf("en el find callsite\n");
    auto &FL = mM->getFunctionList();
    for (Function &Fn : FL){
        cout<< Fn.getName().data() << "\n";
        for (BasicBlock &BB : Fn){
            for (Instruction &Inst : BB)
            {
                if (isa<CallInst>(&Inst)) {
                    CallInst* cs;
                    cs = dyn_cast<CallInst>(&Inst);
                    Function *fun = cs->getCalledFunction();
                    if (fun && fun->getName() == "make_byte_symbolic"){ 
                        outs() << fun->getName(); 
                        outs()<< Inst <<"\n";
                        return cs;
                        //return dyn_cast<Value> (&Inst);
                    }
                }
            }
        }
    }
    return nullptr;

}

void X86TaintedIR::taint_instructions_sara (CallInst* cs, Value* val, ICFG* icfg,  Module* mM, Set<NodeID> icfgIDs, Function * Fn, bool &set , bool &beginTaint){ 
    outs()<< "********************************* TAINTING INSIDE FUNCTION "<< Fn->getName() << " ************************************\n";
    auto* moduleset = LLVMModuleSet::getLLVMModuleSet();
    for (BasicBlock &BB : *Fn){
        for (Instruction &Inst : BB)
        {
            if (cs == dyn_cast<CallInst>(&Inst))
            {
                beginTaint = 1;
                outs()<<"Found make sym \n";
            }  
            else if (isa<CallInst>(&Inst))
            {
                CallInst* cInst;
                cInst = dyn_cast<CallInst>(&Inst);
                StringRef funName = cInst->getCalledFunction()->getName();
                // temp.push_back(mM->getFunction(funName));
                taint_instructions_sara ( cs, val, icfg, mM, icfgIDs, mM->getFunction(funName), set, beginTaint);
                outs()<< "********************************* RETURNING TO FUNCTION "<< Fn->getName() << " ************************************\n";
                //continue;
            }


	    
            NodeID id = icfg->getICFGNode(moduleset->getSVFInstruction(&Inst))->getId();
            outs() << "BeginTaint "<< beginTaint << "In ID list? "<< (icfgIDs.find(id) != icfgIDs.end()) << "\n";

            if (icfgIDs.find(id) != icfgIDs.end() && beginTaint )
            {
                Inst.setTainted(1);
                //printf("tainted\n");
                
                if (Inst.getOpcode() == 53)
                {
                    outs() << "Set \n";
                    set = 1;
                }
                outs() << Inst << "and op "<< Inst.getOpcodeName() << "\n";
                //std::cout <<"ICFG ID of an INST"<< id << "\n";
                //addedMD.insert(id);
                //getMD(&Inst);
            }
            else if (set)
            {
                Inst.setTainted(1);
                //printf("tainted\n");
                set = 0;
                outs() << Inst << "and op "<< Inst.getOpcodeName() << "\n";
            }
        }
    }
}
void X86TaintedIR::taint_functions_sara (SVFG* vfg, ICFG* icfg, Module* mM){
    CallInst* cs = find_callSite(mM);
    Value* val = cs->getArgOperand(0);
    Set<NodeID> icfgIDs = SymVal_succesors(find_defSymVal(val, vfg), vfg);
    // bool beginTaint = 0;
    Function *Fn =  mM->getFunction("main");
    if (Fn == nullptr)
    {
     Fn =  mM->getFunction("begin_target_inner");   
    }
    bool beginTaint = 0;
    bool set =0;
    //bool foundFunc = 1;
    outs()<< "********************************* checking if segfault "<< Fn->getName() << " ************************************\n";
    
    taint_instructions_sara(cs, val, icfg, mM, icfgIDs, Fn, set, beginTaint);
}

void X86TaintedIR::checkLibc (Instruction &Inst, std::vector<std::string> functionNames){
        if (isa<CallInst>(&Inst)) {
	    CallInst* cs;
	    cs = dyn_cast<CallInst>(&Inst);
	    Function *fun = cs->getCalledFunction();
	    if (fun ){
		StringRef funName = fun->getName();
		if (std::find(functionNames.begin(), functionNames.end(), funName) != functionNames.end())
			fun->setName(funName + "_sara"); 
	    }
	} 
}

void X86TaintedIR::manualSVF(Module &M) {
	std::ifstream myfile; 
	myfile.open("../../../../install/redefined_sara");
	std::vector<std::string> functionNames;
	StringRef myline;
	std::string temp;
	StringRef delimiter;
	StringRef token;
	if ( myfile.is_open() ) {
	    while ( myfile ) {
		std::getline (myfile, temp);
		myline = StringRef(temp);
		delimiter = " ";
		token = myline.substr(0, myline.find(delimiter));
		functionNames.push_back(token);
	    }
	}
	for (Function &F : M.functions()) {
	    if (F.getMetadata("taintedFun"))
		Analysis.setUseTaintsara(false);
	    for (BasicBlock &BB : F) {
		for (Instruction &Inst : BB){
		    if (Inst.getMetadata("tainted")) {
			checkLibc(Inst, functionNames);
			Inst.setTainted(1);	
		    }		
		}
	    }
	}
}

bool X86TaintedIR::runOnModule(Module &M) {
    if( !Analysis.getUseSVF() ){
      manualSVF(M);
      return false;
    }

    SVFModule* svfModule = LLVMModuleSet::getLLVMModuleSet()->buildSVFModule(M);
    //    svfModule->buildSymbolTableInfo();

    /// Build Program Assignment Graph (SVFIR)
    SVFIRBuilder builder(svfModule);
    SVFIR* pag = builder.build();

    /// Create Andersen's pointer analysis
    Andersen* ander = AndersenWaveDiff::createAndersenWaveDiff(pag);

    /// Call Graph
    PTACallGraph* callgraph = ander->getPTACallGraph();

    /// ICFG
    ICFG* icfg = pag->getICFG();
    //icfg->dump("icfg");

    /// Value-Flow Graph (VFG)
    VFG* vfg = new VFG(callgraph);

    /// Sparse value-flow graph (SVFG)
    SVFGBuilder svfBuilder(true);
    SVFG* svfg = svfBuilder.buildFullSVFG(ander);
    taint_functions_sara(svfg, icfg, &M);
    printf("finished\n");


    // clean up memory
    delete vfg;
    delete svfg;
    AndersenWaveDiff::releaseAndersenWaveDiff();
    SVFIR::releaseSVFIR();

    //    LLVMModuleSet::getLLVMModuleSet()->dumpModulesToFile(".svf.bc");
    SVF::LLVMModuleSet::releaseLLVMModuleSet();

    //    llvm::llvm_shutdown();
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
