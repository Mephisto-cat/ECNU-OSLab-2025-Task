#ifndef VM_H
#define VM_H

#include "types.h"

void kvminit();
void kvminithart();

extern uint64 *kernel_pgdir;
extern volatile int kvminit_done;

#endif
