/*
➢ 做一些M-mode寄存器的读写操作
➢ 让RISC-V的陷阱机制认为之前的状态是S-mode，以实现状态迁移
➢ 触发状态迁移并进入main函数(S-mode)
*/
#include "types.h"

void main();

uint64 r_mstatus() {
    uint64 x;
    // asm volatile("汇编指令" : 输出列表 : 输入列表);
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

uint64 r_mhartid(void) {
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    return x;
}

void w_tp(uint64 x) {
    asm volatile("mv tp, %0" : : "r"(x));
}


void start() {
    w_tp(r_mhartid());

    uint64 x = r_mstatus();
    // MPP 值	mret 之后变什么模式
    // 3（二进制 11）	M-mode
    // 1（二进制 01）	S-mode1
    // 0（二进制 00）	U-mode

    // x 现在是 M-mode，将其变为 S-mode
    x &= ~(2UL << 11);   // 清 bit12 (M-mode → 不设就是 U-mode)
    x |=  (1UL << 11);   // 设 bit11 = S-mode
    w_mstatus(x);

    w_mepc((uint64)main);

    // 暂时禁用 MMU，关中断委托
    asm volatile("csrw satp, %0" : : "r"(0));
    asm volatile("csrw medeleg, %0" : : "r"(0));
    asm volatile("csrw mideleg, %0" : : "r"(0));
    asm volatile("csrw sie, %0" : : "r"(0));

    w_pmpaddr0(0x3fffffffffffffull);    // 放行全部物理地址
    w_pmpcfg0(0xf);                     // 可读可写可执行

    asm volatile("mret");

    while (1);
}