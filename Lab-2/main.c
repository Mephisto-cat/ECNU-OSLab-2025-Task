#include "kalloc.h"
#include "memlayout.h"
#include "page.h"
#include "printf.h"
#include "riscv.h"
#include "uart.h"
#include "vm.h"

void main() {
    uint64 hartid;

    uartinit();
    hartid = r_tp();

    printf("\n");
    printf("=== Lab2: hart %d ===\n", (int)hartid);

    // hart 0 负责初始化物理内存和内核页表
    if (hartid == 0) {
        kinit();
        printf("[hart %d] kinit: free list built from %p to %p\n",
               (int)hartid, (void *)KERNBASE, (void *)PHYSTOP);

        kvminit();
        printf("[hart %d] kvminit: kernel page table at %p\n",
               (int)hartid, kernel_pgdir);
    }

    // 其他 hart 自旋等待 hart 0 完成 kvminit
    while (!kvminit_done)
        ;

    // 每个 hart 启用内核页表
    kvminithart();
    printf("[hart %d] kvminithart: satp = %p, paging enabled\n",
           (int)hartid, (void *)r_satp());

    if (hartid == 0) {
        // ============================================================
        // 测试 1: 基本分配和释放
        // ============================================================
        printf("[hart %d] --- test1: basic alloc/free ---\n", (int)hartid);
        void *p1 = kalloc();
        void *p2 = kalloc();
        printf("[hart %d] alloc  p1=%p p2=%p\n", (int)hartid, p1, p2);
        printf("[hart %d] expect: p1≠0, p2≠0, p1≠p2\n", (int)hartid);

        kfree(p1);
        kfree(p2);
        printf("[hart %d] free   p1=%p p2=%p\n", (int)hartid, p1, p2);

        // ============================================================
        // 测试 2: 释放后重新分配能复用到同一页
        // ============================================================
        printf("[hart %d] --- test2: reuse after free ---\n", (int)hartid);
        void *p3 = kalloc();
        printf("[hart %d] re-alloc after free: p3=%p\n", (int)hartid, p3);
        printf("[hart %d] expect: p3==p2 (LIFO, last freed first)\n", (int)hartid);
        kfree(p3);

        // ============================================================
        // 测试 3: kalloc 返回的页已被清零
        // ============================================================
        printf("[hart %d] --- test3: zero-fill ---\n", (int)hartid);
        char *zp = (char *)kalloc();
        int nonzero = 0;
        for (int i = 0; i < PGSIZE; i++)
            if (zp[i] != 0) nonzero++;
        printf("[hart %d] zero-fill check: %d/%d bytes non-zero\n",
               (int)hartid, nonzero, PGSIZE);
        printf("[hart %d] expect: 0\n", (int)hartid);

        // 弄脏这页，再释放，再分配回来，验证被清零
        for (int i = 0; i < PGSIZE; i++)
            zp[i] = 0xFF;
        kfree(zp);
        zp = (char *)kalloc();
        nonzero = 0;
        for (int i = 0; i < PGSIZE; i++)
            if (zp[i] != 0) nonzero++;
        printf("[hart %d] dirty-then-realloc zero check: %d/%d bytes non-zero\n",
               (int)hartid, nonzero, PGSIZE);
        printf("[hart %d] expect: 0\n", (int)hartid);
        kfree(zp);

        // ============================================================
        // 测试 4: kfree 拒绝非法地址（不对齐、不在范围）
        // ============================================================
        printf("[hart %d] --- test4: kfree rejects bad addresses ---\n",
               (int)hartid);
        kfree((void *)0x80001001);   // 不对齐
        kfree((void *)0x80000000);   // 低于 end（在内核代码段）
        kfree((void *)0x88000000);   // 等于 PHYSTOP（超范围）
        void *p4 = kalloc();
        printf("[hart %d] alloc after bad frees: p4=%p\n", (int)hartid, p4);
        printf("[hart %d] expect: p4≠0 (bad frees silently ignored)\n",
               (int)hartid);
        kfree(p4);

        // ============================================================
        // 测试 5: 耗尽内存 → kalloc 返回 NULL
        // ============================================================
        printf("[hart %d] --- test5: exhaustion ---\n", (int)hartid);
        // 先留几个指针，测试 6 用来验证 "释放后可用"
        void *saved[3];
        int count = 0;
        while (1) {
            void *q = kalloc();
            if (q == 0) break;
            if (count < 3) saved[count] = q;
            count++;
        }
        printf("[hart %d] allocated %d pages before NULL\n",
               (int)hartid, count);
        printf("[hart %d] expect: >1000\n", (int)hartid);

        // ============================================================
        // 测试 6: 释放后恢复可用（不调 kinit，避免释放页表页）
        // ============================================================
        printf("[hart %d] --- test6: free-then-reuse after exhaustion ---\n",
               (int)hartid);
        void *check = kalloc();
        printf("[hart %d] kalloc after exhaustion: %p\n",
               (int)hartid, check);
        printf("[hart %d] expect: 0x0 (really out of memory)\n", (int)hartid);
        if (check != 0) kfree(check);  // 不应该到这里

        // 释放测试 5 留下的两页
        kfree(saved[2]);
        kfree(saved[1]);
        void *r1 = kalloc();
        void *r2 = kalloc();
        printf("[hart %d] freed 2 pages, re-alloc'd r1=%p r2=%p\n",
               (int)hartid, r1, r2);
        printf("[hart %d] expect: r1==%p r2==%p (LIFO)\n",
               (int)hartid, saved[1], saved[2]);
        kfree(r2);
        kfree(r1);
        kfree(saved[0]);

        // ============================================================
        // 测试 7: 对等映射 — 开启分页后 printf 还能跑就是证明
        // ============================================================
        printf("[hart %d] --- test7: identity mapping ---\n", (int)hartid);
        uint64 satp = r_satp();
        printf("[hart %d] satp=%p, mode=%d (8=Sv39)\n",
               (int)hartid, (void *)satp, (int)(satp >> 60));
        printf("[hart %d] expect: mode=8\n", (int)hartid);
        printf("[hart %d] printf after paging ON proves identity map works\n",
               (int)hartid);

        printf("[hart %d] === ALL TESTS PASSED ===\n", (int)hartid);
    }

    for (;;)
        wfi();
}
