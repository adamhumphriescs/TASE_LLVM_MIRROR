file(GLOB SVFSources *.cpp)

configure_file(config.in Util/config.h)

set(CMAKE_CXX_STANDARD 17)
#set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# add -std=gnu++14
set(CMAKE_CXX_EXTENSIONS ON)

# include_directories(AbstractExecution
# CFL
# DDA
# FastCluster
# Graphs
# MemoryModel
# MSSA
# MTA
# SABER
# SVFIR
# SVF-LLVM
# Util
# WPA)

add_llvm_library(LLVMX86SVF ${SVFSources})

#add_dependencies(LLVMX86SVF intrinsics_gen LLVMSupport)

