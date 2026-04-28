# Lab-1: 机器启动、UART、printf、自旋锁

一个运行在 QEMU RISC-V 64 位平台上的最小裸机内核。从 CPU 上电开始，完成栈设置、权限降级（M-mode → S-mode）、串口驱动、格式化输出、多核互斥锁。

## 文件

| 文件 | 做什么 |
|------|--------|
| `kernel.ld` | 链接脚本，入口 `_entry`，加载到 `0x80000000` |
| `entry.S` | 汇编入口，给每个 hart 分配栈，跳 C |
| `start.c` | M-mode 下配 PMP/MPP/mepc，`mret` 进 S-mode |
| `main.c` | 初始化 UART，printf 输出验证信息 |
| `UART.c` | 16550 UART 驱动，初始化 + 忙等发送 |
| `printf.c` | 自实现的 `printf`（%d %u %x %p %s %c） |
| `spinlock.c` | 自旋锁，关中断 + GCC 原子内置 |
| `riscv.h` | CSR 读写内联汇编（mstatus/mepc/satp/PMP） |
| `types.h` | uint8/uint32/uint64/int64 |

## 启动流程

```
CPU 上电 → _entry (设栈) → start (M-mode 降级) → main (S-mode)
                                                    │
                                              uartinit → printf → 终端
```

## 构建与运行

需要 riscv64 交叉编译工具链和 qemu-system-riscv64。

```bash
make        # 编译生成 kernel-qemu.elf 和 kernel.asm
make run    # 在 QEMU 中启动（双核，串口输出到终端）
make clean  # 清理
```

预期输出：

```
Lab1 kernel entered main() on hart 0
Lab1 kernel entered main() on hart 1
Hello, world from S-mode!
Hello, world from S-mode!
UART MMIO base = 0x0000000010000000
UART MMIO base = 0x0000000010000000
This printf is protected by a spinlock.
This printf is protected by a spinlock.
```
