#include "riscv.h"
#include "spinlock.h"

void initlock(struct spinlock *lk, const char *name) {
    lk->locked = 0;
    lk->name = name;
}

/*
acquire — 拿锁
先关中断，然后原子地抢锁
抢不到就在原地自旋，直到拿到为止
*/
void acquire(struct spinlock *lk) {
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0);
    __sync_synchronize(); // 让其他核能看到 lock 的状态
}

/*
release — 放锁
先保证之前的所有内存操作对别的核可见，然后原子放锁，最后开中断
*/
void release(struct spinlock *lk) {
    __sync_synchronize();
    __sync_lock_release(&lk->locked);
    intr_on();
}
