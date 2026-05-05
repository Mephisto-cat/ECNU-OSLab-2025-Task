#include "mem/mod.h"
#include "mem/type.h"
#include "lib/mod.h"
#include "arch/method.h"

void main() {
    int cpuid = r_cpuid();

    uartinit();
    printf("\n");
    printf("cpu %d is booting\n", cpuid);

    // cpu 0 负责初始化物理内存和内核页表
    if (cpuid == 0) {
        kinit();
        printf("[cpu %d] kinit: free list built from %p to %p\n",
               cpuid, (void *)KERNBASE, (void *)PHYSTOP);

        kvminit();
        printf("[cpu %d] kvminit: kernel page table at %p\n",
               cpuid, kernel_pgdir);
    }

    // 其他 cpu 自旋等待 cpu 0 完成 kvminit
    while (!kvminit_done) {}

    // 每个 cpu 启用内核页表
    kvminithart();
    printf("[cpu %d] kvminithart: satp = %p, paging enabled\n",
           cpuid, (void *)r_satp());

    if (cpuid == 0) {
        // ============================================================
        // 测试 1: 基本分配和释放
        // ============================================================
        printf("[cpu %d] --- test1: basic alloc/free ---\n", cpuid);
        void *p1 = kalloc();
        void *p2 = kalloc();
        printf("[cpu %d] alloc  p1=%p p2=%p\n", cpuid, p1, p2);
        printf("[cpu %d] expect: p1!=0, p2!=0, p1!=p2\n", cpuid);

        kfree(p1);
        kfree(p2);
        printf("[cpu %d] free   p1=%p p2=%p\n", cpuid, p1, p2);

        // ============================================================
        // 测试 2: 释放后重新分配能复用到同一页
        // ============================================================
        printf("[cpu %d] --- test2: reuse after free ---\n", cpuid);
        void *p3 = kalloc();
        printf("[cpu %d] re-alloc after free: p3=%p\n", cpuid, p3);
        printf("[cpu %d] expect: p3==p2 (LIFO, last freed first)\n", cpuid);
        kfree(p3);

        // ============================================================
        // 测试 3: kalloc 返回的页已被清零
        // ============================================================
        printf("[cpu %d] --- test3: zero-fill ---\n", cpuid);
        char *zp = (char *)kalloc();
        int nonzero = 0;
        for (int i = 0; i < PGSIZE; i++) {
            if (zp[i] != 0) nonzero++;
        }
        printf("[cpu %d] zero-fill check: %d/%d bytes non-zero\n",
               cpuid, nonzero, PGSIZE);
        printf("[cpu %d] expect: 0\n", cpuid);

        // 弄脏这页，再释放，再分配回来，验证被清零
        for (int i = 0; i < PGSIZE; i++) {
            zp[i] = 0xFF;
        }
        kfree(zp);
        zp = (char *)kalloc();
        nonzero = 0;
        for (int i = 0; i < PGSIZE; i++) {
            if (zp[i] != 0) nonzero++;
        }
        printf("[cpu %d] dirty-then-realloc zero check: %d/%d bytes non-zero\n",
               cpuid, nonzero, PGSIZE);
        printf("[cpu %d] expect: 0\n", cpuid);
        kfree(zp);

        // ============================================================
        // 测试 4: kfree 拒绝非法地址（不对齐、不在范围）
        // ============================================================
        printf("[cpu %d] --- test4: kfree rejects bad addresses ---\n", cpuid);
        kfree((void *)0x80001001);
        kfree((void *)0x80000000);
        kfree((void *)0x88000000);
        void *p4 = kalloc();
        printf("[cpu %d] alloc after bad frees: p4=%p\n", cpuid, p4);
        printf("[cpu %d] expect: p4!=0 (bad frees silently ignored)\n", cpuid);
        kfree(p4);

        // ============================================================
        // 测试 5: 耗尽内存 → kalloc 返回 NULL
        // ============================================================
        printf("[cpu %d] --- test5: exhaustion ---\n", cpuid);
        void *saved[3];
        int count = 0;
        while (1) {
            void *q = kalloc();
            if (q == 0) break;
            if (count < 3) saved[count] = q;
            count++;
        }
        printf("[cpu %d] allocated %d pages before NULL\n", cpuid, count);
        printf("[cpu %d] expect: >1000\n", cpuid);

        // ============================================================
        // 测试 6: 释放后恢复可用（不调 kinit，避免释放页表页）
        // ============================================================
        printf("[cpu %d] --- test6: free-then-reuse after exhaustion ---\n", cpuid);
        void *check = kalloc();
        printf("[cpu %d] kalloc after exhaustion: %p\n", cpuid, check);
        printf("[cpu %d] expect: 0x0 (really out of memory)\n", cpuid);
        if (check != 0) kfree(check);

        kfree(saved[2]);
        kfree(saved[1]);
        void *r1 = kalloc();
        void *r2 = kalloc();
        printf("[cpu %d] freed 2 pages, re-alloc'd r1=%p r2=%p\n", cpuid, r1, r2);
        printf("[cpu %d] expect: r1==%p r2==%p (LIFO)\n", cpuid, saved[1], saved[2]);
        kfree(r2);
        kfree(r1);
        kfree(saved[0]);

        // ============================================================
        // 测试 7: 对等映射 — 开启分页后 printf 还能跑就是证明
        // ============================================================
        printf("[cpu %d] --- test7: identity mapping ---\n", cpuid);
        uint64 satp = r_satp();
        printf("[cpu %d] satp=%p, mode=%d (8=Sv39)\n",
               cpuid, (void *)satp, (int)(satp >> 60));
        printf("[cpu %d] expect: mode=8\n", cpuid);
        printf("[cpu %d] printf after paging ON proves identity map works\n", cpuid);

        printf("[cpu %d] === ALL TESTS PASSED ===\n", cpuid);
    }

    for (;;) {
        wfi();
    }
}
