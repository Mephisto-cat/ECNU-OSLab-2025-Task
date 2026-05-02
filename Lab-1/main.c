#include "printf.h"
#include "riscv.h"
#include "uart.h"

void main() {
    uartinit();

    if (r_tp() == 0) {
        printf("Hello, World!\n");
        printf("=== printf test ===\n");
        printf("%%d: %d\n", -42);
        printf("%%u: %u\n", 12345U);
        printf("%%x: %x\n", 0xdeadU);
        printf("%%p: %p\n", (void *)0x80000000UL);
        printf("%%s: %s\n", "hello");
        printf("%%c: %c\n", 'X');
        printf("%%%%: 100%%\n");
        printf("=== done ===\n");
    } else {
        printf("Hello, OS!\n");
    }

    for (;;)
        wfi();
}
