#include "riscv.h"
#include "types.h"
#include "memlayout.h"

volatile uint64 ticks;

#define INTERVAL 10000000UL  // 约 10ms (@1GHz)

// 初始化时钟中断 — 设置第一个 mtimecmp 触发点
void timer_init() {
    uint64 hartid = r_tp();
    volatile uint64 *mtimecmp = (volatile uint64 *)(CLINT + 0x4000 + 8 * hartid);
    volatile uint64 *mtime    = (volatile uint64 *)(CLINT + 0xBFF8);

    *mtimecmp = *mtime + INTERVAL;
}

// S-mode 时钟中断处理 — 在 trap_kernel_handler 中由 software interrupt 触发
void clock_intr() {
    ticks++;
    // 清除 S-mode 软件中断
    asm volatile("csrc sip, %0" : : "r"(2UL));
}
