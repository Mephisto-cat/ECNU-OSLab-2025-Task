#include "mod.h"

// 内核页表
static pgtbl_t kernel_pgtbl;

// in trampoline.S
extern char trampoline[];

// 根据pagetable,找到va对应的pte
// 若设置alloc=true 则在PTE无效时尝试申请一个物理页
// 成功返回PTE, 失败返回NULL
// 提示：使用 VA_TO_VPN + PTE_TO_PA + PA_TO_PTE
pte_t *vm_getpte(pgtbl_t pgtbl, uint64 va, bool alloc) {
    assert(va < VA_MAX, "vm_getpte: va out of range");

    for (int level = 2; level > 0; level--) {
        pte_t *pte = &pgtbl[VA_TO_VPN(va, level)];
        if (*pte & PTE_V) {
            assert(PTE_CHECK(*pte), "vm_getpte: leaf before level 0");
            pgtbl = (pgtbl_t)PTE_TO_PA(*pte);
        } else {
            if (!alloc)
                return NULL;

            pgtbl_t next = (pgtbl_t)pmem_alloc(true);
            *pte = PA_TO_PTE((uint64)next) | PTE_V;
            pgtbl = next;
        }
    }

    return &pgtbl[VA_TO_VPN(va, 0)];
}

// 在pgtbl中建立 [va, va + len) -> [pa, pa + len) 的映射
// 本质是找到va在页表对应位置的pte并修改它
// 检查: va pa 应当是 page-aligned, len(字节数) > 0, va + len <= VA_MAX
// 注意: perm 应该如何使用
void vm_mappages(pgtbl_t pgtbl, uint64 va, uint64 pa, uint64 len, int perm) {
    assert(len > 0, "vm_mappages: zero length");
    assert(va % PGSIZE == 0, "vm_mappages: va not aligned");
    assert(pa % PGSIZE == 0, "vm_mappages: pa not aligned");
    assert(va + len <= VA_MAX, "vm_mappages: va out of range");

    for (uint64 a = va, p = pa; a < va + len; a += PGSIZE, p += PGSIZE) {
        pte_t *pte = vm_getpte(pgtbl, a, true);
        assert(pte != NULL, "vm_mappages: pte alloc failed");
        assert((*pte & PTE_V) == 0, "vm_mappages: remap");
        *pte = PA_TO_PTE(p) | perm | PTE_V;
    }

}

// 解除pgtbl中[va, va+len)区域的映射
// 如果freeit == true则释放对应物理页, 默认是用户的物理页
void vm_unmappages(pgtbl_t pgtbl, uint64 va, uint64 len, bool freeit) {
    assert(len > 0, "vm_unmappages: zero length");
    assert(va % PGSIZE == 0, "vm_unmappages: va not aligned");
    assert(va + len <= VA_MAX, "vm_unmappages: va out of range");

    for (uint64 a = va; a < va + len; a += PGSIZE) {
        pte_t *pte = vm_getpte(pgtbl, a, false);
        assert(pte != NULL, "vm_unmappages: pte not found");
        assert((*pte & PTE_V) != 0, "vm_unmappages: not mapped");
        assert(!PTE_CHECK(*pte), "vm_unmappages: not a leaf");

        if (freeit)
            pmem_free(PTE_TO_PA(*pte), false);
        *pte = 0;
    }

}

// 完成UART、CLINT、PLIC、内核代码区、内核数据区、可分配区域、trampoline、内核栈的页表映射
// 相当于部分填充kernel_pgtbl
void kvm_init() {
    kernel_pgtbl = (pgtbl_t)pmem_alloc(true);

    // MMIO 外设对等映射
    vm_mappages(kernel_pgtbl, UART_BASE, UART_BASE, PGSIZE, PTE_R | PTE_W);
    vm_mappages(kernel_pgtbl, PLIC_BASE, PLIC_BASE, 0x400000, PTE_R | PTE_W);
    vm_mappages(kernel_pgtbl, CLINT_BASE, CLINT_BASE, 0x10000, PTE_R | PTE_W);

    // 内核代码和数据所在的物理内存采用对等映射
    vm_mappages(kernel_pgtbl, KERNEL_BASE, KERNEL_BASE, (uint64)ALLOC_END - KERNEL_BASE, PTE_R | PTE_W | PTE_X);

    // 用户/内核切换跳板在内核页表中也映射到固定高地址
    vm_mappages(kernel_pgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

    // proczero 的内核栈，映射到高地址区域，下面一页保留作保护页
    uint64 kstack_pa = (uint64)pmem_alloc(true);
    vm_mappages(kernel_pgtbl, KSTACK(0), kstack_pa, PGSIZE, PTE_R | PTE_W);
}

// 每个CPU都需要调用, 从不使用页表切换到使用内核页表
// 切换后需要刷新TLB里面的缓存
void kvm_inithart() {
    w_satp(MAKE_SATP(kernel_pgtbl));
    sfence_vma();
}

// 输出页表内容(for debug)
void vm_print(pgtbl_t pgtbl) {
    // 顶级页表，次级页表，低级页表
    pgtbl_t pgtbl_2 = pgtbl, pgtbl_1 = NULL, pgtbl_0 = NULL;
    pte_t pte;

    printf("level-2 pgtbl: pa = %p\n", pgtbl_2);
    for (int i = 0; i < PGSIZE / sizeof(pte_t); i++) {
        pte = pgtbl_2[i];
        if (!((pte)&PTE_V))
            continue;
        assert(PTE_CHECK(pte), "vm_print: pte check fail (1)");
        pgtbl_1 = (pgtbl_t)PTE_TO_PA(pte);
        printf(".. level-1 pgtbl %d: pa = %p\n", i, pgtbl_1);

        for (int j = 0; j < PGSIZE / sizeof(pte_t); j++) {
            pte = pgtbl_1[j];
            if (!((pte)&PTE_V))
                continue;
            assert(PTE_CHECK(pte), "vm_print: pte check fail (2)");
            pgtbl_0 = (pgtbl_t)PTE_TO_PA(pte);
            printf(".. .. level-0 pgtbl %d: pa = %p\n", j, pgtbl_0);

            for (int k = 0; k < PGSIZE / sizeof(pte_t); k++) {
                pte = pgtbl_0[k];
                if (!((pte)&PTE_V))
                    continue;
                assert(!PTE_CHECK(pte), "vm_print: pte check fail (3)");
                printf(".. .. .. physical page %d: pa = %p flags = %d\n", k, (uint64)PTE_TO_PA(pte), (int)PTE_FLAGS(pte));
            }
        }
    }
}
