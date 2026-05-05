#pragma once

#include "arch/type.h"

// 读 cpuid
static inline uint64 r_cpuid(void) {
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

// 读写 satp
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

// 读 scause
static inline uint64 r_scause() {
    uint64 x;
    asm volatile("csrr %0, scause" : "=r"(x));
    return x;
}

// 读写 sepc
static inline uint64 r_sepc() {
    uint64 x;
    asm volatile("csrr %0, sepc" : "=r"(x));
    return x;
}

static inline void w_sepc(uint64 x) {
    asm volatile("csrw sepc, %0" : : "r"(x));
}

// 读 stval
static inline uint64 r_stval() {
    uint64 x;
    asm volatile("csrr %0, stval" : "=r"(x));
    return x;
}
