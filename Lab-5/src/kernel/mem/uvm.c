#include "mod.h"

/*--------------------part-1: 关于内核空间<->用户空间的数据传递--------------------*/

static uint64 uvm_walkaddr(pgtbl_t pgtbl, uint64 va, int perm) {
    pte_t *pte = vm_getpte(pgtbl, va, false);

    assert(pte != NULL, "uvm_walkaddr: pte not found");
    assert((*pte & PTE_V) != 0, "uvm_walkaddr: pte not valid");
    assert(!PTE_CHECK(*pte), "uvm_walkaddr: not a leaf");
    assert((*pte & PTE_U) != 0, "uvm_walkaddr: not user page");
    assert(((*pte) & perm) == perm, "uvm_walkaddr: permission denied");

    return PTE_TO_PA(*pte) + (va % PGSIZE);
}

// 用户态地址空间[src, src+len) 拷贝至 内核态地址空间[dst, dst+len)
// 注意: src dst 不一定是 page-aligned
void uvm_copyin(pgtbl_t pgtbl, uint64 dst, uint64 src, uint32 len) {
    while (len > 0) {
        uint64 n = MIN(PGSIZE - (src % PGSIZE), len);
        uint64 pa = uvm_walkaddr(pgtbl, src, PTE_R);

        memmove((void *)dst, (void *)pa, n);
        dst += n;
        src += n;
        len -= n;
    }

}

// 内核态地址空间[src, src+len） 拷贝至 用户态地址空间[dst, dst+len)
// 注意: src dst 不一定是 page-aligned
void uvm_copyout(pgtbl_t pgtbl, uint64 dst, uint64 src, uint32 len) {
    while (len > 0) {
        uint64 n = MIN(PGSIZE - (dst % PGSIZE), len);
        uint64 pa = uvm_walkaddr(pgtbl, dst, PTE_W);

        memmove((void *)pa, (void *)src, n);
        dst += n;
        src += n;
        len -= n;
    }

}

// 用户态字符串拷贝到内核态
// 最多拷贝maxlen字节, 中途遇到'\0'则终止
// 注意: src dst 不一定是 page-aligned
void uvm_copyin_str(pgtbl_t pgtbl, uint64 dst, uint64 src, uint32 maxlen) {
    char ch;

    if (maxlen == 0)
        return;

    for (uint32 i = 0; i < maxlen; i++) {
        uvm_copyin(pgtbl, (uint64)&ch, src + i, 1);
        ((char *)dst)[i] = ch;
        if (ch == '\0')
            return;
    }

    ((char *)dst)[maxlen - 1] = '\0';

}

/*--------------------part-2: mmap_region相关--------------------*/

// 打印以mmap为首的mmap链
// for debug
void uvm_show_mmaplist(mmap_region_t *mmap) {
    mmap_region_t *tmp = mmap;
    printf("\nalloced mmap_space:\n");
    if (tmp == NULL)
        printf("empty\n");
    while (tmp != NULL) {
        printf("alloced mmap_region: %p ~ %p\n", tmp->begin, tmp->begin + tmp->npages * PGSIZE);
        tmp = tmp->next;
    }
}

// 两个 mmap_region 区域合并
// 注意: 保留一个 释放一个 不操作 next 指针
// 由uvm_mmap调用
static void __attribute__((unused)) mmap_merge(mmap_region_t *mmap_1, mmap_region_t *mmap_2, bool keep_mmap_1) {
    // 确保有效和紧临
    assert(mmap_1 != NULL && mmap_2 != NULL, "mmap_merge: NULL");
    assert(mmap_1->begin + mmap_1->npages * PGSIZE == mmap_2->begin, "mmap_merge: check fail");

    // merge
    if (keep_mmap_1) {
        mmap_1->npages += mmap_2->npages;
        mmap_region_free(mmap_2);
    } else {
        mmap_2->begin -= mmap_1->npages * PGSIZE;
        mmap_2->npages += mmap_1->npages;
        mmap_region_free(mmap_1);
    }
}

// 寻找一块足够大的区域(len), 作为 mmap_region
// 由uvm_mmap调用(处理begin==0的情况)
// 成功返回begin, 失败返回0
static uint64 uvm_mmap_find(mmap_region_t *head_mmap, uint64 len, mmap_region_t **p_last_mmap, mmap_region_t **p_tmp_mmap) {
    mmap_region_t *last = NULL;
    mmap_region_t *tmp = head_mmap;
    uint64 begin = MMAP_BEGIN;

    while (tmp != NULL) {
        if (begin + len <= tmp->begin)
            break;
        begin = tmp->begin + tmp->npages * PGSIZE;
        last = tmp;
        tmp = tmp->next;
    }

    if (begin + len > MMAP_END)
        return 0;

    *p_last_mmap = last;
    *p_tmp_mmap = tmp;
    return begin;
}

// 在用户页表和进程mmap链里新增mmap区域 [begin, begin + npages * PGSIZE)
// 调用者保证begin是page-aligned的, 页面权限为perm
// 注意: 如果start==0, 意味着需要内核自主找一块足够大的空间
// 失败则panic卡死
uint64 uvm_mmap(uint64 begin, uint32 npages, int perm) {
    proc_t *p = myproc();
    mmap_region_t *last = NULL;
    mmap_region_t *tmp = p->mmap;
    uint64 len = (uint64)npages * PGSIZE;

    assert(npages > 0, "uvm_mmap: zero pages");
    assert(len > 0, "uvm_mmap: zero length");

    if (begin == 0) {
        begin = uvm_mmap_find(p->mmap, len, &last, &tmp);
        assert(begin != 0, "uvm_mmap: no space");
    } else {
        assert(begin % PGSIZE == 0, "uvm_mmap: begin not aligned");
        assert(begin >= MMAP_BEGIN && begin + len <= MMAP_END, "uvm_mmap: out of range");
        while (tmp != NULL && tmp->begin < begin) {
            last = tmp;
            tmp = tmp->next;
        }
        assert(last == NULL || last->begin + last->npages * PGSIZE <= begin, "uvm_mmap: overlap left");
        assert(tmp == NULL || begin + len <= tmp->begin, "uvm_mmap: overlap right");
    }

    for (uint64 va = begin; va < begin + len; va += PGSIZE)
        vm_mappages(p->pgtbl, va, (uint64)pmem_alloc(false), PGSIZE, perm);

    mmap_region_t *mmap = mmap_region_alloc();
    mmap->begin = begin;
    mmap->npages = npages;
    mmap->next = tmp;
    if (last == NULL)
        p->mmap = mmap;
    else
        last->next = mmap;

    if (last != NULL && last->begin + last->npages * PGSIZE == mmap->begin) {
        last->next = mmap->next;
        mmap_merge(last, mmap, true);
        mmap = last;
    }

    if (tmp != NULL && mmap->begin + mmap->npages * PGSIZE == tmp->begin) {
        mmap->next = tmp->next;
        mmap_merge(mmap, tmp, true);
    }

    return begin;
}


// 在用户页表和进程mmap链里释放mmap区域 [begin, begin + npages * PGSIZE)
// 失败则panic卡死
void uvm_munmap(uint64 begin, uint32 npages) {
    proc_t *p = myproc();
    mmap_region_t *last = NULL;
    mmap_region_t *tmp = p->mmap;
    uint64 len = (uint64)npages * PGSIZE;
    uint64 end = begin + len;

    assert(npages > 0, "uvm_munmap: zero pages");
    assert(begin % PGSIZE == 0, "uvm_munmap: begin not aligned");
    assert(begin >= MMAP_BEGIN && end <= MMAP_END, "uvm_munmap: out of range");

    while (tmp != NULL && tmp->begin + tmp->npages * PGSIZE <= begin) {
        last = tmp;
        tmp = tmp->next;
    }

    assert(tmp != NULL, "uvm_munmap: mmap not found");
    assert(begin >= tmp->begin && end <= tmp->begin + tmp->npages * PGSIZE, "uvm_munmap: range not mapped");

    uint64 tmp_end = tmp->begin + tmp->npages * PGSIZE;
    if (begin == tmp->begin && end == tmp_end) {
        if (last == NULL)
            p->mmap = tmp->next;
        else
            last->next = tmp->next;
        mmap_region_free(tmp);
    } else if (begin == tmp->begin) {
        tmp->begin = end;
        tmp->npages = (tmp_end - end) / PGSIZE;
    } else if (end == tmp_end) {
        tmp->npages = (begin - tmp->begin) / PGSIZE;
    } else {
        mmap_region_t *right = mmap_region_alloc();
        right->begin = end;
        right->npages = (tmp_end - end) / PGSIZE;
        right->next = tmp->next;
        tmp->npages = (begin - tmp->begin) / PGSIZE;
        tmp->next = right;
    }

    vm_unmappages(p->pgtbl, begin, len, true);
}

/*------------------part-3: 用户空间heap和stack管理相关------------------*/

// 用户堆空间增加, 返回新的堆顶地址 (注意栈顶最大值限制)
uint64 uvm_heap_grow(pgtbl_t pgtbl, uint64 cur_heap_top, uint32 len) {
    uint64 new_heap_top = cur_heap_top + len;
    uint64 map_begin = ALIGN_UP(cur_heap_top, PGSIZE);
    uint64 map_end = ALIGN_UP(new_heap_top, PGSIZE);

    assert(new_heap_top >= cur_heap_top, "uvm_heap_grow: overflow");
    assert(new_heap_top <= MMAP_BEGIN, "uvm_heap_grow: out of heap space");

    for (uint64 va = map_begin; va < map_end; va += PGSIZE)
        vm_mappages(pgtbl, va, (uint64)pmem_alloc(false), PGSIZE, PTE_R | PTE_W | PTE_U);

    return new_heap_top;
}

// 用户堆空间减少, 返回新的堆顶地址
uint64 uvm_heap_ungrow(pgtbl_t pgtbl, uint64 cur_heap_top, uint32 len) {
    uint64 new_heap_top = cur_heap_top - len;
    uint64 unmap_begin = ALIGN_UP(new_heap_top, PGSIZE);
    uint64 unmap_end = ALIGN_UP(cur_heap_top, PGSIZE);

    assert(new_heap_top <= cur_heap_top, "uvm_heap_ungrow: overflow");
    assert(new_heap_top >= USER_BASE + PGSIZE, "uvm_heap_ungrow: below heap base");

    if (unmap_begin < unmap_end)
        vm_unmappages(pgtbl, unmap_begin, unmap_end - unmap_begin, true);

    return new_heap_top;
}

// 处理函数栈增长导致的page fault事件
// 成功返回new_ustack_npage，失败返回-1
uint64 uvm_ustack_grow(pgtbl_t pgtbl, uint64 old_ustack_npage, uint64 fault_addr) {
    uint64 old_bottom = TRAPFRAME - old_ustack_npage * PGSIZE;
    uint64 new_bottom = ALIGN_DOWN(fault_addr, PGSIZE);

    if (fault_addr >= old_bottom || new_bottom < MMAP_END)
        return -1;

    for (uint64 va = new_bottom; va < old_bottom; va += PGSIZE)
        vm_mappages(pgtbl, va, (uint64)pmem_alloc(false), PGSIZE, PTE_R | PTE_W | PTE_U);

    return (TRAPFRAME - new_bottom) / PGSIZE;
}

/*----------------------part-4: 用户页表管理相关----------------------*/

// 递归释放 页表占用的物理页 和 页表管理的物理页
// ps: 顶级页表level = 3
static void destroy_pgtbl(pgtbl_t pgtbl, uint32 level) {
    for (int i = 0; i < PGSIZE / sizeof(pte_t); i++) {
        pte_t pte = pgtbl[i];
        if ((pte & PTE_V) == 0)
            continue;

        if (PTE_CHECK(pte)) {
            destroy_pgtbl((pgtbl_t)PTE_TO_PA(pte), level - 1);
        } else {
            pmem_free(PTE_TO_PA(pte), false);
        }
    }

    pmem_free((uint64)pgtbl, true);
}

// 页表销毁
void uvm_destroy_pgtbl(pgtbl_t pgtbl) {
    vm_unmappages(pgtbl, TRAPFRAME, PGSIZE, true);   // 可以释放，因为trapframe是每个进程独有的
    vm_unmappages(pgtbl, TRAMPOLINE, PGSIZE, false); // 不能释放，因为所有进程共用区域
    destroy_pgtbl(pgtbl, 3);
}

// 连续虚拟空间的复制
// 在uvm_copy_pgtbl中使用
static void copy_range(pgtbl_t old, pgtbl_t new, uint64 begin, uint64 end) {
    uint64 va, pa, page;
    int flags;
    pte_t *pte;

    for (va = begin; va < end; va += PGSIZE) {
        pte = vm_getpte(old, va, false);
        assert(pte != NULL, "uvm_copy_pgtbl: pte == NULL");
        assert((*pte) & PTE_V, "uvm_copy_pgtbl: pte not valid");

        pa = (uint64)PTE_TO_PA(*pte);
        flags = (int)PTE_FLAGS(*pte);

        page = (uint64)pmem_alloc(false);
        memmove((char *)page, (const char *)pa, PGSIZE);
        vm_mappages(new, va, page, PGSIZE, flags);
    }
}

// 拷贝页表 (拷贝并不包括 trapframe 和 trampoline)
// 拷贝的页表管理的物理页是原来页表的复制品
void uvm_copy_pgtbl(pgtbl_t old, pgtbl_t new, uint64 heap_top, uint64 ustack_npage, mmap_region_t *mmap) {
    copy_range(old, new, USER_BASE, ALIGN_UP(heap_top, PGSIZE));
    copy_range(old, new, TRAPFRAME - ustack_npage * PGSIZE, TRAPFRAME);

    for (mmap_region_t *tmp = mmap; tmp != NULL; tmp = tmp->next)
        copy_range(old, new, tmp->begin, tmp->begin + tmp->npages * PGSIZE);

}
