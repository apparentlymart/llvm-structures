
#include <stdio.h>
#include <tap.h>

struct llist_head_s {
    struct llist_head_s* next;
    struct llist_head_s* prev;
};

typedef struct llist_head_s llist_head;

void llist_init(llist_head*);
void llist_add_head(llist_head*, llist_head*);
void llist_add_tail(llist_head*, llist_head*);
void llist_del(llist_head*);

void test_init() {
    llist_head list;
    llist_init(&list);

    ptr_eq(list.next, &list, "next elem is list itself");
    ptr_eq(list.prev, &list, "prev elem is list itself");

}

void test_add_head() {
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

void test_add_tail() {
    llist_head list;
    llist_init(&list);

    llist_head new1;
    llist_head new2;

    llist_add_tail(&new1, &list);

    ptr_eq(list.next, &new1, "list next elem is first item");
    ptr_eq(list.prev, &new1, "list prev elem is first item");
    ptr_eq(new1.next, &list, "first item next is list");
    ptr_eq(new1.prev, &list, "first item prev is list");

    llist_add_tail(&new2, &list);

    ptr_eq(list.next, &new1, "list next elem is first item");
    ptr_eq(list.prev, &new2, "list prev elem is secton item");
    ptr_eq(new1.next, &new2, "first item next is second item");
    ptr_eq(new1.prev, &list, "first item prev is list");
    ptr_eq(new2.next, &list, "second item next is list");
    ptr_eq(new2.prev, &new1, "second item prev is first item");

}

void test_del() {
    llist_head item1;
    llist_head item2;
    llist_head item3;

    item1.next = &item2;
    item2.next = &item3;
    item3.next = &item1;
    item1.prev = &item3;
    item3.prev = &item2;
    item2.prev = &item1;

    llist_del(&item2);

    ptr_eq(item2.next, &item2, "item2 next is itself");
    ptr_eq(item2.prev, &item2, "item2 prev is itself");
    ptr_eq(item1.prev, &item3, "item1 prev is item3");
    ptr_eq(item3.prev, &item1, "item3 prev is item1");
    ptr_eq(item1.next, &item3, "item1 next is item3");
    ptr_eq(item3.next, &item1, "item3 next is item1");

}

int main() {
    test_group("llist_init", test_init);
    test_group("llist_add_head", test_add_head);
    test_group("llist_add_tail", test_add_tail);
    test_group("llist_del", test_del);

    return test_result();
}
