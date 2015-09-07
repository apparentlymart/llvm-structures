
define void @spinlock(i8* %lock) alwaysinline {
entry:
    br label %loop
loop:
    %result = cmpxchg i8* %lock, i8 0, i8 1 acquire monotonic
    %success = extractvalue {i8, i1} %result, 1
    br i1 %success, label %done, label %loop
done:
    ret void
}

define void @spinlock_unlock(i8* %lock) alwaysinline {
    fence release
    store i8 0, i8* %lock
    ret void
}
