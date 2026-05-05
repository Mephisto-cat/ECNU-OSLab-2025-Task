#include "types.h"
#include "printf.h"

#define UART0 0x10000000L

#define RHR 0  // 接收 (读)
#define THR 0  // 发送 (写)
#define IER 1  // 中断使能
#define FCR 2  // FIFO 控制
#define LCR 3  // 线路控制
#define LSR 5  // 线路状态

#define LCR_BAUD_LATCH  0x80  // DLAB=1，要写波特率时先设
#define LCR_EIGHT_BITS  0x03  // 8N1
#define FCR_FIFO_ENABLE 0x01  // 开 FIFO
#define FCR_FIFO_CLEAR  0x06  // 清空 FIFO
#define IER_TX_ENABLE   0x01  // 允许发送中断
#define IER_RX_ENABLE   0x01  // 允许接收中断
#define IER_RX_TX       (IER_RX_ENABLE | IER_TX_ENABLE)
#define LSR_TX_IDLE     0x20  // bit5: 发送器空闲
#define LSR_RX_READY    0x01  // bit0: 有数据

static volatile uint8 *const uart = (volatile uint8 *)UART0;

void my_put(int c) {
    // 等发送器空闲
    while ((uart[LSR] & LSR_TX_IDLE) == 0) {}

    uart[THR] = (uint8)c;
}

void uartinit() {
    // 关中断
    uart[IER] = 0x00;

    // 设置波特率
    uart[LCR] = LCR_BAUD_LATCH;
    uart[0] = 0x03;
    uart[1] = 0x00;

    uart[LCR] = LCR_EIGHT_BITS;

    // 开 FIFO 清空
    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;

    // 使能接收和发送中断
    uart[IER] = IER_RX_TX;
}

// 中断驱动接收 — 读取收到的字符并回显
void uart_intr() {
    while (uart[LSR] & LSR_RX_READY) {
        int c = uart[RHR];
        printf("[UART intr] received: '%c'\n", c);
    }
}