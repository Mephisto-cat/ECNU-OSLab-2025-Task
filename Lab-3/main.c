#include "kalloc.h"
#include "memlayout.h"
#include "printf.h"
#include "riscv.h"
#include "trap.h"
#include "uart.h"
#include "vm.h"

extern volatile uint64 ticks;

void main() {
    uint64 hartid;

    uartinit();
    hartid = r_tp();

    printf("\n");
    printf("=== Lab3: hart %d ===\n", (int)hartid);

    // hart 0 负责初始化物理内存和内核页表
    if (hartid == 0) {
        kinit();
        printf("[hart %d] kinit: free list built from %p to %p\n",
               (int)hartid, (void *)KERNBASE, (void *)PHYSTOP);

        kvminit();
        printf("[hart %d] kvminit: kernel page table at %p\n",
               (int)hartid, kernel_pgdir);

        // 初始化陷阱系统 (设置 stvec + 初始化 PLIC)
        trap_kernel_init();
        printf("[hart %d] trap_kernel_init: stvec set, PLIC inited\n",
               (int)hartid);
    }

    // 其他 hart 自旋等待 hart 0 完成 kvminit
    while (!kvminit_done) {}

    // 每个 hart 启用内核页表
    kvminithart();
    printf("[hart %d] kvminithart: satp = %p, paging enabled\n", (int)hartid, (void *)r_satp());

    // 每个 hart 配置自己的陷阱入口和中断
    trap_kernel_inithart();
    printf("[hart %d] trap_kernel_inithart: interrupts enabled\n", (int)hartid);

    if (hartid == 0) {
        // 初始化时钟中断: 写第一个 mtimecmp 启动时钟 tick
        timer_init();

        // 测试 — 中断系统 (时钟中断 + 串口中断就绪)
        printf("[hart %d] --- test8: interrupt system ---\n", (int)hartid);
        uint64 t0 = ticks;
        printf("[hart %d] initial ticks=%d\n", (int)hartid, (int)t0);
        printf("[hart %d] waiting for 5 clock interrupts...\n", (int)hartid);

        // 等 5 个时钟 tick
        while (ticks < t0 + 5) {}

        printf("[hart %d] final ticks=%d\n", (int)hartid, (int)ticks);
        printf("[hart %d] expect: ticks >= %d\n",
               (int)hartid, (int)(t0 + 5));

        // PLIC 和 UART RX 中断已就绪，等一些 tick 给用户敲键盘
        printf("[hart %d] UART interrupt is ready, press some keys...\n",
               (int)hartid);

        while (ticks < t0 + 20) {}

        printf("[hart %d] --- test8 done ---\n", (int)hartid);
        printf("[hart %d] === ALL TESTS PASSED ===\n", (int)hartid);
    }

    for (;;) {
        wfi();
    }
}