#pragma once

#include "arch/type.h"

// 物理页分配器
void  kinit();
void *kalloc();
void  kfree(void *pa);

// 内核页表
void kvminit();
void kvminithart();

extern uint64 *kernel_pgdir;
extern volatile int kvminit_done;
