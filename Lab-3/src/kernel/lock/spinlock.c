#include "lock/mod.h"
#include "arch/method.h"

void initlock(struct spinlock *lk, const char *name) {
    lk->locked = 0;
    lk->name = name;
}

void acquire(struct spinlock *lk) {
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0) {}
    __sync_synchronize();
}

void release(struct spinlock *lk) {
    __sync_synchronize();
    __sync_lock_release(&lk->locked);
    intr_on();
}
