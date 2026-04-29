#include "riscv.h"
#include "spinlock.h"

void initlock(struct spinlock *lk, const char *name)
{
    lk->locked = 0;
    lk->name = name;
}

// 关中断后原子抢锁，抢不到就自旋
void acquire(struct spinlock *lk)
{
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0)
        ;
    __sync_synchronize();
}

// 放锁，然后开中断
void release(struct spinlock *lk)
{
    __sync_synchronize();
    __sync_lock_release(&lk->locked);
    intr_on();
}
