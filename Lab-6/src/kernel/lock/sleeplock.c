#include "mod.h"
#include "../proc/mod.h"

void sleeplock_init(sleeplock_t *lk, char *name) {
    spinlock_init(&lk->lock, "sleeplock");
    lk->locked = 0;
    lk->name = name;
    lk->pid = -1;
}

bool sleeplock_holding(sleeplock_t *lk) {
    bool holding;

    spinlock_acquire(&lk->lock);
    holding = lk->locked && lk->pid == myproc()->pid;
    spinlock_release(&lk->lock);

    return holding;
}

void sleeplock_acquire(sleeplock_t *lk) {
    spinlock_acquire(&lk->lock);
    while (lk->locked) {
        proc_sleep(lk, &lk->lock);
    }
    lk->locked = 1;
    lk->pid = myproc()->pid;
    spinlock_release(&lk->lock);
}

void sleeplock_release(sleeplock_t *lk) {
    spinlock_acquire(&lk->lock);
    assert(lk->locked && lk->pid == myproc()->pid, "sleeplock_release: not holding");
    lk->locked = 0;
    lk->pid = -1;
    proc_wakeup(lk);
    spinlock_release(&lk->lock);
}