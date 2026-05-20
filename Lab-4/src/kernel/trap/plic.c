#include "mod.h"

// PLIC初始化
void plic_init() {
    // 设置UART中断优先级
    *(uint32 *)(PLIC_PRIORITY(UART_IRQ)) = 1;
}

// PLIC核心初始化
void plic_inithart() {
    int hartid = mycpuid();

    // Lab-4 的用户态中断测试运行在 CPU0 的 proczero 上。
    // 只让 CPU0 接收 UART 中断，避免 CPU1 在内核态抢走键盘输入。
    if (hartid == 0)
        *(uint32 *)PLIC_SENABLE(hartid) = (1 << UART_IRQ);
    else
        *(uint32 *)PLIC_SENABLE(hartid) = 0;

    // 设置响应阈值
    *(uint32 *)PLIC_SPRIORITY(hartid) = 0;
}

// 获取中断号
int plic_claim(void) {
    int hartid = mycpuid();
    int irq = *(uint32 *)PLIC_SCLAIM(hartid);
    return irq;
}

// 确认该中断号对应中断已经完成
void plic_complete(int irq) {
    int hartid = mycpuid();
    *(uint32 *)PLIC_SCLAIM(hartid) = irq;
}
