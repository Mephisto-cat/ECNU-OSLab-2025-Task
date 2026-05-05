#include "trap/mod.h"
#include "trap/type.h"
#include "mem/type.h"
#include "arch/method.h"

#define INTERVAL 10000000UL

// M-mode 时钟中断入口
void timer_vector();
asm(
    ".section .text\n"
    ".global timer_vector\n"
    ".align 4\n"
    "timer_vector:\n"
    "    addi sp, sp, -32\n"
    "    sd   a0, 0(sp)\n"
    "    sd   a1, 8(sp)\n"
    "    sd   t0, 16(sp)\n"
    "    sd   ra, 24(sp)\n"
    "    rdtime a0\n"
    "    li    a1, 10000000\n"
    "    add   a0, a0, a1\n"
    "    csrr  a1, mhartid\n"
    "    li    t0, 0x02004000\n"
    "    slli  a1, a1, 3\n"
    "    add   t0, t0, a1\n"
    "    sd    a0, 0(t0)\n"
    "    li    t0, 2\n"
    "    csrs  mip, t0\n"
    "    ld    ra, 24(sp)\n"
    "    ld    t0, 16(sp)\n"
    "    ld    a1, 8(sp)\n"
    "    ld    a0, 0(sp)\n"
    "    addi  sp, sp, 32\n"
    "    mret\n"
);

void timer_init() {
    int cpuid = r_cpuid();
    volatile uint64 *mtimecmp = (volatile uint64 *)CLINT_MTIMECMP(cpuid);
    volatile uint64 *mtime    = (volatile uint64 *)CLINT_MTIME;

    *mtimecmp = *mtime + INTERVAL;
}

void clock_intr() {
    ticks++;
    asm volatile("csrc sip, %0" : : "r"(2UL));
}
