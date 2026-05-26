#include "mod.h"

// in trampoline.S
extern char trampoline[];  // 内核和用户切换的代码
extern char user_vector[]; // 用户触发陷阱进入内核
extern char user_return[]; // 内核处理完毕返回用户

// in trap.S
extern char kernel_vector[]; // 内核态trap处理流程, 进入内核后应当切换中断处理入口

// in trap_kernel.c
extern char *interrupt_info[16]; // 中断错误信息
extern char *exception_info[16]; // 异常错误信息

static void user_external_interrupt_handler() {
    int irq = plic_claim();

    if (irq == UART_IRQ) {
        int c;
        while ((c = uart_getc_sync()) != -1) {
            printf("[UART intr] received: '%c'\n", c);
        }
    }

    if (irq)
        plic_complete(irq);
}

// 在user_vector()里面调用
// 用户态trap处理的核心逻辑
void trap_user_handler() {
    proc_t *p = myproc();
    uint64 scause = r_scause();
    uint64 stval = r_stval();
    uint64 trap_id = scause & 0xf;

    assert((r_sstatus() & SSTATUS_SPP) == 0, "trap_user_handler: not from u-mode");

    // 进入内核态后先切回内核trap入口, 避免内核处理期间再次走用户入口
    w_stvec((uint64)kernel_vector);

    // 保存用户PC, trap_user_return会重新写回sepc
    p->tf->user_to_kern_epc = r_sepc();

    if (scause & 0x8000000000000000ul) {
        switch (trap_id) {
        case 1:
            timer_interrupt_handler();
            proc_yield();
            break;
        case 5:
            timer_interrupt_handler();
            proc_yield();
            break;
        case 9:
            user_external_interrupt_handler();
            break;
        default:
            printf("\nunexpected user interrupt: %s\n", interrupt_info[trap_id]);
            printf("trap_id = %d, sepc = %p, stval = %p\n", trap_id, p->tf->user_to_kern_epc, stval);
            panic("trap_user_handler");
        }
    } else {
        switch (trap_id) {
        case 8:
            // ecall返回时应跳过ecall指令本身
            p->tf->user_to_kern_epc += 4;
            syscall();
            break;
        case 13:
        case 15:
            printf("page fault occured! trap id = %d\n", trap_id);
            uint64 old_ustack_npage = p->ustack_npage;
            p->ustack_npage = uvm_ustack_grow(p->pgtbl, p->ustack_npage, stval);
            if (p->ustack_npage == (uint64)-1) {
                printf("\nunexpected user page fault: %s\n", exception_info[trap_id]);
                printf("trap_id = %d, sepc = %p, stval = %p\n", trap_id, p->tf->user_to_kern_epc, stval);
                panic("trap_user_handler");
            }
            printf("ustack_npage: %d -> %d\n", old_ustack_npage, p->ustack_npage);
            break;
        default:
            printf("\nunexpected user exception: %s\n", exception_info[trap_id]);
            printf("trap_id = %d, sepc = %p, stval = %p\n", trap_id, p->tf->user_to_kern_epc, stval);
            panic("trap_user_handler");
        }
    }

    trap_user_return();

}

// 调用user_return()
// 内核态返回用户态
void trap_user_return() {
    proc_t *p = myproc();
    uint64 user_vector_va = TRAMPOLINE + ((uint64)user_vector - (uint64)trampoline);
    uint64 user_return_va = TRAMPOLINE + ((uint64)user_return - (uint64)trampoline);
    void (*user_return_fn)(uint64, uint64) = (void (*)(uint64, uint64))user_return_va;

    intr_off();

    // 下一次用户态trap要先进入trampoline中的user_vector
    w_stvec(user_vector_va);

    // user_vector进入内核后需要恢复这些内核运行环境
    p->tf->user_to_kern_satp = r_satp();
    p->tf->user_to_kern_sp = p->kstack;
    p->tf->user_to_kern_trapvector = (uint64)trap_user_handler;
    p->tf->user_to_kern_hartid = r_tp();

    // sret返回到用户态: sepc是用户PC, SPP=0表示返回U-mode, SPIE=1表示用户态开中断
    w_sepc(p->tf->user_to_kern_epc);
    uint64 sstatus = r_sstatus();
    sstatus &= ~SSTATUS_SPP;
    sstatus |= SSTATUS_SPIE;
    w_sstatus(sstatus);

    // 在trampoline中切到用户页表并恢复全部用户寄存器
    user_return_fn(TRAPFRAME, MAKE_SATP(p->pgtbl));

}
