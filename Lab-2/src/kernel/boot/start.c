/*
> 做一些M-mode寄存器的读写操作
> 让RISC-V的陷阱机制认为之前的状态是S-mode，以实现状态迁移
> 触发状态迁移并进入main函数(S-mode)
*/
#include "arch/type.h"

void main();

uint64 r_mstatus();
void   w_mstatus(uint64 x);
void   w_mepc(uint64 x);
void   w_pmpaddr0(uint64 x);
void   w_pmpcfg0(uint64 x);
uint64 r_mhartid();
void   w_tp(uint64 x);


void start() {
    w_tp(r_mhartid());

    uint64 x = r_mstatus();
    x &= ~(2UL << 11);
    x |=  (1UL << 11);
    w_mstatus(x);

    w_mepc((uint64)main);

    asm volatile("csrw satp, %0" : : "r"(0));
    asm volatile("csrw medeleg, %0" : : "r"(0));
    asm volatile("csrw mideleg, %0" : : "r"(0));
    asm volatile("csrw sie, %0" : : "r"(0));

    w_pmpaddr0(0x3fffffffffffffull);
    w_pmpcfg0(0xf);

    asm volatile("mret");

    while (1) {}
}
