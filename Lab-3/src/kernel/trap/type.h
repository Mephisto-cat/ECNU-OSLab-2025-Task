#pragma once

#include "arch/type.h"

// 每 hart 一个的陷阱帧
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

// PLIC 寄存器偏移
#define PLIC_PRIORITY    0x000000
#define PLIC_PENDING     0x001000
#define PLIC_ENABLE      0x002000
#define PLIC_THRESHOLD   0x200000
#define PLIC_CLAIM       0x200004

#define UART0_IRQ 10

// CLINT 寄存器偏移
#define CLINT_MTIMECMP(hartid)  (CLINT + 0x4000 + 8 * (hartid))
#define CLINT_MTIME             (CLINT + 0xBFF8)
