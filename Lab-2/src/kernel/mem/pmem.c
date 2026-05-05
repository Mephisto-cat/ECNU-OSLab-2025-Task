#include "mem/mod.h"
#include "mem/type.h"
#include "lock/mod.h"

// 空闲页面链表节点：复用空闲页自身来存储指针
struct run {
    struct run *next;
};

struct {
    struct spinlock lock;
    struct run *freelist;
} kmem;

extern char end; // kernel.ld 定义，内核 BSS 之后的首地址

// 初始化
void kinit() {
    initlock(&kmem.lock, "kmem");

    char *p = (char *)PGROUNDUP((uint64)&end);
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
        kfree(p);
    }
}

// 申请内存，删除链表节点
void *kalloc() {
    acquire(&kmem.lock);
    struct run *r = kmem.freelist;
    if (r) {
        kmem.freelist = r->next;
    }
    release(&kmem.lock);

    if (r) {
        char *v = (char *)r;
        for (int i = 0; i < PGSIZE; i++) {
            v[i] = 0;
        }
    }
    return (void *)r;
}

// 释放，插入链表节点
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
