#include "mem/mod.h"
#include "mem/type.h"
#include "arch/method.h"

uint64 *kernel_pgdir;
volatile int kvminit_done;

static uint64 *walk(uint64 *pgdir, uint64 va, int alloc) {
    for (int level = 2; level >= 1; level--) {
        uint64 *pte = &pgdir[PX(va, level)];
        if (*pte & PTE_V) {
            pgdir = (uint64 *)PTE2PA(*pte);
        } else if (alloc) {
            pgdir = (uint64 *)kalloc();
            if (pgdir == 0) {
                return 0;
            }
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
        } else {
            return 0;
        }
    }
    return &pgdir[PX(va, 0)];
}

static void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
        uint64 *pte = walk(pgdir, a, 1);
        if (pte == 0) {
            return;
        }
        *pte = PA2PTE(pa) | perm | PTE_V;
    }
}

void kvminit() {
    kernel_pgdir = (uint64 *)kalloc();
    if (kernel_pgdir == 0) {
        return;
    }

    kvmmap(kernel_pgdir, UART0, UART0, PGSIZE, PTE_KERN_RW);
    kvmmap(kernel_pgdir, PLIC, PLIC, 0x400000, PTE_KERN_RW);
    kvmmap(kernel_pgdir, CLINT, CLINT, 0x10000, PTE_KERN_RW);
    kvmmap(kernel_pgdir, KERNBASE, KERNBASE, PHYSTOP - KERNBASE, PTE_KERN_RWX);

    kvminit_done = 1;
}

void kvminithart() {
    w_satp(MAKE_SATP(kernel_pgdir));
    sfence_vma();
}
