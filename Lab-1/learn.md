# Lab-1 学习笔记

## CPU 特权级

| 模式 | 权限 | 本实验角色 |
|------|------|-----------|
| M-mode | 最高，可访问所有 CSR | 启动配置，配完就让位 |
| S-mode | 次高，运行 OS 内核 | 内核主体所在的模式 |
| U-mode | 最低，运行用户程序 | 本实验未涉及 |

CPU 上电默认 M-mode。OS 内核需要降级到 S-mode 才能正常工作。

## 状态迁移：M-mode → S-mode

三个关键部件配合完成降级：

**mstatus** — 存放 CPU 状态的 CSR。MPP 字段（bit 11-12）决定 mret 后降到哪个模式：
- 11（M-mode）、01（S-mode）、00（U-mode）

**mepc** — 存放目标地址的 CSR。mret 会跳转到这个地址。设为 main 函数地址。

**mret** — 一条 CPU 指令。同时做两件事：看 MPP 降级 + 看 mepc 跳转。

## PMP（物理内存保护）

RISC-V 默认 S-mode 对物理内存无访问权限。M-mode 在离开前必须配置 PMP，给 S-mode 开放行条。

- pmpaddr0：放行的地址范围
- pmpcfg0：放行的权限（读写执行）

## 内联汇编

C 语言中通过 `asm volatile(...)` 嵌入 CPU 指令。

格式：`asm volatile("指令" : 输出列表 : 输入列表)`

- 读 CSR：`asm volatile("csrr %0, CSR名" : "=r"(变量))`
  - csrr：读 CSR 指令
  - %0：占位符，对应输出列表中第一个变量
  - "=r"：输出给 C 变量，= 表示只写
- 写 CSR：`asm volatile("csrw CSR名, %0" : : "r"(变量))`
  - csrw：写 CSR 指令
  - "r"：从 C 变量取值作为输入
- volatile：告诉编译器不要优化掉这条语句
- asm：声明内联汇编

## RISC-V 通用寄存器

CPU 内部有 32 个 64 位通用寄存器：zero(0)、ra(返回地址)、sp(栈指针)、gp、tp(线程指针)、t0-t2(临时)、a0-a7(函数参数)、s0-s11(保存寄存器) 等。

本实验中 tp 被用来从 M-mode 向 S-mode 传递 hartid。

## 链接脚本（kernel.ld）

链接脚本告诉链接器：入口在哪（_entry）、各 section 从哪开始排布（0x80000000）。

Section 顺序：.text（代码）→ .rodata（只读数据）→ .data（已初始化变量）→ .bss（未初始化变量）。

## UART 串口

通过与硬件寄存器交互来收发数据。QEMU virt 平台 UART 寄存器的 MMIO 基地址为 0x10000000。

**初始化流程**：关中断 → 设波特率（开 DLAB，写分频值，关 DLAB）→ 设 8N1 → 开 FIFO 并清空 → 允许收发。

**发送字符**：先检查 LSR 的 bit5（发送器空闲），再写入 THR。
- `uart[LSR] & LSR_TX_IDLE`：判断是否空闲
- `uart[THR] = c`：发送字符

## printf 格式化输出

**可变参数**：`printf(const char *fmt, ...)` — `...` 表示参数数量和类型不定。

**va_list 机制**：
| 宏 | 作用 |
|----|------|
| va_list | 声明一个栈上游标 |
| va_start(ap, last_fixed) | 游标定位到最后一个固定参数之后 |
| va_arg(ap, type) | 按类型取出一个参数，游标自动前进 |
| va_end(ap) | 清理游标 |

**实现要点**：遍历 fmt 字符串，普通字符直接发送，遇到 % 就根据后续字母用 va_arg 取参数，转换成字符串后逐字发送。

## 自旋锁（spinlock）

**问题**：两个核同时调用 printf，输出会交错。UART 是共享资源，一次只能一个核用。

**原理**：
```
acquire（拿锁）→ 独占使用 UART → release（放锁）
```

**acquire**：关中断 + 原子抢锁（test-and-set）。没抢到就在原地自旋等待，直到抢到为止。

**release**：放锁 + 开中断。中间的内存屏障确保所有输出完成，对其他核可见。

**原子操作**：`__sync_lock_test_and_set(&locked, 1)` 同时读旧值和写新值，不可分割。`__sync_synchronize()` 是内存屏障，确保指令顺序。

**中断保护**：acquire 前关中断，防止"持锁者等自己"的死锁。
