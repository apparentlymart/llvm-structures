
%llist_head = type {
    %llist_head*, ; next
    %llist_head*  ; prev
}

; List Initialization
define void @llist_init(%llist_head* %head) {
    %next_pp = getelementptr %llist_head, %llist_head* %head, i32 0, i32 0
    %prev_pp = getelementptr %llist_head, %llist_head* %head, i32 0, i32 1

    ; An empty list starts off as just pointers to itself.
    store %llist_head* %head, %llist_head** %next_pp
    store %llist_head* %head, %llist_head** %prev_pp

    ret void
}

; Internal functions wrapped by the various list-manipulation functions.
define private void @__llist_add(%llist_head* %new, %llist_head* %prev, %llist_head* %next) alwaysinline {
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
define private void @__llist_del(%llist_head* %prev, %llist_head* %next) alwaysinline {
    %next_prev_pp = getelementptr %llist_head, %llist_head* %next, i32 0, i32 1
    %prev_next_pp = getelementptr %llist_head, %llist_head* %prev, i32 0, i32 0

    store %llist_head* %prev, %llist_head** %next_prev_pp
    store %llist_head* %next, %llist_head** %prev_next_pp
    ret void
}

; List Manipulation Operations

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

define void @llist_add_tail(%llist_head* %new, %llist_head* %head) inlinehint {
    %head_prev_pp = getelementptr %llist_head, %llist_head* %head, i32 0, i32 1
    %head_prev_p = load %llist_head*, %llist_head** %head_prev_pp
    call void @__llist_add(
        %llist_head* %new,
        %llist_head* %head_prev_p,
        %llist_head* %head
    )
    ret void
}

define void @llist_del(%llist_head* %entry) inlinehint {
    %entry_prev_pp = getelementptr %llist_head, %llist_head* %entry, i32 0, i32 1
    %entry_next_pp = getelementptr %llist_head, %llist_head* %entry, i32 0, i32 0
    %entry_prev_p = load %llist_head*, %llist_head** %entry_prev_pp
    %entry_next_p = load %llist_head*, %llist_head** %entry_next_pp
    call void @__llist_del(
        %llist_head* %entry_prev_p,
        %llist_head* %entry_next_p
    )

    ; Update our removed item so it points to itself, avoiding the chance
    ; that we'll accidentally traverse out into the old list.
    store %llist_head* %entry, %llist_head** %entry_prev_pp
    store %llist_head* %entry, %llist_head** %entry_next_pp

    ret void
}
