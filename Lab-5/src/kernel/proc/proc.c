#include "mod.h"

// 这个文件通过make build生成, 是proczero对应的ELF文件
#include "../../user/initcode.h"
#define initcode target_user_initcode
#define initcode_len target_user_initcode_len

// in trampoline.S
extern char trampoline[];

// in swtch.S
extern void swtch(context_t *old, context_t *new);

// in trap/trap_user.c
extern void trap_user_return();

// 第一个用户进程
static proc_t proczero;

// 获得一个初始化过的用户页表
// 完成trapframe和trampoline的映射
pgtbl_t proc_pgtbl_init(uint64 trapframe) {
    pgtbl_t pgtbl = (pgtbl_t)pmem_alloc(true);

    // trampoline运行在S-mode, 用户页表中必须有同一份高地址映射
    vm_mappages(pgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

    // trapframe由S-mode的user_vector访问, 不加PTE_U避免用户态直接读写
    vm_mappages(pgtbl, TRAPFRAME, trapframe, PGSIZE, PTE_R | PTE_W);

    return pgtbl;
}

/*
    第一个用户态进程的创建
    它的代码和数据位于initcode.h的initcode数组

    第一个进程的用户地址空间布局:
    trapoline   (1 page)
    trapframe   (1 page)
    ustack      (1 page)
    .......
                        <--heap_top
    code + data (1 page)
    empty space (1 page) 最低的4096字节 不分配物理页，同时不可访问

	注意: 用用户空间的地址映射需要标记 PTE_U
*/
void proc_make_first() {
    uint64 code_pa = (uint64)pmem_alloc(false);
    uint64 ustack_pa = (uint64)pmem_alloc(false);

    proczero.pid = 0;
    proczero.tf = (trapframe_t *)pmem_alloc(false);
    proczero.pgtbl = proc_pgtbl_init((uint64)proczero.tf);
    proczero.mmap = NULL;

    // 用户代码从USER_BASE开始, 最低一页留空用于捕获空指针访问
    assert(initcode_len <= PGSIZE, "proc_make_first: initcode too large");
    memmove((void *)code_pa, initcode, initcode_len);
    vm_mappages(proczero.pgtbl, USER_BASE, code_pa, PGSIZE, PTE_R | PTE_W | PTE_X | PTE_U);

    // 用户栈放在TRAPFRAME下方一页, sp从页顶向下增长
    vm_mappages(proczero.pgtbl, TRAPFRAME - PGSIZE, ustack_pa, PGSIZE, PTE_R | PTE_W | PTE_U);
    proczero.ustack_npage = 1;
    proczero.heap_top = USER_BASE + PGSIZE;

    // 初始用户态上下文: PC指向用户代码, SP指向用户栈顶
    proczero.tf->user_to_kern_epc = USER_BASE;
    proczero.tf->sp = TRAPFRAME;

    // 初始内核态上下文: swtch之后从trap_user_return开始返回用户态
    proczero.kstack = KSTACK(proczero.pid) + PGSIZE;
    proczero.ctx.ra = (uint64)trap_user_return;
    proczero.ctx.sp = proczero.kstack;

    mycpu()->proc = &proczero;
    swtch(&mycpu()->ctx, &proczero.ctx);
}
