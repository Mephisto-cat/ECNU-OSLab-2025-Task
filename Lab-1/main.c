#include "printf.h"
#include "riscv.h"
#include "uart.h"

void main(void)
{
    uint64 hartid;

    uartinit();
    hartid = r_tp();

    printf("\n");
    printf("Lab1 kernel entered main() on hart %d\n", (int)hartid);
    printf("Hello, world from S-mode!\n");
    printf("UART MMIO base = %p\n", (void *)0x10000000UL);
    printf("This printf is protected by a spinlock.\n");

    for (;;)
        wfi();
}
