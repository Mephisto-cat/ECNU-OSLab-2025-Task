#ifndef RISCV_H
#define RISCV_H

#include "types.h"

// 读 tp 寄存器 (hartid 从 M-mode 带下来存在这里)
static inline uint64 r_tp(void) {
    uint64 x;
    asm volatile("mv %0, tp" : "=r"(x));
    return x;
}

// 读 mhartid (M-mode hart ID)
static inline uint64 r_mhartid() {
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    return x;
}

// 停机等待中断
static inline void wfi(void) {
    asm volatile("wfi");
}

// 读 scause (S-mode trap cause)
static inline uint64 r_scause() {
    uint64 x;
    asm volatile("csrr %0, scause" : "=r"(x));
    return x;
}

// 读 sepc (S-mode exception PC)
static inline uint64 r_sepc() {
    uint64 x;
    asm volatile("csrr %0, sepc" : "=r"(x));
    return x;
}

// 写 sepc
static inline void w_sepc(uint64 x) {
    asm volatile("csrw sepc, %0" : : "r"(x));
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
