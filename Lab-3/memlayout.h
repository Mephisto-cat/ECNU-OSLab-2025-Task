#ifndef MEMLAYOUT_H
#define MEMLAYOUT_H

// QEMU virt 平台物理内存布局
#define UART0    0x10000000L
#define PLIC     0x0c000000L
#define CLINT    0x02000000L
#define KERNBASE 0x80000000L
#define PHYSTOP  (KERNBASE + 128 * 1024 * 1024)

#endif
