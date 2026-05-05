#include "mem/mod.h"
#include "mem/type.h"
#include "lock/mod.h"

struct run {
    struct run *next;
};

struct {
    struct spinlock lock;
    struct run *freelist;
} kmem;

extern char end;

void kinit() {
    initlock(&kmem.lock, "kmem");
    char *p = (char *)PGROUNDUP((uint64)&end);
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
        kfree(p);
    }
}

void *kalloc() {
    acquire(&kmem.lock);
    struct run *r = kmem.freelist;
    if (r) {
        kmem.freelist = r->next;
    }
    release(&kmem.lock);
    if (r) {
        uint64 *v = (uint64 *)r;
        for (int i = 0; i < PGSIZE / sizeof(uint64); i++) {
            v[i] = 0;
        }
    }
    return (void *)r;
}

void kfree(void *pa) {
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
        return;
    }
    struct run *r = (struct run *)pa;
    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    release(&kmem.lock);
}
