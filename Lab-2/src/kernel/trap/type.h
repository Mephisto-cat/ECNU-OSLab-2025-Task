#pragma once

// PLIC 寄存器偏移
#define PLIC_PRIORITY    0x000000
#define PLIC_PENDING     0x001000
#define PLIC_ENABLE      0x002000
#define PLIC_THRESHOLD   0x200000
#define PLIC_CLAIM       0x200004

// CLINT 寄存器偏移
#define MTIMECMP(hartid)  (CLINT + 0x4000 + 8 * (hartid))
#define MTIME             (CLINT + 0xBFF8)
