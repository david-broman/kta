
LIB_NAME = ptllvm
FILES = llvmBitcode llvmPPrint llvmDecode llvmEval llvmUtils
TEST_FILES = testLlvmDecode
ONLY_MLI_FILES = llvmAst
DIRS = ../utools/ /usr/local/llvm32/lib/ocaml
DEP_LIBS = utools.cmxa llvm.cmxa llvm_executionengine.cmxa llvm_bitreader.cmxa
