#include "plic.h"
#include "memlayout.h"
#include "riscv.h"

// PLIC 寄存器偏移
#define PLIC_PRIORITY    0x000000  // 中断优先级数组基址
#define PLIC_PENDING     0x001000  // 中断挂起位图
#define PLIC_ENABLE      0x002000  // 中断使能 (per context, 0x80 对齐)
#define PLIC_THRESHOLD   0x200000  // 优先级阈值 (per context, 0x1000 对齐)
#define PLIC_CLAIM       0x200004  // 声明/读取中断 (per context)
#define PLIC_COMPLETE    0x200004  // 完成中断 (同 claim)

#define UART0_IRQ 10

void plic_init() {
    volatile uint8 *plic = (volatile uint8 *)PLIC;

    // 设置 UART0 中断优先级
    *(volatile uint32 *)(plic + PLIC_PRIORITY + UART0_IRQ * 4) = 1;
}

void plic_inithart() {
    int hartid = r_tp();
    volatile uint8 *plic = (volatile uint8 *)PLIC;

    // 使能当前 hart 的 UART0 中断
    uint32 en = *(volatile uint32 *)(plic + PLIC_ENABLE + hartid * 0x80);
    en |= (1U << UART0_IRQ);
    *(volatile uint32 *)(plic + PLIC_ENABLE + hartid * 0x80) = en;

    // 设置优先级阈值为 0（接收所有优先级的中断）
    *(volatile uint32 *)(plic + PLIC_THRESHOLD + hartid * 0x1000) = 0;
}

int plic_claim() {
    int hartid = r_tp();
    volatile uint8 *plic = (volatile uint8 *)PLIC;

    return *(volatile int *)(plic + PLIC_CLAIM + hartid * 0x1000);
}

void plic_complete(int irq) {
    int hartid = r_tp();
    volatile uint8 *plic = (volatile uint8 *)PLIC;

    *(volatile uint32 *)(plic + PLIC_COMPLETE + hartid * 0x1000) = irq;
}
