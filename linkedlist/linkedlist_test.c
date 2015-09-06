
#include <stdio.h>
#include <tap.h>

struct llist_head_s {
    struct llist_head_s* next;
    struct llist_head_s* prev;
};

typedef struct llist_head_s llist_head;

void llist_init(llist_head*);
void llist_add_head(llist_head*, llist_head*);

void test_init() {
    llist_head list;
    llist_init(&list);

    ptr_eq(list.next, &list, "next elem is list itself");
    ptr_eq(list.prev, &list, "prev elem is list itself");

}

void test_add() {
    llist_head list;
    llist_init(&list);

    llist_head new1;
    llist_head new2;

    llist_add_head(&new1, &list);

    ptr_eq(list.next, &new1, "list next elem is first item");
    ptr_eq(list.prev, &new1, "list prev elem is first item");
    ptr_eq(new1.next, &list, "first item next is list");
    ptr_eq(new1.prev, &list, "first item prev is list");

    llist_add_head(&new2, &list);

    ptr_eq(list.next, &new2, "list next elem is second item");
    ptr_eq(list.prev, &new1, "list prev elem is first item");
    ptr_eq(new1.next, &list, "first item next is list");
    ptr_eq(new1.prev, &new2, "first item prev is second item");
    ptr_eq(new2.next, &new1, "second item next is first item");
    ptr_eq(new2.prev, &list, "second item prev is list");

}

int main() {
    test_group("llist_init", test_init);
    test_group("llist_add", test_add);

    return test_result();
}
