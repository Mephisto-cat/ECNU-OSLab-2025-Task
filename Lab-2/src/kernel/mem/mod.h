#pragma once

#include "arch/type.h"

void  kinit();
void *kalloc();
void  kfree(void *pa);

void kvminit();
void kvminithart();

extern uint64 *kernel_pgdir;
extern volatile int kvminit_done;
