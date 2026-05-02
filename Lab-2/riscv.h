#ifndef RISCV_H
#define RISCV_H

#include "types.h"

// 读 tp 寄存器 (hartid 从 M-mode 带下来存在这里)
static inline uint64 r_tp(void) {
    uint64 x;
    asm volatile("mv %0, tp" : "=r"(x));
    return x;
}

// 停机等待中断
static inline void wfi(void) {
    asm volatile("wfi");
}

// 关 S-mode 中断
static inline void intr_off(void) {
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
}

// 开 S-mode 中断
static inline void intr_on(void) {
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
}

// 读写 satp (S-mode 页表基址寄存器)
static inline void w_satp(uint64 x) {
    asm volatile("csrw satp, %0" : : "r"(x));
}

static inline uint64 r_satp() {
    uint64 x;
    asm volatile("csrr %0, satp" : "=r"(x));
    return x;
}

// 刷新 TLB
static inline void sfence_vma() {
    asm volatile("sfence.vma");
}

#endif
