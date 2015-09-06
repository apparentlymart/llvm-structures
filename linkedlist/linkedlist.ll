
%llist_head = type {
    %llist_head*, ; next
    %llist_head*  ; prev
}

define void @llist_init(%llist_head* %head) {
    %next_pp = getelementptr %llist_head, %llist_head* %head, i32 0, i32 0
    %prev_pp = getelementptr %llist_head, %llist_head* %head, i32 0, i32 1

    ; An empty list starts off as just pointers to itself.
    store %llist_head* %head, %llist_head** %next_pp
    store %llist_head* %head, %llist_head** %prev_pp

    ret void
}

; Internal function wrapped by the various list-manipulation functions.
define void @__llist_add(%llist_head* %new, %llist_head* %prev, %llist_head* %next) alwaysinline {
    %next_prev_pp = getelementptr %llist_head, %llist_head* %next, i32 0, i32 1
    %prev_next_pp = getelementptr %llist_head, %llist_head* %prev, i32 0, i32 0
    %new_prev_pp = getelementptr %llist_head, %llist_head* %new, i32 0, i32 1
    %new_next_pp = getelementptr %llist_head, %llist_head* %new, i32 0, i32 0

    store %llist_head* %new, %llist_head** %next_prev_pp
    store %llist_head* %next, %llist_head** %new_next_pp
    store %llist_head* %prev, %llist_head** %new_prev_pp
    store %llist_head* %new, %llist_head** %prev_next_pp
    ret void
}

define void @llist_add_head(%llist_head* %new, %llist_head* %head) inlinehint {
    %head_next_pp = getelementptr %llist_head, %llist_head* %head, i32 0, i32 0
    %head_next_p = load %llist_head*, %llist_head** %head_next_pp
    call void @__llist_add(
        %llist_head* %new,
        %llist_head* %head,
        %llist_head* %head_next_p
    )
    ret void
}
