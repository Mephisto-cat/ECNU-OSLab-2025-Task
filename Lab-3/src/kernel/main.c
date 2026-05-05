#include "mem/mod.h"
#include "mem/type.h"
#include "trap/mod.h"
#include "lib/mod.h"
#include "arch/method.h"

void main() {
    int cpuid = r_cpuid();

    uartinit();
    printf("\n");
    printf("cpu %d is booting\n", cpuid);

    if (cpuid == 0) {
        kinit();
        printf("[cpu %d] kinit: free list built from %p to %p\n",
               cpuid, (void *)KERNBASE, (void *)PHYSTOP);

        kvminit();
        printf("[cpu %d] kvminit: kernel page table at %p\n",
               cpuid, kernel_pgdir);

        trap_kernel_init();
        printf("[cpu %d] trap_kernel_init: stvec set, PLIC inited\n", cpuid);
    }

    while (!kvminit_done) {}

    kvminithart();
    printf("[cpu %d] kvminithart: satp = %p, paging enabled\n",
           cpuid, (void *)r_satp());

    trap_kernel_inithart();
    printf("[cpu %d] trap_kernel_inithart: interrupts enabled\n", cpuid);

    if (cpuid == 0) {
        timer_init();

        printf("[cpu %d] --- test8: interrupt system ---\n", cpuid);
        uint64 t0 = ticks;
        printf("[cpu %d] initial ticks=%d\n", cpuid, (int)t0);
        printf("[cpu %d] waiting for 5 clock interrupts...\n", cpuid);

        while (ticks < t0 + 5) {}

        printf("[cpu %d] final ticks=%d\n", cpuid, (int)ticks);
        printf("[cpu %d] expect: ticks >= %d\n", cpuid, (int)(t0 + 5));

        printf("[cpu %d] UART interrupt is ready, press some keys...\n", cpuid);

        while (ticks < t0 + 20) {}

        printf("[cpu %d] --- test8 done ---\n", cpuid);
        printf("[cpu %d] === ALL TESTS PASSED ===\n", cpuid);
    }

    for (;;) {
        wfi();
    }
}
