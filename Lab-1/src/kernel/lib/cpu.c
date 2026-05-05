#include "arch/type.h"

uint64 r_mstatus() {
    uint64 x;
    asm volatile("csrr %0, mstatus" : "=r"(x));
    return x;
}

void w_mstatus(uint64 x) {
    asm volatile("csrw mstatus, %0" : : "r"(x));
}

void w_mepc(uint64 x) {
    asm volatile("csrw mepc, %0" : : "r"(x));
}

void w_pmpaddr0(uint64 x) {
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
}

void w_pmpcfg0(uint64 x) {
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
}

uint64 r_mhartid() {
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    return x;
}

void w_tp(uint64 x) {
    asm volatile("mv tp, %0" : : "r"(x));
}
