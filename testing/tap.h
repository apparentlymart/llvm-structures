#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdint.h>

int test_count = 0;
int failures = 0;
typedef void (*subtests)();

void vok(int test, const char *fmt, va_list argp) {
    if (test_count == 0) {
        printf("TAP version 13\n");
    }
    printf("%s %i - ", test ? "ok" : "not ok", ++test_count);
    if (! test) {
        failures++;
    }
    vprintf(fmt, argp);
    printf("\n");
}

int ok(int test, const char *fmt, ...) {
    va_list argp;
    va_start(argp, fmt);
    vok(test, fmt, argp);
    va_end(argp);
    return test;
}

int ptr_eq(void *a, void *b, const char *desc) {
    ok(a == b, "%s: %p == %p", desc, a, b);
    return a == b;
}

void test_group(const char *name, subtests ptr) {
    printf("# %s\n", name);
    ptr();
}

int test_result() {
    printf("1..%i\n", test_count);
    return failures > 0 ? 1 : 0;
}

void bail(const char *why) {
    printf("Bail out! %s\n", why);
    exit(test_result());
}
