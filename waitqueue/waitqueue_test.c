#include <tap.h>

struct llist_head_s {
    struct llist_head_s* next;
    struct llist_head_s* prev;
};
typedef struct llist_head_s llist_head;
typedef int8_t spinlock;

typedef struct {
    llist_head list;
    spinlock lock;
} waitqueue;

typedef struct {
    llist_head list;
    void* func;
    void* ctx;
} waitqueue_item;

void waitqueue_init(waitqueue*);
void waitqueue_item_init(waitqueue_item*, void* func, void* ctx);

void test_waitqueue_init() {
    waitqueue queue;

    // Put some garbage in the lock field as if it were uninitialized memory.
    queue.lock = 0xF0;

    waitqueue_init(&queue);

    ok(queue.lock == 0, "queue lock initialized correctly");
    ptr_eq(queue.list.prev, &queue, "queue is its own prev");
    ptr_eq(queue.list.next, &queue, "queue is its own next");
}

void test_waitqueue_item_init() {
    waitqueue_item item;

    // Here we're just using the functions as dummy pointers to give
    // us something to assert against below.
    waitqueue_item_init(&item, test_waitqueue_init, test_waitqueue_item_init);

    ptr_eq(item.list.prev, &item, "item is its own prev");
    ptr_eq(item.list.next, &item, "item is its own next");
    ptr_eq(item.func, test_waitqueue_init, "item func initialized correctly");
    ptr_eq(item.ctx, test_waitqueue_item_init, "item ctx initialized correctly");
}

int main() {
    ok(1, "dummy test so the first thing isn't a group");

    test_group("waitqueue_init", test_waitqueue_init);
    test_group("waitqueue_item_init", test_waitqueue_item_init);

    return test_result();
}
