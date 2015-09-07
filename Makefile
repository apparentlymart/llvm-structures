
LLVM_SUFFIX=
LLC=llc$(LLVM_SUFFIX)
CLANG=clang$(LLVM_SUFFIX)
OPT=opt$(LLVM_SUFFIX)
LLVM_DIS=llvm-dis$(LLVM_SUFFIX)
LLVM_LINK=llvm-link$(LLVM_SUFFIX)
PROVE_FLAGS=
SOURCE_FILES=$(shell find . -type f -name '*.ll')
OPT_FILES=$(patsubst %.ll,%.bc,$(SOURCE_FILES))
OPT_SOURCE_FILES=$(patsubst %.ll,%.llo,$(SOURCE_FILES))
OBJ_FILES=$(patsubst %.ll,%.o,$(SOURCE_FILES))
ASM_FILES=$(patsubst %.ll,%.s,$(SOURCE_FILES))
TEST_SOURCE_FILES=$(patsubst %.ll,%_test.c,$(SOURCE_FILES))
TEST_OBJ_FILES=$(patsubst %.ll,%_test.o,$(SOURCE_FILES))
TEST_FILES=$(patsubst %.ll,%_test,$(SOURCE_FILES))

all: $(ASM_FILES) $(OPT_SOURCE_FILES) $(OBJ_FILES)

test: $(TEST_FILES)
	prove $(PROVE_FLAGS) -e '' $(TEST_FILES)

clean:
	rm -f $(OBJ_FILES) $(ASM_FILES) $(OPT_FILES) $(OPT_SOURCE_FILES) $(TEST_OBJ_FILES) $(TEST_FILES) llvmstruct.bc llvmstruct.llo

%.o: %.s
	as $< -o $@

%.s: %.bc
	$(LLC) $< -o=$@

%.bc: %.ll
	$(OPT) $< -inline -constprop -gvn -codegenprepare -o=$@

%.llo: %.bc
	$(LLVM_DIS) $< -o=$@

%_test: %_test.o llvmstruct.o
	gcc $< llvmstruct.o -lpthread -o $@

%_test.o: %_test.c
	$(CLANG) -c -o $@ $< -Itesting

llvmstruct.bc: $(OPT_FILES)
	$(LLVM_LINK) $(OPT_FILES) | $(OPT) -inline -constprop -o $@

.PHONY: all test
