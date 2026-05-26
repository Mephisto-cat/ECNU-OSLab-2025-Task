# Lab-6 进程管理模块

本实验在 Lab-5 用户态虚拟内存、系统调用和 trap 流程的基础上，补全了从单进程到多进程需要的进程数组、调度器、`fork/wait/sleep/exit` 生命周期管理、基于时钟中断的抢占式调度，以及后续文件系统会用到的睡眠锁。

## 实验目标

本次实验完成下面几条执行链：

```text
内核启动
  -> 初始化物理内存、mmap 节点仓库、进程数组、内核页表、trap
  -> 创建 proczero
  -> 进入 proc_scheduler 调度循环
```

```text
用户进程
  -> ecall 进入内核
  -> syscall 分发 fork/wait/sleep/exit 等系统调用
  -> 进程状态在 RUNNING/RUNNABLE/SLEEPING/ZOMBIE/UNUSED 之间切换
  -> swtch 在进程上下文和 CPU 调度器上下文之间切换
```

```text
时钟中断
  -> timer_update 更新 ticks
  -> 唤醒等待 sys_timer 的进程
  -> 当前进程 proc_yield 让出 CPU
```

## 主要实现

### 进程数组和调度

`src/kernel/proc/proc.c` 维护 `proc_list[N_PROC]`、`global_pid` 和 `proczero`：

- `proc_init()` 初始化进程仓库、PID 锁和 wait 锁。
- `proc_alloc()` 申请 `UNUSED` PCB，分配 trapframe 和用户页表，并把 `ctx.ra` 设置为 `proc_return`。
- `proc_free()` 释放用户页表、用户物理页、mmap 描述节点和 PCB 元数据。
- `proc_make_first()` 创建第一个用户进程，只把它设为 `RUNNABLE`，不再直接 `swtch`。
- `proc_scheduler()` 循环扫描 `RUNNABLE` 进程，切换到进程上下文运行。
- `proc_sched()` 从进程上下文切回 CPU 调度器上下文。

`src/kernel/main.c` 初始化完成后进入 `proc_scheduler()`，两个 CPU 都参与调度。

### fork / wait / exit

- `proc_fork()` 深拷贝父进程的 trapframe、代码/堆/栈页、mmap 区域和 mmap 链表，子进程返回值设置为 `0`，父进程得到子进程 PID。
- `proc_exit()` 不直接释放自己，而是设置 `ZOMBIE` 和 `exit_code`，唤醒父进程后切回调度器。
- `proc_wait()` 扫描子进程，发现 `ZOMBIE` 后复制退出码到用户空间并回收子进程；没有僵尸子进程时睡眠在父进程自身地址上。
- 父进程退出时，未退出的子进程会过继给 `proczero`。

### sleep / wakeup / sleeplock

- `proc_sleep()` 设置睡眠资源并切回调度器。
- `proc_wakeup()` 唤醒所有等待同一资源的睡眠进程。
- `timer_wait()` 让进程睡眠指定 tick 数，时钟中断更新 ticks 后唤醒检查。
- `src/kernel/lock/sleeplock.c` 基于自旋锁和 `proc_sleep/proc_wakeup` 实现睡眠锁。

### 时钟中断抢占

`src/kernel/trap/trap_user.c` 和 `src/kernel/trap/trap_kernel.c` 在处理时钟中断后调用 `proc_yield()`，把当前运行进程从 `RUNNING` 改回 `RUNNABLE`，实现简单时间片轮转。

### 系统调用

新增并接入以下系统调用：

```c
SYS_print_str
SYS_print_int
SYS_getpid
SYS_fork
SYS_wait
SYS_exit
SYS_sleep
```

## 构建和运行

```bash
cd Lab-6
make clean
make build
make run
```

```text
cpu 0 is booting!
cpu 1 is booting!

proczero: hello world!
```

## 测试

脚本 `run_all_tests.sh`，会自动替换 `src/user/initcode.c`，逐个构建运行测试，最后恢复原文件。每个测试都会把 QEMU 原始输出保存到 `test-logs/`，终端也会同步打印。

```bash
cd Lab-6
./run_all_tests.sh
```

本地验证结果：

```text
PASS: test-1
PASS: test-2
PASS: test-3
PASS: test-4
All tests passed.
```

日志文件说明：`test-logs/test-1.log` 到 `test-logs/test-4.log` 是 QEMU 原始输出，便于复查完整运行过程。

测试 1：

```text
cpu 0 is booting!
cpu 1 is booting!

proczero: hello world!
```

测试 2：

```text
cpu 0 is booting!
cpu 1 is booting!
proc 1 is running...
level-1!
proc 2 is running...
level-2!
level-2!
level-3!
level-3!
proc 3 is running...
level-3!
proc 4 is running...
level-3!
```

测试 3：

```text
--------test begin--------
child proc: hello!
MMAP_REGION
HEAP_REGION
STACK_REGION

parent proc: hello!
num = 2
good boy!
--------test end----------
```

测试 4：

```text
Ready to sleep!
proc 2 is sleeping!
...
proc 2 is wakeup!
Ready to exit!
proc 1 is wakeup!
Child exit!
```

测试覆盖：

- 测试 1：`getpid` 和 `print_str`，验证 proczero 能进入用户态。
- 测试 2：连续两次 `fork`，验证进程复制、调度和输出次数，预期 `level-1/2/3` 分别出现 `1/2/4` 次。
- 测试 3：`fork + wait + exit`，并在 fork 前写入 mmap、heap、stack，验证地址空间深拷贝和退出码回收。
- 测试 4：子进程 `sleep(30)` 后退出，父进程 `wait`，验证时钟睡眠、唤醒和僵尸回收。

## 注意点

- PCB 的共享字段需要在持有进程锁时读写。
- `proc_sleep()` 醒来后先重新获得原锁，再释放进程锁，避免在返回用户态前打开中断造成错误的 trap 入口。
- `proczero` 永不退出，用作孤儿进程的最终父进程。
