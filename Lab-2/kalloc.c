#include "kalloc.h"
#include "memlayout.h"
#include "page.h"
#include "spinlock.h"

/* 空闲页面链表节点：复用空闲页自身来存储指针 */
struct run {
    struct run *next;
};

struct {
    struct spinlock lock;
    struct run *freelist;
} kmem;

extern char end;  /* kernel.ld 定义，内核 BSS 之后的首地址 */

void kinit(void)
{
    char *p;
    initlock(&kmem.lock, "kmem");

    p = (char *)PGROUNDUP((uint64)&end);
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE)
        kfree(p);
}

void *kalloc(void)
{
    struct run *r;
    char *v;
    int i;

    acquire(&kmem.lock);
    r = kmem.freelist;
    if (r)
        kmem.freelist = r->next;
    release(&kmem.lock);

    if (r) {
        v = (char *)r;
        for (i = 0; i < PGSIZE; i++)
            v[i] = 0;
    }
    return (void *)r;
}

void kfree(void *pa)
{
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0
        || (char *)pa < (char *)PGROUNDUP((uint64)&end)
        || (uint64)pa >= PHYSTOP)
        return;

    r = (struct run *)pa;
    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    release(&kmem.lock);
}
