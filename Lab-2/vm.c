#include "vm.h"
#include "kalloc.h"
#include "memlayout.h"
#include "page.h"
#include "riscv.h"

uint64 *kernel_pgdir;
volatile int kvminit_done;

/*
 * Walk Sv39 page table, return PTE address for va.
 * When alloc=1, allocate missing intermediate page table pages.
 * Only allocates at levels 2 and 1; level 0 is the leaf PTE.
 */
static uint64 *walk(uint64 *pgdir, uint64 va, int alloc)
{
    int level;
    uint64 *pte;

    for (level = 2; level >= 1; level--) {
        pte = &pgdir[PX(va, level)];
        if (*pte & PTE_V) {
            pgdir = (uint64 *)PTE2PA(*pte);
        } else if (alloc) {
            pgdir = (uint64 *)kalloc();
            if (pgdir == 0)
                return 0;
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
        } else {
            return 0;
        }
    }
    return &pgdir[PX(va, 0)];
}

/* Map va→pa in pgdir for sz bytes (identity mapping for kernel) */
void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm)
{
    uint64 a, *pte;

    for (a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
        pte = walk(pgdir, a, 1);
        if (pte == 0)
            return;
        *pte = PA2PTE(pa) | perm | PTE_V;
    }
}

/*
 * Create kernel page table with identity mapping covering:
 *   - UART MMIO: 0x10000000
 *   - RAM: 0x80000000 .. 0x88000000
 */
void kvminit(void)
{
    kernel_pgdir = (uint64 *)kalloc();
    if (kernel_pgdir == 0)
        return;

    kvmmap(kernel_pgdir, UART0, UART0, PGSIZE, PTE_KERN_RW);
    kvmmap(kernel_pgdir, KERNBASE, KERNBASE, PHYSTOP - KERNBASE,
           PTE_KERN_RWX);

    kvminit_done = 1;
}

/* Enable kernel page table on this hart */
void kvminithart(void)
{
    w_satp(MAKE_SATP(kernel_pgdir));
    asm volatile("sfence.vma" : : : "memory");
}
