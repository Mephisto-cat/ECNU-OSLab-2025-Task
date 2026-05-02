#ifndef SPINLOCK_H
#define SPINLOCK_H

#include "types.h"

struct spinlock {
    uint32 locked;
    const char *name;
};

void initlock(struct spinlock *lk, const char *name);
void acquire(struct spinlock *lk);
void release(struct spinlock *lk);

#endif
