#include "riscv.h"

void main(void);

// entry.S 把我们放在 M-mode，切到 S-mode 再进 main
__attribute__((noreturn)) void start(void)
{
    uint64 x;

    // hartid 只能在 M-mode 读，存到 tp 带下去
    w_tp(r_mhartid());

    // mstatus.MPP 设成 S-mode，mret 之后就会进 Supervisor
    x = r_mstatus();
    x &= ~MSTATUS_MPP_MASK;
    x |= MSTATUS_MPP_S;
    w_mstatus(x);

    // mret 的目标地址
    w_mepc((uint64)main);

    // 暂时不用 MMU
    w_satp(0);

    // 还没写中断处理，全关
    w_medeleg(0);
    w_mideleg(0);
    w_sie(0);

    // PMP：允许 S-mode 访问全部物理内存
    w_pmpaddr0(0x3fffffffffffffull);
    w_pmpcfg0(0xf);

    asm volatile("mret");

    for (;;)
        ;
}
