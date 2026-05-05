#include "arch/type.h"

#define UART0 0x10000000L

#define RHR 0
#define THR 0
#define IER 1
#define FCR 2
#define LCR 3
#define LSR 5

#define LCR_BAUD_LATCH  0x80
#define LCR_EIGHT_BITS  0x03
#define FCR_FIFO_ENABLE 0x01
#define FCR_FIFO_CLEAR  0x06
#define IER_TX_ENABLE   0x01
#define LSR_TX_IDLE     0x20

static volatile uint8 *const uart = (volatile uint8 *)UART0;

void my_put(int c) {
    while ((uart[LSR] & LSR_TX_IDLE) == 0) {}
    uart[THR] = (uint8)c;
}

void uartinit() {
    uart[IER] = 0x00;

    uart[LCR] = LCR_BAUD_LATCH;
    uart[0] = 0x03;
    uart[1] = 0x00;

    uart[LCR] = LCR_EIGHT_BITS;

    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;

    uart[IER] = IER_TX_ENABLE;
}
