
LLC=llc
CLANG=clang
OPT=opt
LLVM_DIS=llvm-dis
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
	prove -e '' -v $(TEST_FILES)

clean:
	rm -f $(OBJ_FILES) $(ASM_FILES) $(OPT_FILES) $(OPT_SOURCE_FILES) $(TEST_OBJ_FILES) $(TEST_FILES)

%.o: %.s
	as $< -o $@

%.s: %.bc
	$(LLC) $< -o=$@

%.bc: %.ll
	$(OPT) $< -inline -constprop -gvn -codegenprepare -o=$@

%.llo: %.bc
	$(LLVM_DIS) $< -o=$@

%_test: %_test.o %.o
	gcc $< $(patsubst %_test.o,%.o,$<) -lpthread -o $@

%.o: %.c
	clang -c -o $@ $< -Itesting

.PHONY: all test
