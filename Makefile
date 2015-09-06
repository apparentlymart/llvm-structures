
LLC=llc
CLANG=clang
SOURCE_FILES=$(shell find . -type f -name '*.ll')
OBJ_FILES=$(patsubst %.ll,%.o,$(SOURCE_FILES))
ASM_FILES=$(patsubst %.ll,%.s,$(SOURCE_FILES))
TEST_SOURCE_FILES=$(patsubst %.ll,%_test.c,$(SOURCE_FILES))
TEST_OBJ_FILES=$(patsubst %.ll,%_test.o,$(SOURCE_FILES))
TEST_FILES=$(patsubst %.ll,%_test,$(SOURCE_FILES))

all: $(ASM_FILES) $(OBJ_FILES)

test: $(TEST_FILES)
	prove -e '' -v $(TEST_FILES)

clean:
	rm -f $(OBJ_FILES) $(ASM_FILES) $(TEST_OBJ_FILES) $(TEST_FILES)

%.o: %.s
	as $< -o $@

%.s: %.ll
	$(LLC) $< -o=$@

%_test: %_test.o %.o
	gcc $< $(patsubst %_test.o,%.o,$<) -o $@

%.o: %.c
	clang -c -o $@ $< -Itesting

.PHONY: all test
