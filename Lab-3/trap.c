#include "trap.h"
#include "memlayout.h"
#include "page.h"
#include "plic.h"
#include "printf.h"
#include "riscv.h"
#include "uart.h"

struct trapframe trapframe[NCPU];

extern void kernel_vector();

// hart 0 初始化陷阱系统: 设置 stvec, 初始化 PLIC
void trap_kernel_init() {
    plic_init();
}

// 每个 hart 设置自己的 trapframe 并启用中断
void trap_kernel_inithart() {
    int hartid = r_tp();

    // 设置 stvec 指向 S-mode 陷阱入口
    asm volatile("csrw stvec, %0" : : "r"(kernel_vector));

    // sscratch 存当前 hart 的 trapframe 指针
    asm volatile("csrw sscratch, %0" : : "r"(&trapframe[hartid]));

    plic_inithart();

    // 开 S-mode 中断: sie[1]=software, sie[5]=timer, sie[9]=external
    asm volatile("csrs sie, %0" : : "r"((1UL << 1) | (1UL << 5) | (1UL << 9)));

    // 全局开中断 (sstatus[1]=SIE)
    intr_on();
}

// 外部中断分发 — 读 PLIC claim 号，按中断号分派
static void external_interrupt_handler() {
    int irq = plic_claim();
    if (irq == 10) {
        uart_intr();
    }
    plic_complete(irq);
}

// S-mode 陷阱总入口 (由 kernel_vector 调用)
void trap_kernel_handler() {
    uint64 scause = trapframe[r_tp()].scause;

    if (scause & (1UL << 63)) {
        // 中断
        uint64 code = scause & 0xFF;
        switch (code) {
        case 1:   // S-mode software interrupt → 时钟 tick
            clock_intr();
            break;
        case 5:   // S-mode timer interrupt (备用)
            clock_intr();
            break;
        case 9:   // S-mode external interrupt → PLIC 分发
            external_interrupt_handler();
            break;
        default:
            break;
        }
    }
    // 异常暂不处理，Lab-3 只涉及中断
}
