#ifndef VM_H
#define VM_H

#include "types.h"

void kvminit(void);
void kvminithart(void);
void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm);

/* 导出的内核页表根，供其他模块使用 */
extern uint64 *kernel_pgdir;
extern volatile int kvminit_done;

#endif
