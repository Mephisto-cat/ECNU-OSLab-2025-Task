# Lab-2 内存管理初步

## 实验目标

在 Lab-1 的基础上实现：

1. **物理页分配器** — 基于空闲链表的物理页管理（4KB 粒度）
2. **内核页表** — 基于 Sv39 三级页表的虚拟内存管理（对等映射）

## 新增文件

| 文件 | 功能 |
|---|---|
| `page.h` | 页大小、Sv39 三级索引、PTE 标志位、地址转换宏 |
| `memlayout.h` | 物理内存布局常量（UART=0x10000000, RAM=0x80000000~0x88000000）|
| `kalloc.h` | 物理页分配器接口声明 |
| `kalloc.c` | 空闲链表实现：`kinit` / `kalloc` / `kfree`，spinlock 保护 |
| `vm.h` | 内核页表接口声明 |
| `vm.c` | Sv39 页表遍历与映射：`walk` / `kvmmap` / `kvminit` / `kvminithart` |

## 改动文件

| 文件 | 改动 |
|---|---|
| `riscv.h` | 新增 `r_satp()` / `w_satp()` / `sfence_vma()` |
| `kernel.ld` | 新增 `PROVIDE(end = .)` 标记内核占用的内存边界 |
| `start.c` | mret 前关闭 MMU 和中断委托 |
| `Makefile` | OBJS 增加 `kalloc.o vm.o` |
| `main.c` | 7 项测试覆盖全部功能 |

## 架构设计

### 物理内存管理

```
空闲链表（freelist）: 每个空闲 4KB 页的前 8 字节复用为链表指针

  freelist → [页N] → [页N+1] → [页N+2] → ... → NULL

kalloc(): 从表头摘下 → O(1)，分配后清零
kfree():  插回表头     → O(1)，含安全检查（对齐+范围）
```

`kinit()` 从链接脚本导出的 `end` 符号（内核 .bss 之后）开始，到 `PHYSTOP`（128MB），把所有页加入空闲链表。spinlock 保证多核并发安全。

### 虚拟内存管理

```
Sv39 三级页表，对等映射（va == pa）:

虚拟地址: | L2 索引 (9b) | L1 索引 (9b) | L0 索引 (9b) | 页内偏移 (12b) |

walk():    遍历三级页表到叶子 PTE，alloc=1 时按需分配中间页表
kvmmap():  逐页填写 PTE，建立 va→pa 映射
kvminit(): cpu 0 创建内核页表（映射 UART + 128MB RAM）
kvminithart(): 各 cpu 将根页表地址写入 satp 寄存器
```

## 运行方法

```bash
cd Lab-2
make clean && make        # 编译（0 警告）
make run                  # QEMU 运行（-smp 2 双核）
```

## 测试结果

| # | 测试项 | 验证内容 | 结果 |
|---|---|---|---|
| 1 | 基本分配/释放 | kalloc 返回非空、地址不同、kfree 正常 | PASS |
| 2 | 释放复用 | 释放后重新分配拿到同一页（LIFO）| PASS |
| 3 | 清零 | 新分配页全零；写脏释放再分配仍然全零 | PASS |
| 4 | 非法地址 | 不对齐/越界地址的 kfree 被静默拒绝 | PASS |
| 5 | 内存耗尽 | 分配 32689 页后 kalloc 返回 NULL | PASS |
| 6 | 耗尽回收 | 释放后 kalloc 恢复可用，LIFO 顺序正确 | PASS |
| 7 | 对等映射 | satp 为 Sv39 模式，开启分页后代码正常执行 | PASS |


## 测试详解

### test1 基本分配/释放

```c
void *p1 = kalloc();
void *p2 = kalloc();
// 断言: p1≠0, p2≠0, p1≠p2  — 两个不同的有效页
kfree(p1);
kfree(p2);
```

验证 `kalloc` 返回的是真实可用的物理地址，且连续两次分配不重叠。`kfree` 正常返回无崩溃。

### test2 释放后复用

```c
// 先分配 p2 再分配 p1，释放顺序 p1→p2 (p2 最后释放)
// 再分配 p3，断言: p3 == p2  — LIFO
```

验证空闲链表的后进先出（LIFO）性质。头插法 + 头取法决定了最后释放的页最先被再次分配。

### test3 清零

```c
char *zp = kalloc();
// 遍历 4096 字节，统计非零 → 期望 0

// 写脏整页
for (int i = 0; i < PGSIZE; i++) zp[i] = 0xFF;
kfree(zp);
zp = kalloc();
// 再次统计非零 → 期望仍然 0
```

两阶段验证：首次分配全零，且释放后再分配依然全零。第二阶段排除了"只因为从未被用过才全零"的可能——上一任用户写入的数据在新分配时被彻底擦除。安全意义：不留数据泄露隐患。

### test4 非法地址防御

```c
kfree((void *)0x80001001);  // 不对齐的地址
kfree((void *)0x80000000);  // 在内核代码段里
kfree((void *)0x88000000);  // 刚好等于 PHYSTOP，越界
// 断言: 之后 kalloc 依然返回非空 — freelist 未被破坏
```

验证 `kfree` 的三段式校验逻辑：不对齐、低于 end 符号（在内核区域）、高于等于 PHYSTOP。三项非法输入全部被静默丢弃，释放链表完好。

### test5 内存耗尽

```c
int count = 0;
while (1) {
    void *q = kalloc();
    if (q == 0) break;
    count++;
}
// 断言: count > 1000
```

验证分配器在资源耗尽时返回 NULL 而不是 crash。Lab-2 实际值约 32689 页（128MB 减去内核自身占用的几页）。

### test6 耗尽回收

```c
// 在 test5 耗尽后
void *check = kalloc();
// 断言: check == 0  — 真的一滴都没有了

kfree(saved[2]); kfree(saved[1]);
void *r1 = kalloc();
void *r2 = kalloc();
// 断言: r1 == saved[1], r2 == saved[2]  — 精确 LIFO 顺序
```

验证两个边界：耗尽后确实返回 NULL；任意释放后立刻恢复可用，且 LIFO 顺序精确。`saved[0]` 先分配先保留，被留在 freelist 里最后才被拿到，不参与 LIFO 比较——只有后两个释放的才按顺序验证。

### test7 对等映射

```c
uint64 satp = r_satp();
// 断言: (satp >> 60) == 8  — Sv39 模式
printf("printf after paging ON proves identity map works\n");
```

读 satp 断言 mode==8，然后用 printf 输出。printf 内部调用 `my_put`，通过 `volatile uint8 *uart` 访问 UART MMIO 地址——能正常输出本身就证明 Sv39 页表的对等映射让虚拟地址等于物理地址，内核代码和数据的访问全部走 MMU 翻译后正确命中。


## 关键输出

```
cpu 0 is booting
cpu 1 is booting
[cpu 0] kinit: free list built from 0x80000000 to 0x88000000
[cpu 0] kvminit: kernel page table at 0x87fff000
[cpu 0] kvminithart: satp = 0x8000000000087fff, paging enabled
[cpu 0] --- test1~7 ---
[cpu 0] === ALL TESTS PASSED ===
```

## 所有输出
```
cpu 0 is booting
cpu 1 is booting
[cpu 0] kinit: free list built from 0x0000000080000000 to 0x0000000088000000
[cpu 0] kvminit: kernel page table at 0x0000000087fff000
[cpu 0] kvminithart: satp = 0x8000000000087fff, paging enabled
[cpu 1] kvminithart: satp = 0x8000000000087fff, paging enabled
[cpu 0] --- test1: basic alloc/free ---
[cpu 0] alloc  p1=0x0000000087fbb000 p2=0x0000000087fba000
[cpu 0] expect: p1≠0, p2≠0, p1≠p2
[cpu 0] free   p1=0x0000000087fbb000 p2=0x0000000087fba000
[cpu 0] --- test2: reuse after free ---
[cpu 0] re-alloc after free: p3=0x0000000087fba000
[cpu 0] expect: p3==p2 (LIFO, last freed first)
[cpu 0] --- test3: zero-fill ---
[cpu 0] zero-fill check: 0/4096 bytes non-zero
[cpu 0] expect: 0
[cpu 0] dirty-then-realloc zero check: 0/4096 bytes non-zero
[cpu 0] expect: 0
[cpu 0] --- test4: kfree rejects bad addresses ---
[cpu 0] alloc after bad frees: p4=0x0000000087fba000
[cpu 0] expect: p4≠0 (bad frees silently ignored)
[cpu 0] --- test5: exhaustion ---
[cpu 0] allocated 32689 pages before NULL
[cpu 0] expect: >1000
[cpu 0] --- test6: free-then-reuse after exhaustion ---
[cpu 0] kalloc after exhaustion: 0x0000000000000000
[cpu 0] expect: 0x0 (really out of memory)
[cpu 0] freed 2 pages, re-alloc'd r1=0x0000000087fbb000 r2=0x0000000087fb9000
[cpu 0] expect: r1==0x0000000087fbb000 r2==0x0000000087fb9000 (LIFO)
[cpu 0] --- test7: identity mapping ---
[cpu 0] satp=0x8000000000087fff, mode=8 (8=Sv39)
[cpu 0] expect: mode=8
[cpu 0] printf after paging ON proves identity map works
[cpu 0] === ALL TESTS PASSED ===
QEMU: Terminated
```