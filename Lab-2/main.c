#include "kalloc.h"
#include "memlayout.h"
#include "printf.h"
#include "riscv.h"
#include "uart.h"
#include "vm.h"

void main(void)
{
    uint64 hartid;
    void *p1, *p2, *p3;

    uartinit();
    hartid = r_tp();

    printf("\n");
    printf("Lab2 kernel entered main() on hart %d\n", (int)hartid);

    /* hart 0 does physical memory init and kernel page table */
    if (hartid == 0) {
        kinit();
        printf("[hart %d] kinit: free list built from %p to %p\n",
               (int)hartid, (void *)KERNBASE, (void *)PHYSTOP);

        kvminit();
        printf("[hart %d] kvminit: kernel page table at %p\n",
               (int)hartid, kernel_pgdir);
    }

    /* other harts spin until hart 0 finishes kvminit */
    while (!kvminit_done)
        ;

    /* each hart enables the kernel page table */
    kvminithart();
    printf("[hart %d] kvminithart: satp = %p, paging enabled\n",
           (int)hartid, (void *)r_satp());

    /* test physical page allocation and deallocation */
    p1 = kalloc();
    p2 = kalloc();
    printf("[hart %d] allocated  p1=%p p2=%p\n", (int)hartid, p1, p2);

    kfree(p1);
    kfree(p2);
    printf("[hart %d] freed      p1=%p p2=%p\n", (int)hartid, p1, p2);

    p3 = kalloc();
    printf("[hart %d] re-alloc'd p3=%p\n", (int)hartid, p3);
    kfree(p3);

    printf("[hart %d] Lab2 memory management tests done\n", (int)hartid);

    for (;;)
        wfi();
}
