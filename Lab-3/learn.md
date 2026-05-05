# Lab-3 学习笔记

## 1. 中断与异常

RISC-V 把打断正常执行流的事件统称为**陷阱 (trap)**，分为两类：

- **中断 (interrupt)**：可预期的打断。比如时钟每隔若干周期 tick 一次、键盘按下触发串口中断。处理完后回到 PC+4（下一条指令）。
- **异常 (exception)**：不可预期的打断。比如非法指令、地址不对齐。处理完后回到 PC（重新执行当前指令）。

Lab-3 只涉及中断处理，不涉及异常。

## 2. 陷阱处理的完整生命周期

以时钟中断为例，每次 trap 经历三个阶段：

**陷入 (trap entry)**：CPU 硬件自动完成
- sepc ← 被打断的 PC
- scause ← 中断/异常原因码（中断的最高位=1）
- stval ← 附加信息（如访问出错的地址）
- sstatus.SPIE ← sstatus.SIE，sstatus.SIE ← 0（关中断）
- PC ← stvec（跳转到陷阱入口）

**处理 (handler)**：软件完成
- 保存全部寄存器到 trapframe
- 切换回内核栈
- 根据 scause 分支到具体处理函数
- 处理完毕

**返回 (trap return)**：sret 指令
- PC ← sepc
- sstatus.SIE ← sstatus.SPIE（恢复中断使能状态）
- 回到被打断的代码继续执行

## 3. trapframe 和 sscratch 的配合

trapframe 是每个 hart 独有的一片内存，存放被打断时的全部寄存器快照。问题在于：进入 trap 后 sp 还指向用户/内核栈，如果直接往 trapframe 存数据，需要临时覆盖 sp——但 sp 本身也要保存。

**sscratch 寄存器的妙用**：启动时把 &trapframe 塞进 sscratch。进入 trap 时一条 `csrrw sp, sscratch, sp` 同时完成"把 sp 换到 trapframe 基址"和"把旧 sp 存到 sscratch"。之后从 sscratch 取出旧 sp 写进 trapframe.sp，再把 sscratch 改存 trapframe 地址，切回内核栈去调 C 函数。返回时反过来：从 sscratch 换回 trapframe 基址，恢复所有寄存器，最后把 trapframe 地址写回 sscratch 为下一次做准备。

这个过程最容易踩的坑是：**调 C 函数前必须切回内核栈**。trapframe 只有几百字节，C 函数的调用帧会把它踩烂——这就是我之前"调完 handler 回来 freelist 全坏"的原因。

## 4. 两级时钟中断：M-mode 和 S-mode 的分工

RISC-V 的 MTIMECMP 寄存器只能在 M-mode 写，但 OS 内核跑在 S-mode。所以时钟中断需要两级协作：

```
M-mode:  timer IRQ → 更新 MTIMECMP → 置 SSIP → mret
S-mode:  software IRQ → clock_intr()
```

M-mode 的 timer_vector 是"硬件驱动层"——只管更新硬件寄存器和触发软件中断。S-mode 的 clock_intr 是"内核逻辑层"——统计 tick 数、做调度决策等。

这种"把复杂逻辑推到低特权级、高特权级只做最小必要操作"的分层思想在 OS 中很常见。

## 5. PLIC：平台级中断控制器

PLIC 是外设中断的控制器。多个外设（UART、磁盘、网卡）通过 PLIC 连接到多个 CPU hart。PLIC 负责：

- **优先级**：每个中断源一个优先级，数字大的先处理
- **阈值**：每 hart 设一个阈值，屏蔽低于该值的中断
- **分发**：同优先级时随机/轮转分给一个 hart
- **claim/complete**：hart 读 claim 寄存器得知是哪个中断；处理完写 complete 让 PLIC 知道"我处理完了"

在 QEMU virt 平台，PLIC 位于物理地址 0x0c000000，UART0 的中断号是 10。

## 6. 中断委托：mideleg 的位图

RISC-V 默认所有中断都进 M-mode。但 M-mode 只是薄薄一层"下转权"，需要把中断委托给 S-mode：

```
mideleg bit 1  = 1  →  machine software IRQ  →  S-mode software IRQ
mideleg bit 5  = 1  →  machine timer IRQ     →  S-mode timer IRQ
mideleg bit 9  = 1  →  machine external IRQ  →  S-mode external IRQ
```

但有例外：机器时钟中断（cause 7）**不能委托**，因为 S-mode 写不了 MTIMECMP。所以它留在 M-mode 由 timer_vector 处理，处理完再通过 SSIP 把控制权交回 S-mode。

另外注意：mideleg bit 和中断 cause 号不是对应关系——bit 1 对应 S-mode software（cause 1），bit 7 对应 M-mode timer（cause 7）。写 mideleg 的时候要查 spec 对好位。

## 7. sstatus.MIE 和跨特权级中断

一个容易忽略的点：即使 mie.MTIE=1（M-mode 定时器中断使能），如果 mstatus.MIE=0，从 S-mode 执行时 M-mode 定时器中断仍然不会触发。**MIE 控制 M-mode 能否打断当前执行流，哪怕当前是更低特权级**。

mret 时 MIE ← MPIE，所以必须在 M-mode 阶段把 MPIE 设为 1。我一开始没设，时钟中断死活不进来，调了半天才发现是这里卡住了。

## 8. 页表要做全：MMIO 区域也要映射

Lab-2 的页表只映射了 UART MMIO 和 128MB RAM。Lab-3 加了 PLIC 和 CLINT 的访问，如果不在内核页表里加上对等映射，第一次访问就 page fault——而且是没被处理的 exception（因为我们的 trap handler 还没处理异常），内核直接挂掉。

教训：**每加一个 MMIO 外设，就要在 kvminit 里加一行的映射**。别等到跑起来 crash 再去找"为什么读 0x0c000000 炸了"。

## 9. 用自旋等待验证时钟中断

验证中断最难的是"不确定它何时发生"。我的 test8 做法是：
- 记下当前 ticks，循环等 ticks 增加 5
- 如果等到了——证明至少 5 次时钟中断正常触发 → PASS
- 如果死循环——证明中断根本不进来 → 查 mtvec/mie/mideleg/mstatus.MIE 链

这比"printf 一行然后祈祷看到输出"可靠得多。

## 10. 为什么 printf 不能放中断处理里

clock_intr 里我本来想加 printf("tick!")，但很快就意识到不对劲：printf 要拿 spinlock、要等 UART TX 空闲、TX 可能触发新的中断——在中断上下文中做这些事是死锁和栈溢出的最佳配方。中断处理函数的铁律：**快进快出，别搞复杂逻辑**。要记录什么，最好的方式就是 `ticks++` 然后在大循环里检查。
