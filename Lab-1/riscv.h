#ifndef RISCV_H
#define RISCV_H

#include "types.h"

// mstatus MPP 字段：决定 mret 后进哪个 privilege level
#define MSTATUS_MPP_MASK  (3UL << 11)
#define MSTATUS_MPP_S     (1UL << 11)

// S-mode 中断使能位
#define SIE_SEIE (1UL << 9)
#define SIE_STIE (1UL << 5)
#define SIE_SSIE (1UL << 1)

// RISC-V CSR 读写内联汇编

static inline uint64 r_mhartid(void)
{
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    return x;
}

static inline void w_tp(uint64 x)
{
    asm volatile("mv tp, %0" : : "r"(x));
}

static inline uint64 r_tp(void)
{
    uint64 x;
    asm volatile("mv %0, tp" : "=r"(x));
    return x;
}

static inline uint64 r_mstatus(void)
{
    uint64 x;
    asm volatile("csrr %0, mstatus" : "=r"(x));
    return x;
}

static inline void w_mstatus(uint64 x)
{
    asm volatile("csrw mstatus, %0" : : "r"(x));
}

static inline void w_mepc(uint64 x)
{
    asm volatile("csrw mepc, %0" : : "r"(x));
}

static inline void w_satp(uint64 x)
{
    asm volatile("csrw satp, %0" : : "r"(x));
}

static inline void w_sie(uint64 x)
{
    asm volatile("csrw sie, %0" : : "r"(x));
}

static inline void w_medeleg(uint64 x)
{
    asm volatile("csrw medeleg, %0" : : "r"(x));
}

static inline void w_mideleg(uint64 x)
{
    asm volatile("csrw mideleg, %0" : : "r"(x));
}

static inline void w_pmpaddr0(uint64 x)
{
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
}

static inline void w_pmpcfg0(uint64 x)
{
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
}

static inline void intr_on(void)
{
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
}

static inline void intr_off(void)
{
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
}

static inline uint64 intr_get(void)
{
    uint64 x;
    asm volatile("csrr %0, sstatus" : "=r"(x));
    return (x & 2UL) != 0;
}

static inline void wfi(void)
{
    asm volatile("wfi");
}

#endif
