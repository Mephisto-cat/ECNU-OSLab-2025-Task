#ifndef TRAP_H
#define TRAP_H

#include "types.h"

// 每个 hart 的陷阱帧：保存被打断时的全部寄存器状态
// 顺序必须和 trap_entry.S 中的 sd/ld 保持一致
struct trapframe {
    uint64 ra, sp, gp, tp;
    uint64 t0, t1, t2;
    uint64 s0, s1;
    uint64 a0, a1, a2, a3, a4, a5, a6, a7;
    uint64 s2, s3, s4, s5, s6, s7, s8, s9, s10, s11;
    uint64 t3, t4, t5, t6;
    uint64 sepc;
    uint64 sstatus;
    uint64 scause;
    uint64 stval;
};

#define NCPU 8

void trap_kernel_init();
void trap_kernel_inithart();
void trap_kernel_handler();
void timer_init();
void clock_intr();

extern struct trapframe trapframe[NCPU];

#endif
