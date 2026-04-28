#ifndef SPINLOCK_H
#define SPINLOCK_H

#include "types.h"

/*
 * 自旋锁（spinlock）。
 *
 * 用于保护多核场景下的共享资源（比如 UART）。
 * 如果一个核拿着锁，另一个核试图获取锁时就会原地"自旋"等待，
 * 直到持锁者释放，不会睡眠/切换任务。
 */
struct spinlock {
    uint32 locked;      /* 0 = 空闲, 1 = 被占用 */
    const char *name;   /* 锁的名字（调试用） */
};

void initlock(struct spinlock *lk, const char *name);
void acquire(struct spinlock *lk);
void release(struct spinlock *lk);

#endif
