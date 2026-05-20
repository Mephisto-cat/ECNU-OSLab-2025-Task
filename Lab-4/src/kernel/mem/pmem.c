#include "mod.h"

// 内核空间和用户空间的可分配物理页分开描述
static alloc_region_t kern_region, user_region;

// 将 [begin, end) 中的每一页挂入空闲链表
static void region_init(alloc_region_t *region, uint64 begin, uint64 end, char *name) {
    region->begin = begin;
    region->end = end;
    region->allocable = 0;
    region->list_head.next = NULL;
    spinlock_init(&region->lk, name);

    for (uint64 page = begin; page + PGSIZE <= end; page += PGSIZE) {
        page_node_t *node = (page_node_t *)page;
        node->next = region->list_head.next;
        region->list_head.next = node;
        region->allocable++;
    }
}

// 物理内存的初始化
// 本质上就是填写kern_region和user_region, 包括基本数值和空闲链表
void pmem_init(void) {
    uint64 begin = ALIGN_UP((uint64)ALLOC_BEGIN, PGSIZE);
    uint64 end = ALIGN_DOWN((uint64)ALLOC_END, PGSIZE);
    uint64 kern_end = begin + KERN_PAGES * PGSIZE;

    if (kern_end > end)
        kern_end = end;

    region_init(&kern_region, begin, kern_end, "kern_region");
    region_init(&user_region, kern_end, end, "user_region");
}

// 尝试返回一个可分配的清零后的物理页
// 失败则panic锁死
void* pmem_alloc(bool in_kernel) {
    alloc_region_t *region = in_kernel ? &kern_region : &user_region;
    page_node_t *page;

    spinlock_acquire(&region->lk);
    page = region->list_head.next;
    if (page != NULL) {
        region->list_head.next = page->next;
        region->allocable--;
    }
    spinlock_release(&region->lk);

    assert(page != NULL, "pmem_alloc: out of memory");
    memset(page, 0, PGSIZE);

    return page;
}

// 释放一个物理页
// 失败则panic锁死
void pmem_free(uint64 page, bool in_kernel) {
    alloc_region_t *region = in_kernel ? &kern_region : &user_region;
    page_node_t *node = (page_node_t *)page;

    assert(page % PGSIZE == 0, "pmem_free: page not aligned");
    assert(page >= region->begin && page < region->end, "pmem_free: page out of range");

    spinlock_acquire(&region->lk);
    node->next = region->list_head.next;
    region->list_head.next = node;
    region->allocable++;
    spinlock_release(&region->lk);
}
