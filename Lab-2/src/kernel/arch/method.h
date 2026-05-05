#pragma once

#include "arch/type.h"

static inline uint64 r_cpuid(void) {
    uint64 x;
    asm volatile("mv %0, tp" : "=r"(x));
    return x;
}

static inline void wfi(void) {
    asm volatile("wfi");
}

static inline void intr_off(void) {
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
}

static inline void intr_on(void) {
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
}

static inline void w_satp(uint64 x) {
    asm volatile("csrw satp, %0" : : "r"(x));
}

static inline uint64 r_satp() {
    uint64 x;
    asm volatile("csrr %0, satp" : "=r"(x));
    return x;
}

static inline void sfence_vma() {
    asm volatile("sfence.vma");
}
