#pragma once

typedef unsigned char          uint8;
typedef unsigned int           uint32;
typedef unsigned long long     uint64;
typedef long                   int64;

// RISC-V 中断相关宏
#define MIE_MTIE  (1UL << 7)   // M-mode timer interrupt enable
#define MIP_SSIP  (1UL << 1)   // S-mode software interrupt pending
#define SIE_SSIE  (1UL << 1)   // S-mode software interrupt enable
#define SIE_STIE  (1UL << 5)   // S-mode timer interrupt enable
#define SIE_SEIE  (1UL << 9)   // S-mode external interrupt enable
