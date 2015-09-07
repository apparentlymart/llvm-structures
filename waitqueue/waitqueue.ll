
%llist_head = type {
    %llist_head*, ; next
    %llist_head*  ; prev
}

%waitqueue_ctx = type i8
%waitqueue_func = type void (%waitqueue_ctx*)

%waitqueue_item = type {
    %llist_head,      ; linked list header
    %waitqueue_func*, ; callback function
    %waitqueue_ctx*   ; context pointer
}

%waitqueue = type {
    %llist_head,      ; linked list of waiters; the queue is the sentinel
    i8                ; spinlock byte
}

declare void @llist_init(%llist_head* %head)
declare void @llist_add_head(%llist_head* %new, %llist_head* %head) inlinehint
declare void @llist_add_tail(%llist_head* %new, %llist_head* %head) inlinehint
declare void @llist_del(%llist_head* %entry) inlinehint
declare void @spinlock(i8* %lock) alwaysinline
declare void @spinlock_unlock(i8* %lock) alwaysinline

define void @waitqueue_init(%waitqueue* %queue) alwaysinline {
    %listhead_p = getelementptr %waitqueue, %waitqueue* %queue, i32 0, i32 0
    %spinlock_p = getelementptr %waitqueue, %waitqueue* %queue, i32 0, i32 1

    ; Initialize our list of items as empty. (the queue is the only item)
    call void @llist_init(%llist_head* %listhead_p)

    ; Unused spinlock bytes must be zero.
    store i8 0, i8* %spinlock_p

    ret void
}

define void @waitqueue_item_init(%waitqueue_item* %item, %waitqueue_func* %func, %waitqueue_ctx* %ctx) alwaysinline {
    %listhead_p = getelementptr %waitqueue_item, %waitqueue_item* %item, i32 0, i32 0
    %func_pp = getelementptr %waitqueue_item, %waitqueue_item* %item, i32 0, i32 1
    %ctx_pp = getelementptr %waitqueue_item, %waitqueue_item* %item, i32 0, i32 2

    ; Initialize as the only item in our list.
    call void @llist_init(%llist_head* %listhead_p)

    ; Set the user-provided data.
    store %waitqueue_func* %func, %waitqueue_func** %func_pp
    store %waitqueue_ctx* %ctx, %waitqueue_ctx** %ctx_pp

    ret void
}

define void @waitqueue_wait_hipri(%waitqueue* %queue, %waitqueue_item* %item) alwaysinline {
    %lock_p = getelementptr %waitqueue, %waitqueue* %queue, i32 0, i32 1
    %queue_listhead_p = getelementptr %waitqueue, %waitqueue* %queue, i32 0, i32 0
    %item_listhead_p = getelementptr %waitqueue_item, %waitqueue_item* %item, i32 0, i32 0

    call void @spinlock(i8* %lock_p);

    call void @llist_add_head(
        %llist_head* %item_listhead_p,
        %llist_head* %queue_listhead_p
    )

    call void @spinlock_unlock(i8* %lock_p);

    ret void
}

define void @waitqueue_wait_lopri(%waitqueue* %queue, %waitqueue_item* %item) alwaysinline {
    %lock_p = getelementptr %waitqueue, %waitqueue* %queue, i32 0, i32 1
    %queue_listhead_p = getelementptr %waitqueue, %waitqueue* %queue, i32 0, i32 0
    %item_listhead_p = getelementptr %waitqueue_item, %waitqueue_item* %item, i32 0, i32 0

    call void @spinlock(i8* %lock_p);

    call void @llist_add_tail(
        %llist_head* %item_listhead_p,
        %llist_head* %queue_listhead_p
    )

    call void @spinlock_unlock(i8* %lock_p);

    ret void
}
