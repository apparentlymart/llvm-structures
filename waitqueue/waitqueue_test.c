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
void waitqueue_wait_lopri(waitqueue*, waitqueue_item*);
void waitqueue_wait_hipri(waitqueue*, waitqueue_item*);
void waitqueue_cancel(waitqueue*, waitqueue_item*);
void waitqueue_notify(waitqueue*);

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

void callback_func(void* ctx) {
    *((int*)ctx) = 1;
}

void test_waitqueue_wait_cancel() {
    waitqueue queue;
    waitqueue_item item_hi;
    waitqueue_item item_lo;

    int dummy_ctx = 0;

    waitqueue_init(&queue);
    waitqueue_item_init(&item_hi, callback_func, &dummy_ctx);
    waitqueue_item_init(&item_lo, callback_func, &dummy_ctx);

    waitqueue_wait_hipri(&queue, &item_hi);
    waitqueue_wait_lopri(&queue, &item_lo);

    ptr_eq(queue.list.prev, &item_lo, "item_lo is tail of queue");
    ptr_eq(queue.list.next, &item_hi, "item_hi is head of queue");

    waitqueue_cancel(&queue, &item_hi);

    ptr_eq(queue.list.prev, &item_lo, "item_lo is tail of queue after cancel");
    ptr_eq(queue.list.next, &item_lo, "item_lo is head of queue after cancel");
}

void test_waitqueue_notify() {
    waitqueue queue;
    waitqueue_item item_hi;
    waitqueue_item item_lo;

    int ctx_hi = 0;
    int ctx_lo = 0;

    waitqueue_init(&queue);
    waitqueue_item_init(&item_hi, callback_func, &ctx_hi);
    waitqueue_item_init(&item_lo, callback_func, &ctx_lo);
    waitqueue_wait_hipri(&queue, &item_hi);
    waitqueue_wait_lopri(&queue, &item_lo);

    ok(ctx_hi == 0, "hi callback not triggered yet");
    ok(ctx_lo == 0, "lo callback not triggered yet");

    waitqueue_notify(&queue);

    ok(ctx_hi == 1, "hi callback now triggered");
    ok(ctx_lo == 0, "lo callback still not triggered yet");

    waitqueue_notify(&queue);

    ok(ctx_lo == 1, "lo callback now triggered");
    ptr_eq(queue.list.next, &queue, "queue is now empty");

    waitqueue_notify(&queue);

    ptr_eq(queue.list.next, &queue, "queue is still empty after redundant notify");

}

int main() {
    ok(1, "dummy test so the first thing isn't a group");

    test_group("waitqueue_init", test_waitqueue_init);
    test_group("waitqueue_item_init", test_waitqueue_item_init);
    test_group("waitqueue_wait/cancel", test_waitqueue_wait_cancel);
    test_group("waitqueue_notify", test_waitqueue_notify);

    return test_result();
}
