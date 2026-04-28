#include "types.h"
#include "uart.h"

// QEMU virt 平台 UART MMIO 基地址
#define UART0 0x10000000L

// 16550 寄存器偏移
#define RHR 0  // 接收 (读)
#define THR 0  // 发送 (写)
#define IER 1  // 中断使能
#define FCR 2  // FIFO 控制
#define LCR 3  // 线路控制 (含 DLAB)
#define LSR 5  // 线路状态

// LCR
#define LCR_BAUD_LATCH  0x80  // DLAB=1, 访问分频器
#define LCR_EIGHT_BITS  0x03  // 8N1

// FCR
#define FCR_FIFO_ENABLE 0x01
#define FCR_FIFO_CLEAR  0x06

// IER
#define IER_TX_ENABLE   0x01
#define IER_RX_ENABLE   0x02

// LSR
#define LSR_TX_IDLE     0x20  // bit 5: 发送器空闲

// volatile — 硬件可能随时改，每次必须真读
static volatile uint8 *const uart = (volatile uint8 *)UART0;

void uartputc_sync(int c)
{
    while ((uart[LSR] & LSR_TX_IDLE) == 0)
        ;
    uart[THR] = (uint8)c;
}

void uartinit(void)
{
    // 关中断，初始化期间寄存器不稳定
    uart[IER] = 0x00;

    // 设波特率：开 DLAB，写分频器，关 DLAB
    uart[LCR] = LCR_BAUD_LATCH;
    uart[0]   = 0x03;
    uart[1]   = 0x00;

    // 8 数据位，无校验，1 停止位
    uart[LCR] = LCR_EIGHT_BITS;

    // 开 FIFO 并清空
    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;

    // 开收发
    uart[IER] = IER_TX_ENABLE | IER_RX_ENABLE;
}
