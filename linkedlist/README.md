LLVM IR Linked List
===================

``linkedlist.ll`` provides a simple circular doubly-linked list implementation.

It expects a struct containing two pointers to itself, which in the source is
called ``%llist_head``. This can then be embedded into another struct to
make that struct into a linked list.

The following operations apply to linked lists:

* ``llist_init(llist_head*)``: turns a (usually-uninitialized) list_head into
  a single-item list, e.g. one where the head is its own predecessor and
  successor.

* ``llist_add_head(llist_head* %new, llist_head* %head)``: takes an
  uninitialized list entr ``%new`` and inserts it into the list before
  ``%head``, so that ``%head.prev`` points to ``%new``.

* ``llist_add_tail(llist_head* %new, llist_head* %head)``: as with
  ``llist_add_head``, except that ``%new`` is inserted *after* ``%head``.

* ``llist_del(llist_head* %entry)``: turns ``%entry`` into a single-item list
  (refers it itself) and then closes the hole left in the list, so that
  ``%entry``'s neighbors now point directly to one another.

Linearly-linked Lists
---------------------

Since the list is both doubly-linked and circular, it's possible to traverse
it in both directions without encountering any "ends".

If a linear list is desired, it can be simulated by starting with a
self-referential sentinel node, and then adding "real" items either before or
after the sentinel. In this case algorithms must know how to identify the
sentinel node; one way to set this up is to make the sentinel the predecessor
of the "head" of the list, so algorithms can dependably find it by accessing
``head.prev``.
