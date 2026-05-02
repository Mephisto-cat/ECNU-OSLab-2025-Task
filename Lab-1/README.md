# Lab-1 实验报告：机器启动

## 实验目标

在 QEMU RISC-V 64 位虚拟平台上实现一个最小裸机内核，完成以下四个子任务：

1. 从 CPU 上电进入 main 函数
2. 通过 UART 串口实现字符级输出
3. 基于 UART 实现 printf 格式化输出
4. 使用自旋锁解决多核竞争 UART 的问题

## 实验环境

| 项目 | 配置 |
|------|------|
| 编译器 | riscv64-linux-gnu-gcc 11.4.0 |
| 模拟器 | QEMU 6.2.0 |
| 平台 | virt，128MB 内存，2 核 |
| 调试器 | gdb-multiarch |
| 内核加载地址 | 0x80000000 |

编译选项：`-ffreestanding -fno-pie -fno-pic -mno-relax -mcmodel=medany -march=rv64gc -mabi=lp64d`

## 实现内容

### 1. 机器启动

**kernel.ld** — 链接脚本。指定 OUTPUT_ARCH("riscv")，入口为 `_entry`，`.text`、`.rodata`、`.data`、`.bss` 四个 section 从 `0x80000000` 起依次排布，末尾提供 `end` 符号标记内核在内存中的结束位置。

**entry.S** — 汇编入口。CPU 上电后 PC = 0x80000000，第一行代码是 `_entry` 标签处的 `csrr a0, mhartid`。为每个 hart 分配独立 4KB 栈（SP = stacks + (hartid + 1) × 4096），然后 `call start` 进入 C 代码。

**start.c** — M-mode 下的最后一段代码。完成以下配置后执行 mret 降级到 S-mode 并跳入 main：

| 步骤 | 操作 | 说明 |
|------|------|------|
| 保存 hartid | `w_tp(r_mhartid())` | mhartid 只能在 M-mode 读，存到 tp 带下去 |
| 设目标模式 | `mstatus.MPP = S-mode` | 清除 bit12、置位 bit11，mret 后降级到 S-mode |
| 设目标地址 | `mepc = (uint64)main` | mret 的跳转目标 |
| 关 MMU | `satp = 0` | 裸地址翻译，lab-2 才用页表 |
| 关中断委托 | `medeleg = mideleg = sie = 0` | 暂不处理中断和异常 |
| 配 PMP | `pmpaddr0` 放行全部地址, `pmpcfg0 = 0xf` | RISC-V 默认 S-mode 无内存访问权限 |
| 执行 mret | `asm volatile("mret")` | 触发状态迁移 |

### 2. 串口驱动（UART.c）

基于 UART 的 MMIO（基地址 `0x10000000`），通过 `volatile uint8*` 指针访问硬件寄存器。

**初始化流程（uartinit）**：
```
关中断 → 开 DLAB → 写分频值（波特率 38400）→ 关 DLAB
       → 设 8N1（8数据位、无校验、1停止位）
       → 开 FIFO 并清空 → 允许发送
```

**发送字符（uartputc_sync）**：忙等 `LSR` 第 5 位（发送器空闲）为 1 后，将字符写入 `THR`。

### 3. 格式化输出（printf.c）

实现支持 **%d / %u / %x / %p / %s / %c / %%** 七种格式符的 printf 函数。

**核心函数**：

| 函数 | 功能 |
|------|------|
| `putc(c)` | 发单字符，`\n` 前自动补 `\r` |
| `printint(num, base, sign)` | 反复取模填入 buffer，逆序发送 |
| `printptr(ptr)` | 固定 16 位十六进制 + 0x 前缀 |
| `printf(fmt, ...)` | 遍历格式串，用 va_list 取可变参数 |

**va_list 机制**：通过 `va_start(ap, fmt)` 让游标指向 fmt 后的第一个参数，`va_arg(ap, type)` 按类型取出参数并自动前进游标，`va_end(ap)` 清理。

### 4. 自旋锁（spinlock.c）

**问题**：双核同时 printf 时 UART 被交替占用，输出错乱。

**方案**：在 printf 入口处加自旋锁，确保一次只有一个核独占 UART。

| 函数 | 操作 |
|------|------|
| `initlock(lk, name)` | locked = 0，记录锁名 |
| `acquire(lk)` | 关中断 → `__sync_lock_test_and_set` 原子抢锁 → `__sync_synchronize` 内存屏障 |
| `release(lk)` | `__sync_synchronize` 内存屏障 → `__sync_lock_release` 放锁 → 开中断 |

关闭中断是为了防止 "持锁者在中断处理中再次抢同一把锁导致自死锁"。

## 启动流程

```
QEMU 上电
  └→ PC = 0x80000000（kernel.ld 指定）
       └→ _entry（entry.S：读 mhartid，设栈）
            └→ start（start.c：M-mode 配置）
                 └→ mret（降级到 S-mode，跳 main）
                      └→ main（main.c：uartinit → printf）
```

## 验证结果

### 基本功能验证

双核运行 `make run`：

```
Hello, World!
Hello, OS!
```

hart 0 输出 "Hello, world!"，hart 1 输出 "Hello, os!"。双核并行执行，自旋锁确保输出不交错。

### printf 格式符测试

```
=== printf test ===
%d: -42
%u: 12345
%x: dead
%p: 0x0000000080000000
%s: hello
%c: X
%%: 100%
=== done ===
```

| 格式符 | 测试值 | 输出 | 验证 |
|--------|--------|------|------|
| `%d` | -42 | -42 | 有符号负数，通过 |
| `%u` | 12345 | 12345 | 无符号十进制，通过 |
| `%x` | 0xdead | dead | 十六进制，通过 |
| `%p` | 0x80000000 | 0x0000000080000000 | 16位指针+0x前缀，通过 |
| `%s` | "hello" | hello | 字符串，通过 |
| `%c` | 'X' | X | 单字符，通过 |
| `%%` | — | 100% | 百分号转义，通过 |

### 自旋锁验证

未加锁时 `printf("OK")` 双核输出交错（OOKK），加锁后每行完整输出不穿插。

## 文件清单

| 文件 | 功能|
|------|------|
| kernel.ld | 链接脚本 |
| entry.S | 汇编入口，栈初始化 |
| start.c | M→S 状态迁移 |
| main.c | 内核主函数 |
| UART.c / uart.h | 16550 串口驱动 |
| printf.c / printf.h | 格式化输出 |
| spinlock.c / spinlock.h | 自旋锁 |
| riscv.h | CSR 内联汇编和寄存器操作 |
| types.h | 基础类型定义 |
| Makefile | 构建系统 |