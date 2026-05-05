#pragma once

#include "trap/type.h"

// 陷阱初始化
void trap_kernel_init();
void trap_kernel_inithart();
void trap_kernel_handler();

// 时钟
void timer_init();
void clock_intr();

// PLIC
void plic_init();
void plic_inithart();
int  plic_claim();
void plic_complete(int irq);

extern struct trapframe trapframe[NCPU];
extern volatile uint64 ticks;
