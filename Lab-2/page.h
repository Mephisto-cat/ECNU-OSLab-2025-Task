#ifndef PAGE_H
#define PAGE_H

#include "types.h"

#define PGSIZE  4096
#define PGSHIFT 12

#define PGROUNDUP(sz)  (((sz) + PGSIZE - 1) & ~(PGSIZE - 1))
#define PGROUNDDOWN(a) ((a) & ~(PGSIZE - 1))

/* Sv39: 3 级页表，每级 9 bit 索引 */
#define PXSHIFT(level)  (PGSHIFT + 9 * (level))
#define PX(va, level)   ((((uint64)(va)) >> PXSHIFT(level)) & 0x1FF)

/* PTE 标志位 */
#define PTE_V   (1UL << 0)
#define PTE_R   (1UL << 1)
#define PTE_W   (1UL << 2)
#define PTE_X   (1UL << 3)
#define PTE_U   (1UL << 4)
#define PTE_G   (1UL << 5)
#define PTE_A   (1UL << 6)
#define PTE_D   (1UL << 7)

#define PTE_KERN_RWX  (PTE_R | PTE_W | PTE_X)
#define PTE_KERN_RW   (PTE_R | PTE_W)

#define PTE2PA(pte)   (((pte) >> 10) << 12)
#define PA2PTE(pa)    (((pa) >> 12) << 10)

/* satp: mode Sv39 + 根页表 PPN */
#define SATP_SV39       (8UL << 60)
#define MAKE_SATP(pgdir)  (SATP_SV39 | (((uint64)(pgdir)) >> 12))

#endif
