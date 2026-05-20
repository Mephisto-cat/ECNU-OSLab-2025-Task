# Lab-4 第一个用户态进程的诞生

本实验完成了第一个用户进程 `proczero` 的创建、运行、系统调用响应，以及用户态下的时钟中断和串口中断响应。最终效果是用户程序先执行两次 `SYS_helloworld` 系统调用，然后停在用户态循环中等待中断；内核能够正确处理系统调用、连续 5 次用户态时钟中断和 UART 输入中断，并输出测试通过信息：

```text
proczero: hello world!
proczero: hello world!
[test1] syscall test passed
[test2] waiting for 5 U-mode timer interrupts before UART test...
[test2] U-mode timer interrupt 1/5 -> trap_user_handler -> return proczero
[test2] U-mode timer interrupt 2/5 -> trap_user_handler -> return proczero
[test2] U-mode timer interrupt 3/5 -> trap_user_handler -> return proczero
[test2] U-mode timer interrupt 4/5 -> trap_user_handler -> return proczero
[test2] U-mode timer interrupt 5/5 -> trap_user_handler -> return proczero
[test2] UART interrupt is ready, press some keys...
[UART intr] received: 'a'
[UART intr] received: 'b'
[UART intr] received: 'c'
[test2] UART interrupt test passed
[test] === ALL TESTS PASSED ===
```

## 实验目标

本实验的核心目标是打通下面这条执行链：

```text
内核初始化
  -> 创建 proczero
  -> 建立用户页表和用户地址空间
  -> 通过 swtch 切换到 proczero 的内核态上下文
  -> 通过 trap_user_return 返回用户态
  -> 用户程序执行 ecall
  -> user_vector 保存用户现场
  -> trap_user_handler 处理系统调用和用户态中断
  -> 再次返回用户态
```

这条链路把 PCB、页表、trapframe、context、trampoline 和 syscall 串在一起，是本实验的主线。

## 模块清单

| 目录 | 作用 |
| --- | --- |
| `src/kernel/boot` | 完成最早期启动流程，从机器态进入内核态，并准备进入 `main` 所需的基础环境。 |
| `src/kernel/arch` | 封装 RISC-V 寄存器、CSR 和常量定义，是内核读写硬件状态的接口层。 |
| `src/kernel/mem` | 管理物理页和页表，为内核映射、用户页表、用户代码页、用户栈页和 trapframe 提供内存基础。 |
| `src/kernel/proc` | 描述进程结构，保存用户页表、用户栈、trapframe、内核栈和上下文，并负责创建第一个用户进程。 |
| `src/kernel/trap` | 处理内核态和用户态 trap，包括系统调用、时钟中断、PLIC 外部中断、UART 中断和 trampoline 切换。 |
| `src/kernel/lock` | 提供自旋锁和中断开关的嵌套管理，用来保护内核中的共享状态。 |
| `src/kernel/lib` | 提供打印、串口、断言和常用工具函数，支撑内核调试和基础输入输出。 |
| `src/user` | 存放第一个用户程序 `initcode`、系统调用号和用户态系统调用入口。 |

## 代码改动概览

### 基础设施

`src/kernel/boot/start.c`

- 设置 `medeleg` 和 `mideleg`，将异常和 S-mode 中断委托给 S-mode。
- 初始化 M-mode 时钟中断。
- 设置 `mepc = main`，通过 `mret` 进入 S-mode 内核。

`src/kernel/mem/pmem.c`

- 实现物理页初始化、分配和释放。
- 将可分配物理页分成内核区域和用户区域。

`src/kernel/mem/kvm.c`

- 实现三级页表查询、映射和取消映射。
- 映射 UART、PLIC、CLINT、内核内存、`TRAMPOLINE` 和 `KSTACK(0)`。

`src/kernel/lock/spinlock.c`

- 实现自旋锁。
- 实现带嵌套计数的关中断和开中断逻辑。

`src/kernel/lib/print.c`

- 实现 `printf`、`panic` 和 `assert`。

### 进程创建

`src/kernel/proc/proc.c`

`proc_pgtbl_init()` 用来创建用户页表，并建立两条用户态 trap 必需的映射：

```text
TRAMPOLINE -> trampoline
TRAPFRAME  -> proczero.tf
```

`proc_make_first()` 用来创建第一个用户进程 `proczero`：

- 分配 trapframe。
- 创建用户页表。
- 分配用户代码页和用户栈页。
- 将 `initcode` 拷贝到 `USER_BASE`。
- 设置用户态入口地址和用户栈顶。
- 设置进程内核栈和 `context`。
- 通过 `swtch()` 切换到 `trap_user_return()`。

### 用户态 trap 和 syscall

`src/kernel/trap/trap_user.c`

`trap_user_return()` 负责从内核态返回用户态：

- 设置 `stvec = user_vector`。
- 在 trapframe 中保存内核页表、内核栈、handler 和 hartid。
- 设置 `sepc` 为用户程序入口。
- 设置 `sstatus.SPP = 0`，使 `sret` 返回 U-mode。
- 跳到 trampoline 中的 `user_return`。

`trap_user_handler()` 负责处理用户态进入内核后的 trap：

- 保存用户态 PC。
- 处理用户态时钟中断和外部中断。
- 识别 U-mode `ecall`。
- 根据 `a7` 中的系统调用号处理 `SYS_helloworld`。
- 将 `sepc` 加 4，避免返回用户态后重复执行同一条 `ecall`。

## 关键逻辑链

### 1. 内核启动

系统从 M-mode 进入 `start()`，完成中断委托、时钟初始化和权限设置，然后通过 `mret` 进入 S-mode 的 `main()`。

```text
start
  -> 设置委托
  -> timer_init
  -> 设置 mepc = main
  -> mret
```

### 2. 内核初始化

`main()` 中先完成基础设施初始化：

```text
print_init
  -> pmem_init
  -> kvm_init
  -> kvm_inithart
  -> trap_kernel_init
  -> trap_kernel_inithart
```

这些步骤完成后，内核已经可以分配页、使用页表、处理中断。

### 3. 创建 proczero

`proc_make_first()` 创建 `proczero` 的 PCB，并建立用户地址空间：

```text
USER_BASE              initcode 用户代码页
TRAPFRAME - PGSIZE     用户栈页
TRAPFRAME              用户现场保存页
TRAMPOLINE             用户态和内核态切换代码
```

最低一页不映射，用来捕获空指针访问。

### 4. context 切换

`proczero.ctx.ra` 被设置为 `trap_user_return`，`proczero.ctx.sp` 被设置为进程内核栈顶。

```text
proc_make_first
  -> swtch
  -> trap_user_return
```

这里的 `swtch` 只发生在 S-mode 内部，用来从内核主执行流切到进程的内核态执行流。

### 5. 返回用户态

`trap_user_return()` 设置好用户态返回环境后，调用 trampoline 中的 `user_return`。

这里传给 `user_return` 的 trapframe 地址使用 `TRAPFRAME`，也就是用户页表中的虚拟地址。`user_return` 会切换到用户页表，切换后仍然需要继续读取 trapframe。

```text
trap_user_return
  -> user_return
  -> 切换用户页表
  -> 恢复用户寄存器
  -> sret
```

### 6. 用户态执行系统调用

用户程序来自 `src/user/initcode.c`：

```c
syscall(SYS_helloworld);
syscall(SYS_helloworld);
while (1)
    ;
```

`syscall()` 最终执行 `ecall`。CPU 根据 `stvec` 跳转到 `user_vector`。

### 7. 用户态 trap 进入内核

`user_vector` 保存用户寄存器，并恢复内核环境：

```text
保存用户寄存器到 trapframe
恢复内核栈
恢复 hartid
切换到内核页表
跳转到 trap_user_handler
```

`trap_user_handler()` 识别异常号 8，即 U-mode `ecall`，然后根据 `a7` 中的系统调用号执行对应处理。

```text
ecall
  -> user_vector
  -> trap_user_handler
  -> SYS_helloworld
  -> printf
  -> trap_user_return
```

### 8. 用户态中断测试

用户程序执行完两次系统调用后停在 U-mode 的 `while (1)` 中。此时发生的时钟中断和串口中断都会从用户态进入 `user_vector`，再进入 `trap_user_handler()`。

时钟中断测试路径：

```text
U-mode while(1)
  -> timer interrupt
  -> user_vector
  -> trap_user_handler
  -> timer_interrupt_handler
  -> [test2] U-mode timer interrupt -> trap_user_handler -> return U-mode
  -> trap_user_return
```

串口中断测试路径：

```text
U-mode while(1)
  -> 键盘输入
  -> UART RX interrupt
  -> user_vector
  -> trap_user_handler
  -> user_external_interrupt_handler
  -> [test2] U-mode UART RX interrupt -> trap_user_handler
  -> trap_user_return
```

Lab-4 使用两个 CPU 运行，但第一个用户进程 `proczero` 在 CPU0 上运行。为了让键盘输入稳定地经过用户态 trap 路径，PLIC 的 UART 中断只打开给 CPU0。否则 CPU1 也可能在内核态抢先 claim UART 中断，字符会被内核态串口处理函数读走，用户态测试就会出现延迟或漏计数。

## 地址布局

```text
TRAMPOLINE             trampoline 汇编代码
TRAPFRAME              保存用户寄存器的 trapframe
TRAPFRAME - PGSIZE     用户栈
USER_BASE              用户程序 initcode
0x0 ~ USER_BASE        留空，捕获空指针访问
```

## 构建和运行

```bash
cd Lab-4
make clean
make build
make run
```

`initcode.h` 是构建时自动生成的文件：

```text
src/user/initcode.c -> build/initcode -> src/user/initcode.h
```

VS Code 提示 `#include "../../user/initcode.h"` 找不到时，先执行一次 `make build`。

## 测试结果

本地测试命令：

```bash
make clean
make run
```

测试流程分成三段：

```text
测试一: 用户程序连续发出两次 SYS_helloworld
测试二-1: 用户程序停在 while(1)，等待 5 次用户态时钟中断
测试二-2: 按键输入，验证用户态串口中断
```

关键输出：

```text
===== make success! =====
cpu 0 is booting!
cpu 1 is booting!
proczero: hello world!
proczero: hello world!
[test1] syscall test passed
[test2] --- user interrupt system ---
[test2] waiting for 5 U-mode timer interrupts before UART test...
[test2] U-mode timer interrupt 1/5 -> trap_user_handler -> return proczero
[test2] U-mode timer interrupt 2/5 -> trap_user_handler -> return proczero
[test2] U-mode timer interrupt 3/5 -> trap_user_handler -> return proczero
[test2] U-mode timer interrupt 4/5 -> trap_user_handler -> return proczero
[test2] U-mode timer interrupt 5/5 -> trap_user_handler -> return proczero
[test2] timer interrupt test passed, enter UART interrupt test
[test2] UART interrupt is ready, press some keys...
```

此时按下键盘，可以看到每个字符都会像 Lab-3 一样被 UART 中断立即接收并打印。测试以前 3 个接收到的字符作为通过条件，后续继续输入也会继续走同一条 UART 中断路径。

```text
[UART intr] received: 'a'
[UART intr] received: 'b'
[UART intr] received: 'c'
[test2] UART interrupt test passed
[test] === ALL TESTS PASSED ===
```

Lab-4 目前只有第一个用户进程 `proczero`，还没有进程调度实验里的下一个用户进程。因此时钟中断测试通过后进入下一项 UART 中断测试，而不是切换到另一个进程。最后 QEMU 仍会保持运行。
