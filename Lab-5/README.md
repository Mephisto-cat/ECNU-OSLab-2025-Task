# Lab-5 用户态虚拟内存管理 + 系统调用流程建立

本实验在 Lab-4 第一个用户态进程 `proczero` 的基础上，补全了用户态和内核态的数据迁移、用户堆和用户栈管理、`mmap_region_node` 仓库、`mmap/munmap` 以及用户页表复制与销毁的基础函数。

先使用数据迁移部分的用户程序进行验证，运行结果和 `picture/test-1.png` 一致：

```text
cpu 0 is booting!
cpu 1 is booting!
get a number from user: 1
get a number from user: 2
get a number from user: 3
get a number from user: 4
get a number from user: 5
get string for user: hello, world
```

## 实验目标

本实验的核心目标是打通下面这条执行链：

```text
用户程序
  -> syscall 宏写入 a0~a7
  -> ecall 进入内核
  -> user_vector 保存用户现场
  -> trap_user_handler 识别 U-mode ecall 或 page fault
  -> syscall 根据 a7 分发系统调用
  -> 系统调用读写用户页表和用户地址空间
  -> trap_user_return 返回用户态
```

这条链路把用户页表、trapframe、系统调用参数传递、堆区增长、栈自动扩展和离散 mmap 区域串在一起。

## 模块清单

| 目录 | 作用 |
| --- | --- |
| `src/kernel/boot` | 完成最早期启动流程，从机器态进入内核态。 |
| `src/kernel/arch` | 封装 RISC-V 寄存器、CSR 和常量定义。 |
| `src/kernel/mem` | 管理物理页、页表、用户堆、用户栈、`mmap_region` 链表，以及用户/内核空间数据拷贝。 |
| `src/kernel/proc` | 描述进程结构，保存用户页表、堆顶、用户栈页数、`mmap` 链表、trapframe、内核栈和上下文。 |
| `src/kernel/syscall` | 维护系统调用号到内核服务函数的跳转表，并提供参数读取辅助函数。 |
| `src/kernel/trap` | 处理内核态和用户态 trap，包括 U-mode `ecall`、用户态 page fault、时钟中断和 UART 中断。 |
| `src/kernel/lock` | 提供自旋锁和中断开关的嵌套管理。 |
| `src/kernel/lib` | 提供打印、串口、断言、内存拷贝和字符串比较等基础工具。 |
| `src/user` | 存放用户程序 `initcode`、用户态系统调用入口和系统调用号。 |

## 代码改动概览

### 数据迁移

`src/kernel/mem/uvm.c`

- `uvm_copyin()`：按用户页表把用户空间数据拷贝到内核空间。
- `uvm_copyout()`：按用户页表把内核空间数据拷贝到用户空间。
- `uvm_copyin_str()`：从用户空间拷贝字符串，最多读取指定长度。

`src/kernel/syscall/sysfunc.c`

- `sys_copyout()` 向用户数组写出 `{1, 2, 3, 4, 5}`。
- `sys_copyin()` 读取用户数组并逐行输出 `get a number from user: X`。
- `sys_copyinstr()` 读取用户字符串并输出 `get string for user: ...`。

### 堆和栈

`src/kernel/syscall/sysfunc.c`

- `sys_brk(0)` 查询当前堆顶，输出 `look event`。
- `sys_brk(new_heap_top)` 根据新旧堆顶关系输出 `grow event`、`equal event` 或 `ungrow event`。
- 每次 `brk` 事件后调用 `vm_print()` 打印页表，便于观察堆页映射变化。

`src/kernel/mem/uvm.c`

- `uvm_heap_grow()` 为新增堆页申请物理页并建立用户映射。
- `uvm_heap_ungrow()` 释放不再被堆顶覆盖的用户页。
- `uvm_ustack_grow()` 在 13/15 号 page fault 时按需向下扩展用户栈。

`src/kernel/trap/trap_user.c`

- page fault 时输出：

```text
page fault occured! trap id = 15
ustack_npage: 1 -> 2
```

### mmap 节点仓库

`src/kernel/mem/mmap.c`

- `mmap_init()` 初始化 `node_list[N_MMAP]`、空闲链表和自旋锁。
- `mmap_region_alloc()` 从仓库申请一个 `mmap_region_t`。
- `mmap_region_free()` 清空并归还一个 `mmap_region_t`。
- `mmap_show_nodelist()` 打印空闲节点链表，用来观察节点仓库状态。

### mmap 与 munmap

`src/kernel/mem/uvm.c`

- `uvm_mmap()` 支持指定地址映射和 `begin == 0` 自动寻找第一块足够大的空洞。
- 新映射区域插入进程 `mmap` 链表后，会和左右相邻区域合并。
- `uvm_munmap()` 支持整段释放、释放前段、释放后段、释放中间段并拆分节点。

`src/kernel/syscall/sysfunc.c`

- `sys_mmap()` 和 `sys_munmap()` 每次操作后都会输出：

```c
uvm_show_mmaplist(p->mmap);
vm_print(p->pgtbl);
printf("\n");
```

### 页表复制与销毁

`src/kernel/mem/uvm.c`

- `uvm_destroy_pgtbl()` 先解除 `TRAPFRAME` 和 `TRAMPOLINE`，再递归释放页表页和用户物理页。
- `uvm_copy_pgtbl()` 拷贝代码/堆区域、用户栈区域和所有 `mmap` 区域，为后续实验的进程复制做准备。

## 实验验证

### 测试 1：用户态和内核态的数据迁移

我使用下面的用户程序检查数组和字符串能否在用户态、内核态之间正确迁移：

```c
int main() {
    int L[5];
    char *s = "hello, world";

    syscall(SYS_copyout, L);
    syscall(SYS_copyin, L, 5);
    syscall(SYS_copyinstr, s);

    while (1)
        ;
    return 0;
}
```

关键输出：

```text
get a number from user: 1
get a number from user: 2
get a number from user: 3
get a number from user: 4
get a number from user: 5
get string for user: hello, world
```

### 测试 2：堆的手动管理

我用 `SYS_brk` 依次完成查询堆顶、增长 9 页、保持不变、缩小 5 页四种情况。`sys_brk()` 会输出 `look/grow/equal/ungrow event`，并在每次事件后打印页表。

### 测试 3：栈的自动管理

我在用户程序里定义跨越多页的非静态数组，通过访问数组高地址和低地址触发栈增长。用户栈访问未映射页时会触发 15 号异常，`trap_user_handler()` 会打印 page fault 和栈页数变化。

### 测试 4：mmap_region_node 仓库

我用两个 CPU 同时申请并归还 `mmap_region_node`，检查自旋锁能否保护全局节点仓库。初始链表输出从 `node 0 index = 0` 递增到 `node 255 index = 255`；申请释放后，可以看到两组节点交替归还。

### 测试 5：mmap 与 munmap

我用一组交错的 `SYS_mmap/SYS_munmap` 调用检查链表插入、合并、拆分和释放，输出表现为：

- 映射区按地址有序插入。
- 相邻映射区自动合并。
- 释放中间区间时拆成左右两段。
- 最后一次 `munmap` 后显示 `empty`。

链表变化的关键过程如下。最开始只有一段：

```text
allocated mmap_region: 0x0000003ffb002000 ~ 0x0000003ffb005000
```

多次相邻映射后合并为：

```text
allocated mmap_region: 0x0000003ffaffe000 ~ 0x0000003ffb015000
```

最后释放为空：

```text
allocated mmap_space:
empty
```

## 地址布局

```text
TRAMPOLINE             trampoline 汇编代码
TRAPFRAME              保存用户寄存器的 trapframe
TRAPFRAME - PGSIZE     初始用户栈
MMAP_END ~ TRAPFRAME   用户栈增长保留区
MMAP_BEGIN ~ MMAP_END  mmap 映射区
heap_top               用户堆顶，向高地址增长
USER_BASE              用户程序 initcode
0x0 ~ USER_BASE        留空，捕获空指针访问
```

## 构建和运行

```bash
cd Lab-5
make clean
make build
make run
```

`initcode.h` 是构建时自动生成的文件：

```text
src/user/initcode.c -> build/initcode -> src/user/initcode.h
```

## 本地验证

为了避免手动来回修改 `initcode.c` 和 `main.c`，我写了一个脚本依次运行五个测试点：

```bash
./run_all_tests.sh
```

脚本会自动写入每个测试对应的用户程序或内核入口，运行后检查关键输出，最后恢复原来的 `initcode.c` 和 `main.c`。每个测试的完整输出保存在 `test-logs/` 目录中。

每个测试点都使用对应的用户程序或内核入口进行验证，运行方式相同：

```bash
make clean
timeout 5s make run
```

### 测试 1：用户态和内核态的数据迁移

关键输出如下，说明 `copyout` 写入用户数组、`copyin` 读回用户数组、`copyinstr` 读取用户字符串均正常：

```text
===== make success! =====
cpu 0 is booting!
cpu 1 is booting!
get a number from user: 1
get a number from user: 2
get a number from user: 3
get a number from user: 4
get a number from user: 5
get string for user: hello, world
```

### 测试 2：堆的手动管理

关键输出分为四段：先查询当前堆顶，再增长 9 页，再保持堆顶不变，最后缩小 5 页。每一步之后打印页表，用来确认新增页面被映射、释放页面被取消映射。

```text
look event: ret_heap_top = 0x0000000000002000
grow event: ret_heap_top = 0x000000000000b000
equal event: ret_heap_top = 0x000000000000b000
ungrow event: ret_heap_top = 0x0000000000006000
```

### 测试 3：栈的自动管理

用户程序访问跨页局部数组时触发栈缺页异常，内核识别 15 号异常后扩展用户栈：

```text
page fault occured! trap id = 15
ustack_npage: 1 -> 2
get string for user: hello
page fault occured! trap id = 15
ustack_npage: 2 -> 5
get string for user: world
```

### 测试 4：mmap_region_node 仓库

初始状态下，仓库空闲链表按顺序输出：

```text
node 0 index = 0
node 1 index = 1
...
node 255 index = 255
```

双核申请并释放后，两个 CPU 归还的节点交替进入空闲链表，可以看到一组 index 从 255 向 128 递减，另一组从 127 向 0 递减。

### 测试 5：mmap 与 munmap

`mmap` 测试中，离散映射会按地址顺序插入，并在相邻时合并。关键链表变化如下：

```text
allocated mmap_region: 0x0000003ffb002000 ~ 0x0000003ffb005000
allocated mmap_region: 0x0000003ffb000000 ~ 0x0000003ffb00b000
allocated mmap_region: 0x0000003ffaffe000 ~ 0x0000003ffb015000
```

`munmap` 测试中，释放区间会缩短节点、删除节点或把节点拆成两段。最后所有映射释放完成：

```text
allocated mmap_space:
empty
```

`timeout` 结束 QEMU 时会出现如下信息，这是因为用户程序最终停在 `while (1)` 中，属于预期行为：

```text
qemu-system-riscv64: terminating on signal 15 from pid ... (timeout)
```
