#include "../arch/mod.h"
#include "../trap/mod.h"

// 每个CPU在运行操作系统时需要一个初始的函数栈
__attribute__((aligned(16))) uint8 CPU_stack[4096 * NCPU];

extern void main();

void start() {
    // 暂时不开启分页，使用物理地址
    w_satp(0);

    // 切换到S-mode后无法访问M-mode的寄存器
    // 所以需要将hartid存到可访问的寄存器tp
    // 之后可以用mycpuid函数访问它
    int id = r_mhartid();
    w_tp(id);

    // 委托S-mode处理所有trap
    w_medeleg(0xffff);
    w_mideleg(SIE_SSIE | SIE_STIE | SIE_SEIE);

    // 时钟中断初始化 (唯一需要在M-mode处理的中断)
    timer_init();

    // 修改mstatus寄存器，假装上一个状态是S-mode
    uint64 status = r_mstatus();
    status &= ~MSTATUS_MPP_MASK;
    status |= MSTATUS_MPP_S;
    status |= (1L << 7); // 设置MPIE, mret后允许M-mode时钟中断打断S-mode
    w_mstatus(status);

    // 设置M-mode的返回地址
    w_mepc((uint64)main);

    // 允许S-mode访问全部物理内存, 并允许读取time/cycle等计数器
    w_pmpaddr0(0x3fffffffffffffull);
    w_pmpcfg0(0xf);
    w_mcounteren(7);

    // 触发状态迁移，回到上一个状态（M-mode->S-mode）
    asm volatile("mret");

    while (1) {
        ;
    }
}
