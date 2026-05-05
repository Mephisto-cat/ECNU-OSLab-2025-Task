/*
➢ 做一些M-mode寄存器的读写操作
➢ 让RISC-V的陷阱机制认为之前的状态是S-mode，以实现状态迁移
➢ 配置中断委托和M-mode陷阱入口
➢ 触发状态迁移并进入main函数(S-mode)
*/
#include "arch/type.h"
#include "mem/type.h"

void main();
extern void timer_vector();

// M-mode CSR 操作声明 (实现见 lib/cpu.c)
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
    // x 现在是 M-mode，将其变为 S-mode
    x &= ~(2UL << 11);
    x |=  (1UL << 11);
    x |=  (1UL << 7);    // MPIE = 1, mret 后 MIE 自动 = 1
    w_mstatus(x);

    w_mepc((uint64)main);

    // 开启分页前先关 MMU
    asm volatile("csrw satp, %0" : : "r"(0));

    // medeleg: 不委托异常
    asm volatile("csrw medeleg, %0" : : "r"(0));

    // mideleg: 委托 S-mode 软件/时钟/外部中断
    asm volatile("csrw mideleg, %0" : : "r"((1UL << 1) | (1UL << 5) | (1UL << 9)));

    // mtvec → timer_vector: M-mode 时钟中断由此处理
    asm volatile("csrw mtvec, %0" : : "r"(timer_vector));

    // mie: 开 M-mode 时钟中断
    asm volatile("csrs mie, %0" : : "r"(MIE_MTIE));

    // 允许 S-mode 读 time/cycle/instret CSR
    asm volatile("csrw mcounteren, %0" : : "r"(7));

    w_pmpaddr0(0x3fffffffffffffull);
    w_pmpcfg0(0xf);

    asm volatile("mret");

    while (1) {}
}
