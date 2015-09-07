
#include <stdint.h>
#include <tap.h>
#include <unistd.h>
// We'll use pthreads to give us two parallel threads so we can
// actually exercise the spinlock. (This means the test suite isn't
// ready-to-run on Windows. Sorry!)
#include <pthread.h>

typedef int8_t lock;

void spinlock(lock*);
void spinlock_unlock(lock*);

lock l;
int started1 = 0;
int locked1 = 0;
int locked2 = 0;

void* thread1(void *thread_id) {
    started1 = 1;
    spinlock(&l);
    locked1 = 1;
    usleep(150000);
    spinlock_unlock(&l);
    return NULL;
}

void* thread2(void *thread_id) {
    spinlock(&l);
    locked2 = 2;
    spinlock_unlock(&l);
    return NULL;
}

int main() {
    pthread_t t1, t2;
    pthread_create(&t1, NULL, thread1, (void*)1);
    while (! started1) {}
    pthread_create(&t2, NULL, thread2, (void*)2);
    while (! locked1) {}
    ok(1, "locked in thread1");
     while (! locked2) {}
    ok(1, "locked in thread2");

    spinlock(&l);
    ok(1, "locked in main");
    spinlock_unlock(&l);

    return test_result();
}
