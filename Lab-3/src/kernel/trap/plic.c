#include "trap/mod.h"
#include "trap/type.h"
#include "mem/type.h"
#include "arch/method.h"

void plic_init() {
    volatile uint8 *plic = (volatile uint8 *)PLIC;
    *(volatile uint32 *)(plic + PLIC_PRIORITY + UART0_IRQ * 4) = 1;
}

void plic_inithart() {
    int cpuid = r_cpuid();
    volatile uint8 *plic = (volatile uint8 *)PLIC;

    uint32 en = *(volatile uint32 *)(plic + PLIC_ENABLE + cpuid * 0x80);
    en |= (1U << UART0_IRQ);
    *(volatile uint32 *)(plic + PLIC_ENABLE + cpuid * 0x80) = en;

    *(volatile uint32 *)(plic + PLIC_THRESHOLD + cpuid * 0x1000) = 0;
}

int plic_claim() {
    int cpuid = r_cpuid();
    volatile uint8 *plic = (volatile uint8 *)PLIC;
    return *(volatile int *)(plic + PLIC_CLAIM + cpuid * 0x1000);
}

void plic_complete(int irq) {
    int cpuid = r_cpuid();
    volatile uint8 *plic = (volatile uint8 *)PLIC;
    *(volatile uint32 *)(plic + PLIC_CLAIM + cpuid * 0x1000) = irq;
}
