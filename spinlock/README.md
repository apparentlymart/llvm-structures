LLVM IR Spinlock
================

``spinlock.ll`` provides a spinlock implementation.

Spinlocks are a very simple building block for mutual exclusion using a
busy-wait loop. Since they poll, they are best used in cases where it is the
common case for the lock to be *uncontended*, and thus where critical sections
are very small.

The lock is acquired using the ``cmpxchg`` instruction to atomically test and
set a byte in memory. Thus the lock isn't actually a data structure at all,
but rather just a byte (`i8`, to be precise) set aside to hold the lock status.
The spinlock functions all take a pointer to such a byte, which must be set
to zero before attempting to use it as a spinlock.

The following functions apply to spinlocks:

* ``spinlock(i8*)``: acquire the lock represented by the given memory address,
  spinning until it becomes available.

* ``spinlock_unlock(i8*)``: release the lock represented by the given memory
  address, thus allowing other threads to acquire it using ``spinlock``.

