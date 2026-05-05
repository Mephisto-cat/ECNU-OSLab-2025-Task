#include "trap/mod.h"
#include "trap/type.h"
#include "mem/type.h"
#include "arch/method.h"
#include "lib/mod.h"

struct trapframe trapframe[NCPU];
volatile uint64 ticks;

extern void kernel_vector();
extern void timer_vector();

// hart 0 初始化陷阱系统
void trap_kernel_init() {
    plic_init();
}

// 每 hart 配置自己的陷阱入口并启用中断
void trap_kernel_inithart() {
    int cpuid = r_cpuid();

    asm volatile("csrw stvec, %0" : : "r"(kernel_vector));
    asm volatile("csrw sscratch, %0" : : "r"(&trapframe[cpuid]));

    plic_inithart();

    // 开 S-mode 中断: software + timer + external
    asm volatile("csrs sie, %0" : : "r"((1UL << 1) | (1UL << 5) | (1UL << 9)));

    intr_on();
}

// 外部中断分发
static void external_interrupt_handler() {
    int irq = plic_claim();
    if (irq == UART0_IRQ) {
        uart_intr();
    }
    plic_complete(irq);
}

// S-mode 陷阱总入口
void trap_kernel_handler() {
    uint64 scause = trapframe[r_cpuid()].scause;

    if (scause & (1UL << 63)) {
        uint64 code = scause & 0xFF;
        switch (code) {
        case 1:
            clock_intr();
            break;
        case 5:
            clock_intr();
            break;
        case 9:
            external_interrupt_handler();
            break;
        }
    }
}
