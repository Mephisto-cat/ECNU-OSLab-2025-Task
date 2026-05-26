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

static proc_t proc_list[N_PROC];
static proc_t *proczero;
static int global_pid;
static spinlock_t pid_lk;
static spinlock_t wait_lk;
static bool sched_trace;

static int alloc_pid() {
    int pid;

    spinlock_acquire(&pid_lk);
    assert(global_pid > 0, "alloc_pid: overflow");
    pid = global_pid++;
    spinlock_release(&pid_lk);

    return pid;
}

static void proc_return() {
    proc_t *p = myproc();

    spinlock_release(&p->lk);
    trap_user_return();
}

void proc_init() {
    spinlock_init(&pid_lk, "pid");
    spinlock_init(&wait_lk, "wait");
    global_pid = 1;
    proczero = NULL;
    sched_trace = false;

    for (int i = 0; i < N_PROC; i++) {
        proc_t *p = &proc_list[i];
        spinlock_init(&p->lk, "proc");
        p->pid = 0;
        p->state = UNUSED;
        p->parent = NULL;
        p->exit_code = 0;
        p->sleep_space = NULL;
        p->pgtbl = NULL;
        p->heap_top = 0;
        p->ustack_npage = 0;
        p->mmap = NULL;
        p->tf = NULL;
        p->kstack = KSTACK(i) + PGSIZE;
        memset(&p->ctx, 0, sizeof(p->ctx));
        memset(p->name, 0, sizeof(p->name));
    }
}

void proc_set_sched_trace(bool on) {
    sched_trace = on;
}

proc_t *proc_alloc() {
    for (int i = 0; i < N_PROC; i++) {
        proc_t *p = &proc_list[i];
        spinlock_acquire(&p->lk);
        if (p->state == UNUSED) {
            p->pid = alloc_pid();
            p->parent = NULL;
            p->exit_code = 0;
            p->sleep_space = NULL;
            p->heap_top = 0;
            p->ustack_npage = 0;
            p->mmap = NULL;
            p->tf = (trapframe_t *)pmem_alloc(false);
            p->pgtbl = proc_pgtbl_init((uint64)p->tf);
            memset(p->tf, 0, sizeof(trapframe_t));
            memset(&p->ctx, 0, sizeof(p->ctx));
            memset(p->name, 0, sizeof(p->name));
            p->name[0] = 'p';
            p->name[1] = 'r';
            p->name[2] = 'o';
            p->name[3] = 'c';
            p->ctx.ra = (uint64)proc_return;
            p->ctx.sp = p->kstack;
            return p;
        }
        spinlock_release(&p->lk);
    }

    return NULL;
}

void proc_free(proc_t *p) {
    assert(spinlock_holding(&p->lk), "proc_free: lock not held");

    if (p->pgtbl != NULL)
        uvm_destroy_pgtbl(p->pgtbl);

    while (p->mmap != NULL) {
        mmap_region_t *next = p->mmap->next;
        mmap_region_free(p->mmap);
        p->mmap = next;
    }

    p->pid = 0;
    p->state = UNUSED;
    p->parent = NULL;
    p->exit_code = 0;
    p->sleep_space = NULL;
    p->pgtbl = NULL;
    p->heap_top = 0;
    p->ustack_npage = 0;
    p->tf = NULL;
    memset(&p->ctx, 0, sizeof(p->ctx));
    p->ctx.ra = (uint64)proc_return;
    p->ctx.sp = p->kstack;
    memset(p->name, 0, sizeof(p->name));
}

pgtbl_t proc_pgtbl_init(uint64 trapframe) {
    pgtbl_t pgtbl = (pgtbl_t)pmem_alloc(true);

    // trampoline运行在S-mode, 用户页表中必须有同一份高地址映射
    vm_mappages(pgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

    // trapframe由S-mode的user_vector访问, 不加PTE_U避免用户态直接读写
    vm_mappages(pgtbl, TRAPFRAME, trapframe, PGSIZE, PTE_R | PTE_W);

    return pgtbl;
}

void proc_make_first() {
    uint64 code_pa = (uint64)pmem_alloc(false);
    uint64 ustack_pa = (uint64)pmem_alloc(false);
    proc_t *p = proc_alloc();

    assert(p != NULL, "proc_make_first: no proc");
    proczero = p;

    assert(initcode_len <= PGSIZE, "proc_make_first: initcode too large");
    memmove((void *)code_pa, initcode, initcode_len);
    vm_mappages(p->pgtbl, USER_BASE, code_pa, PGSIZE, PTE_R | PTE_W | PTE_X | PTE_U);
    vm_mappages(p->pgtbl, TRAPFRAME - PGSIZE, ustack_pa, PGSIZE, PTE_R | PTE_W | PTE_U);

    p->ustack_npage = 1;
    p->heap_top = USER_BASE + PGSIZE;
    p->tf->user_to_kern_epc = USER_BASE;
    p->tf->sp = TRAPFRAME;
    p->name[0] = 'i';
    p->name[1] = 'n';
    p->name[2] = 'i';
    p->name[3] = 't';
    p->state = RUNNABLE;

    spinlock_release(&p->lk);
}

static mmap_region_t *proc_copy_mmap_list(mmap_region_t *mmap) {
    mmap_region_t *head = NULL;
    mmap_region_t *tail = NULL;

    for (mmap_region_t *src = mmap; src != NULL; src = src->next) {
        mmap_region_t *dst = mmap_region_alloc();
        dst->begin = src->begin;
        dst->npages = src->npages;
        dst->next = NULL;
        if (head == NULL)
            head = dst;
        else
            tail->next = dst;
        tail = dst;
    }

    return head;
}

int proc_fork() {
    proc_t *parent = myproc();
    proc_t *child = proc_alloc();

    if (child == NULL)
        return -1;

    uvm_copy_pgtbl(parent->pgtbl, child->pgtbl, parent->heap_top, parent->ustack_npage, parent->mmap);
    child->heap_top = parent->heap_top;
    child->ustack_npage = parent->ustack_npage;
    child->mmap = proc_copy_mmap_list(parent->mmap);
    memmove(child->tf, parent->tf, sizeof(trapframe_t));
    child->tf->a0 = 0;
    memmove(child->name, parent->name, sizeof(child->name));

    spinlock_acquire(&wait_lk);
    child->parent = parent;
    spinlock_release(&wait_lk);

    child->state = RUNNABLE;
    int pid = child->pid;
    spinlock_release(&child->lk);

    return pid;
}

void proc_yield() {
    proc_t *p = myproc();

    if (p == NULL)
        return;

    spinlock_acquire(&p->lk);
    if (p->state == RUNNING) {
        p->state = RUNNABLE;
        proc_sched();
    }
    spinlock_release(&p->lk);
}

static void proc_reparent(proc_t *parent) {
    for (int i = 0; i < N_PROC; i++) {
        proc_t *p = &proc_list[i];
        if (p->parent == parent) {
            p->parent = proczero;
            proc_wakeup(proczero);
        }
    }
}

static void proc_try_wakeup(proc_t *p) {
    if (p != NULL && p->state == SLEEPING && p->sleep_space == p)
        p->state = RUNNABLE;
}

void proc_exit(int exit_code) {
    proc_t *p = myproc();

    assert(p != proczero, "proc_exit: proczero exits");

    spinlock_acquire(&wait_lk);
    proc_reparent(p);

    if (p->parent != NULL) {
        spinlock_acquire(&p->parent->lk);
        proc_try_wakeup(p->parent);
        spinlock_release(&p->parent->lk);
    }

    spinlock_acquire(&p->lk);
    p->exit_code = exit_code;
    p->state = ZOMBIE;
    spinlock_release(&wait_lk);

    proc_sched();
    panic("proc_exit: returned");
}

int proc_wait(uint64 user_addr) {
    proc_t *p = myproc();

    spinlock_acquire(&wait_lk);
    for (;;) {
        bool have_child = false;

        for (int i = 0; i < N_PROC; i++) {
            proc_t *child = &proc_list[i];
            if (child->parent != p)
                continue;

            have_child = true;
            spinlock_acquire(&child->lk);
            if (child->state == ZOMBIE) {
                int pid = child->pid;
                int exit_code = child->exit_code;

                if (user_addr != 0)
                    uvm_copyout(p->pgtbl, user_addr, (uint64)&exit_code, sizeof(exit_code));

                proc_free(child);
                spinlock_release(&child->lk);
                spinlock_release(&wait_lk);
                return pid;
            }
            spinlock_release(&child->lk);
        }

        if (!have_child) {
            spinlock_release(&wait_lk);
            return -1;
        }

        proc_sleep(p, &wait_lk);
        if (user_addr == 0)
            printf("proc %d is wakeup!\n", p->pid);
    }
}

void proc_sleep(void *sleep_space, spinlock_t *lock) {
    proc_t *p = myproc();

    assert(p != NULL, "proc_sleep: no proc");

    if (lock != &p->lk) {
        spinlock_acquire(&p->lk);
        spinlock_release(lock);
    }

    p->sleep_space = sleep_space;
    p->state = SLEEPING;
    proc_sched();
    p->sleep_space = NULL;

    if (lock != &p->lk) {
        spinlock_acquire(lock);
        spinlock_release(&p->lk);
    }
}

void proc_wakeup(void *sleep_space) {
    for (int i = 0; i < N_PROC; i++) {
        proc_t *p = &proc_list[i];
        if (p == myproc())
            continue;

        spinlock_acquire(&p->lk);
        if (p->state == SLEEPING && p->sleep_space == sleep_space)
            p->state = RUNNABLE;
        spinlock_release(&p->lk);
    }
}

void proc_sched() {
    proc_t *p = myproc();
    int origin;

    assert(p != NULL, "proc_sched: no proc");
    assert(spinlock_holding(&p->lk), "proc_sched: lock not held");
    assert(intr_get() == 0, "proc_sched: interruptible");

    origin = mycpu()->origin;
    swtch(&p->ctx, &mycpu()->ctx);
    mycpu()->origin = origin;
}

void proc_scheduler() {
    cpu_t *cpu = mycpu();

    for (;;) {
        intr_on();

        for (int i = 0; i < N_PROC; i++) {
            proc_t *p = &proc_list[i];
            spinlock_acquire(&p->lk);
            if (p->state == RUNNABLE) {
                p->state = RUNNING;
                cpu->proc = p;
                if (sched_trace)
                    printf("proc %d is running...\n", p->pid);
                swtch(&cpu->ctx, &p->ctx);
                cpu->proc = NULL;
            }
            spinlock_release(&p->lk);
        }
    }
}
