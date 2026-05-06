# Lab-3 中断异常初步

## 实验目标

在 Lab-2 的基础上实现：

1. **陷阱系统框架** — S-mode 陷阱入口 (kernel_vector)、上下文保存/恢复、中断分发
2. **时钟中断** — M-mode 时钟中断处理 + S-mode 软件中断构成两级时钟 tick
3. **串口中断** — PLIC 驱动 + UART 中断驱动接收

## 新增文件

| 文件 | 功能 |
|---|---|
| `src/kernel/trap/type.h` | trapframe 结构体 + PLIC/CLINT 寄存器偏移定义 |
| `src/kernel/trap/mod.h` | 陷阱/时钟/PLIC 接口声明 |
| `src/kernel/trap/trap.S` | S-mode 陷阱入口 `kernel_vector` |
| `src/kernel/trap/trap_kernel.c` | 陷阱初始化 + 中断分发 |
| `src/kernel/trap/plic.c` | PLIC 驱动 |
| `src/kernel/trap/timer.c` | M-mode `timer_vector` + `timer_init` + `clock_intr` |

## 改动文件

| 文件 | 改动 |
|---|---|
| `src/kernel/arch/type.h` | 新增 `MIE_MTIE` / `MIP_SSIP` / `SIE_SSIE` / `SIE_STIE` / `SIE_SEIE` 宏 |
| `src/kernel/arch/method.h` | 新增 `r_scause()` / `r_sepc()` / `w_sepc()` / `r_stval()` |
| `src/kernel/boot/start.c` | 配置 mideleg、mtvec→timer_vector、mie(MTIE)、mcounteren、MPIE=1 |
| `src/kernel/lib/uart.c` | uartinit 使能 RX 中断，新增 `uart_intr()` |
| `src/kernel/mem/type.h` | 新增 `PLIC` / `CLINT` 地址宏 |
| `src/kernel/mem/kvm.c` | `kvminit` 新增 PLIC + CLINT 对等映射 |
| `src/kernel/main.c` | 新增 trap/plic 初始化 + timer_init + test8 |

## 实现逻辑链

Lab-2 的内核只能**主动调用函数**——`printf` 输出、`kalloc` 分配，都是内核自己发起的。它无法**被动响应外部事件**——比如键盘按下、时钟到点。

要让内核具备"响应能力"，需要三层机制，且必须按依赖顺序构建：

```
第一层: 陷阱框架 (trap_entry.S + trap.c)
       提供"打断→保存→处理→恢复"的通用管道
第二层: M-mode 中断配置 (start.c + timer_entry.S + timer.c)
       打开中断开关，配置委托，让时钟先跑起来
第三层: 外设中断路由 (plic.c + UART.c 改造)
       把外部设备的中断接到陷阱框架上
```

### 第一层：陷阱框架
**要解决的问题：** 中断随时可能发生。发生的那一刻，CPU 正在执行的代码的寄存器状态必须完整保存，处理完中断后才能原样恢复。而且保存完状态后，必须切回内核栈才能安全地调 C 函数。

**实现（trap_entry.S）：**

```
kernel_vector:
    csrrw sp, sscratch, sp     // sp ↔ trapframe 指针 (sscratch 启动时已写)
    保存 32 个 GPR + CSR        // 全部存到 trapframe
    csrw sscratch, sp           // sscratch = &trapframe (留作返回时用)
    ld sp, trapframe.sp         // 切回内核栈 ← 关键：不切栈会踩烂 trapframe
    call trap_kernel_handler    // C 分发

trap_return:
    csrrw sp, sscratch, sp      // 换回 trapframe
    恢复 CSR + 32 个 GPR
    csrw sscratch, &trapframe   // 为下次 trap 准备
    sret
```

**实现（trap.c）：** `trap_kernel_handler` 读 `scause` 的最高位判中断/异常，低 8 位是中断号，用 switch 分派。目前只处理两种：1. 软件中断，由时钟触发。2. 外部中断，由 PLIC 转发。

**初始化：** `trap_kernel_init`（cpu 0 调用一次）→ 设 stvec、配 PLIC 全局优先级。`trap_kernel_inithart`（每 cpu 各调一次）→ 写 sscratch（指向自己的 trapframe）、写 stvec、使能 sie、调 `intr_on` 开全局中断。

### 第二层：时钟中断

时钟中断是最简单的中断源——不需要外设，CPU 内部就能产生。所以用它来验证第一层的陷阱框架是否正常工作。

**要解决的问题：** RISC-V 的 MTIMECMP 寄存器只能在 M-mode 写，但内核逻辑跑在 S-mode。所以需要 M-mode 和 S-mode 两级协作。

**硬件模型：**
```
MTIME:    一直在递增的 64 位计数器 (开机起每个 cycle +1)
MTIMECMP: 闹钟值，当 MTIME >= MTIMECMP 时触发 M-mode 定时器中断
```

**实现：**

M-mode 侧（timer_entry.S）— 只做硬件维护：
```
timer_vector:
    rdtime                 // 读当前 MTIME
    + INTERVAL             // 加 10M cycles (= 10ms @1GHz)
    写 cpu 的 MTIMECMP    // 闹钟拨到 10ms 后
    csrs mip, 2            // 置 S-mode 软件中断 pending
    mret
```

S-mode 侧（timer.c）— 只做内核逻辑：
```c
void clock_intr() {
    ticks++;
    asm volatile("csrc sip, %0" : : "r"(2UL));  // 清 SSIP
}
```

**启动第一个 tick（timer_init）：** 默认 MTIMECMP = ~0，永远不到。所以必须在 S-mode 通过内存映射方式读 MTIME 当前值、加上 INTERVAL 写入 MTIMECMP——闹钟就设好了。

**M-mode 侧的开关（start.c）：**
| 配置 | 作用 | 不设会怎样 |
|------|------|-----------|
| `mideleg` bit 1/5/9 | 把软中断、时钟、外部中断委托给 S-mode | S-mode 永远收不到中断 |
| `mtvec` → timer_vector | M-mode 定时器中断的入口 | 中断来了 CPU 跳飞 |
| `mie` bit 7 (MTIE) | 允许 M-mode 定时器中断 | 硬件不产生中断 |
| `mstatus.MPIE = 1` | mret 后 MIE = 1 | M-mode 定时器中断无法打断 S-mode |

### 第三层：串口中断

时钟是内部中断，串口是外部中断。外部中断需要一个**路由器**——多个外设共享同一根外部中断线，CPU 需要知道"谁触发的中断"。

**要解决的问题：** UART 收到按键 → 中断信号 → 经过 PLIC 路由到某个 cpu → cpu 的外部中断处理函数 → 读 PLIC claim 寄存器得知是 irq 10 → 调 `uart_intr` → 读完数据 → 通知 PLIC 处理完毕。

**实现（plic.c）：**

- `plic_init`：设 UART0 (irq=10) 优先级 = 1
- `plic_inithart`：为当前 cpu 的 enable 位图里开 bit 10；设阈值 = 0
- `plic_claim` / `plic_complete`：读 claim 寄存器获取中断号；处理完写回同一个地址告知 PLIC

**实现（UART.c 改造）：**

- `uartinit`：IER 从只有发送中断扩展为收发都开
- `uart_intr`：读 LSR bit0 确认有数据 → 读 RHR → printf 回显

**PLIC 和 CLINT 的页表映射（vm.c 改动）：** Lab-2 的内核页表只映射了 UART 和 128MB RAM。PLIC (0x0c000000) 和 CLINT (0x02000000) 是新增的 MMIO 区域，必须在 `kvminit` 里加上对等映射，否则开 MMU 后一访问就 page fault。

### main.c 初始化顺序

```c
// cpu 0
uartinit()           // UART 早于一切，printf 依赖它
kinit()              // 物理页分配器，页表创建依赖它
kvminit()            // 内核页表（含 PLIC/CLINT 映射），开 MMU 依赖它
trap_kernel_init()   // stvec + PLIC 全局配置，中断分发依赖它
                     // → kvminit_done = 1，cpu 1 可以继续了

// 每 cpu
kvminithart()        // 启用 MMU ← PLIC/CLINT 映射已就绪
trap_kernel_inithart() // sscratch/stvec/sie/intr_on ← stvec 已配好，sscratch 已可写

// cpu 0
timer_init()         // 首个 mtimecmp ← CLINT 已映射，stvec 已配好
// test8: 等 5 个 tick ← 整条链路首次实战
```

顺序不能乱：页表映射必须在访问 PLIC/CLINT 之前，stvec 必须在开中断之前，闹钟必须在陷阱框架就绪之后才设。

## 运行方法

```bash
cd Lab-3
make clean && make        # 编译
make run                  # QEMU 运行（-smp 2 双核）
```

## 新增测试

| # | 测试项 | 验证内容 | 结果 |
|---|---|---|---|
| 8 | 中断系统 | 时钟中断正常触发，ticks 从 2 增长到 7（>5），串口中断就绪 | PASS |

### test8 中断系统

```c
timer_init();                    // 设第一个 mtimecmp，闹钟开始滴答
uint64 t0 = ticks;
printf("initial ticks=%d\n", (int)t0);

while (ticks < t0 + 5) {}       // 忙等 5 次时钟中断

printf("final ticks=%d\n", (int)ticks);
// 断言: ticks >= t0 + 5  — 至少 5 次中断正常到达
```

中断的难点是无法控制时机，所以不测确切时刻——只测**趋势和最终结果**：能从循环里"活着出来"就证明整条链路全部正常：

```
MTIMECMP → M-mode timer IRQ → timer_vector 更新闹钟 → 置 SSIP
→ S-mode software IRQ → kernel_vector 保存上下文 → trap_kernel_handler
→ clock_intr (ticks++, 清 SSIP) → 恢复上下文 → sret → 回循环继续检查
```

如果某个环节断了，表现是明确的：

| 断在哪 | 现象 |
|--------|------|
| timer_init 没映射 CLINT | 当场 page fault |
| M-mode 定时器没打开 (mie/MPIE) | ticks 永远不动，死循环 |
| trap_entry 保存/恢复出错 | 寄存器被踩，printf 乱码或 crash |
| clock_intr 没清 SSIP | 只进一次，之后永远卡在处理循环 |

最后等 20 个 tick 给 UART 中断一个窗口期——这段输出本身证明 PLIC 的 init + inithart 没有 crash，UART RX 中断已就绪。

## 关键输出

```
cpu 0 is booting
cpu 1 is booting
[cpu 0] initial ticks=2
[cpu 0] waiting for 5 clock interrupts...

[cpu 0] final ticks=7
[cpu 0] expect: ticks >= 7
[cpu 0] UART interrupt is ready, press some keys...
[UART intr] received: '1'
[UART intr] received: '2'
[UART intr] received: '3'
[UART intr] received: '4'
[UART intr] received: '5'
[UART intr] received: '6'
[UART intr] received: '7'
[cpu 0] --- test8 done ---
[cpu 0] === ALL TESTS PASSED ===
```

## 全部输出

```
cpu 0 is booting
cpu 1 is booting
[cpu 0] kinit: free list built from 0x0000000080000000 to 0x0000000088000000
[cpu 0] kvminit: kernel page table at 0x0000000087fff000
[cpu 1] kvminithart: satp = 0x8000000000087fff, paging enabled
[cpu 0] trap_kernel_init: stvec set, PLIC inited
[cpu 0] kvminithart: satp = 0x8000000000087fff, paging enabled
[cpu 1] trap_kernel_inithart: interrupts enabled
[cpu 0] trap_kernel_inithart: interrupts enabled
[cpu 0] --- test8: interrupt system ---
[cpu 0] initial ticks=2
[cpu 0] waiting for 5 clock interrupts...
[cpu 0] final ticks=7
[cpu 0] expect: ticks >= 7
[cpu 0] UART interrupt is ready, press some keys...
[UART intr] received: '1'
[UART intr] received: '2'
[UART intr] received: '3'
[UART intr] received: '4'
[UART intr] received: '5'
[UART intr] received: '6'
[UART intr] received: '7'
[cpu 0] --- test8 done ---
[cpu 0] === ALL TESTS PASSED ===
QEMU: Terminated
```

## 功能与代码对照

| 功能 | 文件 | 关键函数/变量 |
|------|------|--------------|
| 陷阱入口 | `src/kernel/trap/trap.S` | `kernel_vector`, `trap_return` |
| 上下文保存结构体 | `src/kernel/trap/type.h` | `struct trapframe` (32 GPR + sepc/sstatus/scause/stval) |
| 陷阱初始化 (全局) | `src/kernel/trap/trap_kernel.c` | `trap_kernel_init` → 设 stvec, 调 `plic_init` |
| 陷阱 per-cpu 配置 | `src/kernel/trap/trap_kernel.c` | `trap_kernel_inithart` → 写 sscratch/stvec/sie, `intr_on` |
| 中断分发 | `src/kernel/trap/trap_kernel.c` | `trap_kernel_handler` → switch(scause): 1→`clock_intr`, 9→`external_interrupt_handler` |
| 外部中断分派 | `src/kernel/trap/trap_kernel.c` | `external_interrupt_handler` → `plic_claim` → `uart_intr` / `plic_complete` |
| PLIC 驱动 | `src/kernel/trap/plic.c` | `plic_init` / `plic_inithart` / `plic_claim` / `plic_complete` |
| M-mode 时钟入口 | `src/kernel/trap/timer.c` | `timer_vector` → rdtime, 更新 MTIMECMP, csrs mip 置 SSIP, mret |
| 时钟初始化 + tick | `src/kernel/trap/timer.c` | `timer_init` / `clock_intr` |
| 串口 | `src/kernel/lib/uart.c` | `uartinit` / `my_put` / `uart_intr` |
| M-mode 启动配置 | `src/kernel/boot/start.c` | `start` → mideleg, mtvec→timer_vector, mie(MTIE), mcounteren, MPIE=1 |
| 地址宏 + 中断宏 | `src/kernel/arch/type.h` / `src/kernel/mem/type.h` | `MIE_MTIE` / `PLIC` / `CLINT` |
| 内核页表扩展 | `src/kernel/mem/kvm.c` | `kvminit` → `kvmmap` PLIC + CLINT 对等映射 |
| 测试 (时钟+串口) | `src/kernel/main.c` | `timer_init`, `ticks` 忙等循环, UART 交互窗口 |
