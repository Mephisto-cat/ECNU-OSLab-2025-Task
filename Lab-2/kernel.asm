
kernel-qemu.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
.section .text
.global _entry

_entry:
    csrr a0, mhartid
    80000000:	f1402573          	csrr	a0,mhartid
    la sp, stacks
    80000004:	00002117          	auipc	sp,0x2
    80000008:	ffc10113          	addi	sp,sp,-4 # 80002000 <stacks>
    li t0, 4096
    8000000c:	6285                	lui	t0,0x1
    addi a0, a0, 1
    8000000e:	0505                	addi	a0,a0,1
    mul a0, a0, t0
    80000010:	02550533          	mul	a0,a0,t0
    add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
    call start
    80000016:	072000ef          	jal	ra,80000088 <start>

000000008000001a <r_mstatus>:
*/
#include "types.h"

void main();

uint64 r_mstatus() {
    8000001a:	1141                	addi	sp,sp,-16
    8000001c:	e422                	sd	s0,8(sp)
    8000001e:	0800                	addi	s0,sp,16
    uint64 x;
    // asm volatile("汇编指令" : 输出列表 : 输入列表);
    asm volatile("csrr %0, mstatus" : "=r"(x));
    80000020:	30002573          	csrr	a0,mstatus
    return x;
}
    80000024:	6422                	ld	s0,8(sp)
    80000026:	0141                	addi	sp,sp,16
    80000028:	8082                	ret

000000008000002a <w_mstatus>:

void w_mstatus(uint64 x) {
    8000002a:	1141                	addi	sp,sp,-16
    8000002c:	e422                	sd	s0,8(sp)
    8000002e:	0800                	addi	s0,sp,16
    asm volatile("csrw mstatus, %0" : : "r"(x));
    80000030:	30051073          	csrw	mstatus,a0
}
    80000034:	6422                	ld	s0,8(sp)
    80000036:	0141                	addi	sp,sp,16
    80000038:	8082                	ret

000000008000003a <w_mepc>:

void w_mepc(uint64 x) {
    8000003a:	1141                	addi	sp,sp,-16
    8000003c:	e422                	sd	s0,8(sp)
    8000003e:	0800                	addi	s0,sp,16
    asm volatile("csrw mepc, %0" : : "r"(x));
    80000040:	34151073          	csrw	mepc,a0
}
    80000044:	6422                	ld	s0,8(sp)
    80000046:	0141                	addi	sp,sp,16
    80000048:	8082                	ret

000000008000004a <w_pmpaddr0>:

void w_pmpaddr0(uint64 x) {
    8000004a:	1141                	addi	sp,sp,-16
    8000004c:	e422                	sd	s0,8(sp)
    8000004e:	0800                	addi	s0,sp,16
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    80000050:	3b051073          	csrw	pmpaddr0,a0
}
    80000054:	6422                	ld	s0,8(sp)
    80000056:	0141                	addi	sp,sp,16
    80000058:	8082                	ret

000000008000005a <w_pmpcfg0>:

void w_pmpcfg0(uint64 x) {
    8000005a:	1141                	addi	sp,sp,-16
    8000005c:	e422                	sd	s0,8(sp)
    8000005e:	0800                	addi	s0,sp,16
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    80000060:	3a051073          	csrw	pmpcfg0,a0
}
    80000064:	6422                	ld	s0,8(sp)
    80000066:	0141                	addi	sp,sp,16
    80000068:	8082                	ret

000000008000006a <r_mhartid>:

uint64 r_mhartid(void) {
    8000006a:	1141                	addi	sp,sp,-16
    8000006c:	e422                	sd	s0,8(sp)
    8000006e:	0800                	addi	s0,sp,16
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    80000070:	f1402573          	csrr	a0,mhartid
    return x;
}
    80000074:	6422                	ld	s0,8(sp)
    80000076:	0141                	addi	sp,sp,16
    80000078:	8082                	ret

000000008000007a <w_tp>:

void w_tp(uint64 x) {
    8000007a:	1141                	addi	sp,sp,-16
    8000007c:	e422                	sd	s0,8(sp)
    8000007e:	0800                	addi	s0,sp,16
    asm volatile("mv tp, %0" : : "r"(x));
    80000080:	822a                	mv	tp,a0
}
    80000082:	6422                	ld	s0,8(sp)
    80000084:	0141                	addi	sp,sp,16
    80000086:	8082                	ret

0000000080000088 <start>:


void start() {
    80000088:	1141                	addi	sp,sp,-16
    8000008a:	e422                	sd	s0,8(sp)
    8000008c:	0800                	addi	s0,sp,16
    asm volatile("csrr %0, mhartid" : "=r"(x));
    8000008e:	f14027f3          	csrr	a5,mhartid
    asm volatile("mv tp, %0" : : "r"(x));
    80000092:	823e                	mv	tp,a5
    asm volatile("csrr %0, mstatus" : "=r"(x));
    80000094:	300027f3          	csrr	a5,mstatus
    // 3（二进制 11）	M-mode
    // 1（二进制 01）	S-mode1
    // 0（二进制 00）	U-mode

    // x 现在是 M-mode，将其变为 S-mode
    x &= ~(2UL << 11);   // 清 bit12 (M-mode → 不设就是 U-mode)
    80000098:	777d                	lui	a4,0xfffff
    8000009a:	177d                	addi	a4,a4,-1 # ffffffffffffefff <kernel_pgdir+0xffffffff7fff4fc7>
    8000009c:	8ff9                	and	a5,a5,a4
    x |=  (1UL << 11);   // 设 bit11 = S-mode
    8000009e:	6705                	lui	a4,0x1
    800000a0:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a4:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800000a6:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc, %0" : : "r"(x));
    800000aa:	00000797          	auipc	a5,0x0
    800000ae:	03278793          	addi	a5,a5,50 # 800000dc <main>
    800000b2:	34179073          	csrw	mepc,a5
    w_mstatus(x);

    w_mepc((uint64)main);

    // 暂时禁用 MMU，关中断委托
    asm volatile("csrw satp, %0" : : "r"(0));
    800000b6:	4781                	li	a5,0
    800000b8:	18079073          	csrw	satp,a5
    asm volatile("csrw medeleg, %0" : : "r"(0));
    800000bc:	30279073          	csrw	medeleg,a5
    asm volatile("csrw mideleg, %0" : : "r"(0));
    800000c0:	30379073          	csrw	mideleg,a5
    asm volatile("csrw sie, %0" : : "r"(0));
    800000c4:	10479073          	csrw	sie,a5
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000c8:	57fd                	li	a5,-1
    800000ca:	83a9                	srli	a5,a5,0xa
    800000cc:	3b079073          	csrw	pmpaddr0,a5
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000d0:	47bd                	li	a5,15
    800000d2:	3a079073          	csrw	pmpcfg0,a5

    w_pmpaddr0(0x3fffffffffffffull);    // 放行全部物理地址
    w_pmpcfg0(0xf);                     // 可读可写可执行

    asm volatile("mret");
    800000d6:	30200073          	mret

    while (1);
    800000da:	a001                	j	800000da <start+0x52>

00000000800000dc <main>:
#include "printf.h"
#include "riscv.h"
#include "uart.h"
#include "vm.h"

void main() {
    800000dc:	715d                	addi	sp,sp,-80
    800000de:	e0a2                	sd	s0,64(sp)
    800000e0:	e486                	sd	ra,72(sp)
    800000e2:	fc26                	sd	s1,56(sp)
    800000e4:	f84a                	sd	s2,48(sp)
    800000e6:	f44e                	sd	s3,40(sp)
    800000e8:	f052                	sd	s4,32(sp)
    800000ea:	0880                	addi	s0,sp,80
    uint64 hartid;

    uartinit();
    800000ec:	00000097          	auipc	ra,0x0
    800000f0:	45c080e7          	jalr	1116(ra) # 80000548 <uartinit>
#include "types.h"

// 读 tp 寄存器 (hartid 从 M-mode 带下来存在这里)
static inline uint64 r_tp(void) {
    uint64 x;
    asm volatile("mv %0, tp" : "=r"(x));
    800000f4:	8492                	mv	s1,tp
    hartid = r_tp();

    printf("\n");
    800000f6:	00001517          	auipc	a0,0x1
    800000fa:	faa50513          	addi	a0,a0,-86 # 800010a0 <kvminithart+0x534>
    800000fe:	00000097          	auipc	ra,0x0
    80000102:	534080e7          	jalr	1332(ra) # 80000632 <printf>
    printf("=== Lab2: hart %d ===\n", (int)hartid);
    80000106:	0004891b          	sext.w	s2,s1
    8000010a:	85ca                	mv	a1,s2
    8000010c:	00001517          	auipc	a0,0x1
    80000110:	a8450513          	addi	a0,a0,-1404 # 80000b90 <kvminithart+0x24>
    80000114:	00000097          	auipc	ra,0x0
    80000118:	51e080e7          	jalr	1310(ra) # 80000632 <printf>

    // hart 0 负责初始化物理内存和内核页表
    if (hartid == 0) {
    8000011c:	3c048263          	beqz	s1,800004e0 <main+0x404>
    80000120:	0000a717          	auipc	a4,0xa
    80000124:	f1070713          	addi	a4,a4,-240 # 8000a030 <kvminit_done>
        printf("[hart %d] kvminit: kernel page table at %p\n",
               (int)hartid, kernel_pgdir);
    }

    // 其他 hart 自旋等待 hart 0 完成 kvminit
    while (!kvminit_done)
    80000128:	431c                	lw	a5,0(a4)
    8000012a:	dffd                	beqz	a5,80000128 <main+0x4c>
        ;

    // 每个 hart 启用内核页表
    kvminithart();
    8000012c:	00001097          	auipc	ra,0x1
    80000130:	a40080e7          	jalr	-1472(ra) # 80000b6c <kvminithart>
    asm volatile("csrw satp, %0" : : "r"(x));
}

static inline uint64 r_satp() {
    uint64 x;
    asm volatile("csrr %0, satp" : "=r"(x));
    80000134:	18002673          	csrr	a2,satp
    printf("[hart %d] kvminithart: satp = %p, paging enabled\n",
    80000138:	00001517          	auipc	a0,0x1
    8000013c:	ad050513          	addi	a0,a0,-1328 # 80000c08 <kvminithart+0x9c>
    80000140:	85ca                	mv	a1,s2
    80000142:	00000097          	auipc	ra,0x0
    80000146:	4f0080e7          	jalr	1264(ra) # 80000632 <printf>
           (int)hartid, (void *)r_satp());

    if (hartid == 0) {
    8000014a:	c491                	beqz	s1,80000156 <main+0x7a>
    asm volatile("wfi");
    8000014c:	10500073          	wfi
    80000150:	10500073          	wfi
    80000154:	bfe5                	j	8000014c <main+0x70>
        // ============================================================
        // 测试 1: 基本分配和释放
        // ============================================================
        printf("[hart %d] --- test1: basic alloc/free ---\n", (int)hartid);
    80000156:	4581                	li	a1,0
    80000158:	00001517          	auipc	a0,0x1
    8000015c:	ae850513          	addi	a0,a0,-1304 # 80000c40 <kvminithart+0xd4>
    80000160:	00000097          	auipc	ra,0x0
    80000164:	4d2080e7          	jalr	1234(ra) # 80000632 <printf>
        void *p1 = kalloc();
    80000168:	00001097          	auipc	ra,0x1
    8000016c:	810080e7          	jalr	-2032(ra) # 80000978 <kalloc>
    80000170:	84aa                	mv	s1,a0
        void *p2 = kalloc();
    80000172:	00001097          	auipc	ra,0x1
    80000176:	806080e7          	jalr	-2042(ra) # 80000978 <kalloc>
        printf("[hart %d] alloc  p1=%p p2=%p\n", (int)hartid, p1, p2);
    8000017a:	86aa                	mv	a3,a0
    8000017c:	8626                	mv	a2,s1
        void *p2 = kalloc();
    8000017e:	892a                	mv	s2,a0
        printf("[hart %d] alloc  p1=%p p2=%p\n", (int)hartid, p1, p2);
    80000180:	4581                	li	a1,0
    80000182:	00001517          	auipc	a0,0x1
    80000186:	aee50513          	addi	a0,a0,-1298 # 80000c70 <kvminithart+0x104>
    8000018a:	00000097          	auipc	ra,0x0
    8000018e:	4a8080e7          	jalr	1192(ra) # 80000632 <printf>
        printf("[hart %d] expect: p1≠0, p2≠0, p1≠p2\n", (int)hartid);
    80000192:	4581                	li	a1,0
    80000194:	00001517          	auipc	a0,0x1
    80000198:	afc50513          	addi	a0,a0,-1284 # 80000c90 <kvminithart+0x124>
    8000019c:	00000097          	auipc	ra,0x0
    800001a0:	496080e7          	jalr	1174(ra) # 80000632 <printf>

        kfree(p1);
    800001a4:	8526                	mv	a0,s1
    800001a6:	00001097          	auipc	ra,0x1
    800001aa:	83c080e7          	jalr	-1988(ra) # 800009e2 <kfree>
        kfree(p2);
    800001ae:	854a                	mv	a0,s2
    800001b0:	00001097          	auipc	ra,0x1
    800001b4:	832080e7          	jalr	-1998(ra) # 800009e2 <kfree>
        printf("[hart %d] free   p1=%p p2=%p\n", (int)hartid, p1, p2);
    800001b8:	86ca                	mv	a3,s2
    800001ba:	8626                	mv	a2,s1
    800001bc:	4581                	li	a1,0
    800001be:	00001517          	auipc	a0,0x1
    800001c2:	b0250513          	addi	a0,a0,-1278 # 80000cc0 <kvminithart+0x154>
    800001c6:	00000097          	auipc	ra,0x0
    800001ca:	46c080e7          	jalr	1132(ra) # 80000632 <printf>

        // ============================================================
        // 测试 2: 释放后重新分配能复用到同一页
        // ============================================================
        printf("[hart %d] --- test2: reuse after free ---\n", (int)hartid);
    800001ce:	4581                	li	a1,0
    800001d0:	00001517          	auipc	a0,0x1
    800001d4:	b1050513          	addi	a0,a0,-1264 # 80000ce0 <kvminithart+0x174>
    800001d8:	00000097          	auipc	ra,0x0
    800001dc:	45a080e7          	jalr	1114(ra) # 80000632 <printf>
        void *p3 = kalloc();
    800001e0:	00000097          	auipc	ra,0x0
    800001e4:	798080e7          	jalr	1944(ra) # 80000978 <kalloc>
        printf("[hart %d] re-alloc after free: p3=%p\n", (int)hartid, p3);
    800001e8:	862a                	mv	a2,a0
        void *p3 = kalloc();
    800001ea:	84aa                	mv	s1,a0
        printf("[hart %d] re-alloc after free: p3=%p\n", (int)hartid, p3);
    800001ec:	4581                	li	a1,0
    800001ee:	00001517          	auipc	a0,0x1
    800001f2:	b2250513          	addi	a0,a0,-1246 # 80000d10 <kvminithart+0x1a4>
    800001f6:	00000097          	auipc	ra,0x0
    800001fa:	43c080e7          	jalr	1084(ra) # 80000632 <printf>
        printf("[hart %d] expect: p3==p2 (LIFO, last freed first)\n", (int)hartid);
    800001fe:	4581                	li	a1,0
    80000200:	00001517          	auipc	a0,0x1
    80000204:	b3850513          	addi	a0,a0,-1224 # 80000d38 <kvminithart+0x1cc>
    80000208:	00000097          	auipc	ra,0x0
    8000020c:	42a080e7          	jalr	1066(ra) # 80000632 <printf>
        kfree(p3);
    80000210:	8526                	mv	a0,s1
    80000212:	00000097          	auipc	ra,0x0
    80000216:	7d0080e7          	jalr	2000(ra) # 800009e2 <kfree>

        // ============================================================
        // 测试 3: kalloc 返回的页已被清零
        // ============================================================
        printf("[hart %d] --- test3: zero-fill ---\n", (int)hartid);
    8000021a:	4581                	li	a1,0
    8000021c:	00001517          	auipc	a0,0x1
    80000220:	b5450513          	addi	a0,a0,-1196 # 80000d70 <kvminithart+0x204>
    80000224:	00000097          	auipc	ra,0x0
    80000228:	40e080e7          	jalr	1038(ra) # 80000632 <printf>
        char *zp = (char *)kalloc();
    8000022c:	00000097          	auipc	ra,0x0
    80000230:	74c080e7          	jalr	1868(ra) # 80000978 <kalloc>
    80000234:	6905                	lui	s2,0x1
    80000236:	89aa                	mv	s3,a0
        int nonzero = 0;
        for (int i = 0; i < PGSIZE; i++)
    80000238:	84aa                	mv	s1,a0
    8000023a:	992a                	add	s2,s2,a0
        char *zp = (char *)kalloc();
    8000023c:	87aa                	mv	a5,a0
        int nonzero = 0;
    8000023e:	4601                	li	a2,0
            if (zp[i] != 0) nonzero++;
    80000240:	0007c703          	lbu	a4,0(a5)
        for (int i = 0; i < PGSIZE; i++)
    80000244:	0785                	addi	a5,a5,1
            if (zp[i] != 0) nonzero++;
    80000246:	c311                	beqz	a4,8000024a <main+0x16e>
    80000248:	2605                	addiw	a2,a2,1
        for (int i = 0; i < PGSIZE; i++)
    8000024a:	ff279be3          	bne	a5,s2,80000240 <main+0x164>
        printf("[hart %d] zero-fill check: %d/%d bytes non-zero\n",
    8000024e:	6685                	lui	a3,0x1
    80000250:	4581                	li	a1,0
    80000252:	00001517          	auipc	a0,0x1
    80000256:	b4650513          	addi	a0,a0,-1210 # 80000d98 <kvminithart+0x22c>
    8000025a:	00000097          	auipc	ra,0x0
    8000025e:	3d8080e7          	jalr	984(ra) # 80000632 <printf>
               (int)hartid, nonzero, PGSIZE);
        printf("[hart %d] expect: 0\n", (int)hartid);
    80000262:	4581                	li	a1,0
    80000264:	00001517          	auipc	a0,0x1
    80000268:	b6c50513          	addi	a0,a0,-1172 # 80000dd0 <kvminithart+0x264>
    8000026c:	00000097          	auipc	ra,0x0
    80000270:	3c6080e7          	jalr	966(ra) # 80000632 <printf>

        // 弄脏这页，再释放，再分配回来，验证被清零
        for (int i = 0; i < PGSIZE; i++)
            zp[i] = 0xFF;
    80000274:	57fd                	li	a5,-1
    80000276:	00f48023          	sb	a5,0(s1)
        for (int i = 0; i < PGSIZE; i++)
    8000027a:	0485                	addi	s1,s1,1
    8000027c:	ff249de3          	bne	s1,s2,80000276 <main+0x19a>
        kfree(zp);
    80000280:	854e                	mv	a0,s3
    80000282:	00000097          	auipc	ra,0x0
    80000286:	760080e7          	jalr	1888(ra) # 800009e2 <kfree>
        zp = (char *)kalloc();
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	6ee080e7          	jalr	1774(ra) # 80000978 <kalloc>
    80000292:	6685                	lui	a3,0x1
    80000294:	84aa                	mv	s1,a0
        nonzero = 0;
        for (int i = 0; i < PGSIZE; i++)
    80000296:	87aa                	mv	a5,a0
    80000298:	96aa                	add	a3,a3,a0
        nonzero = 0;
    8000029a:	4601                	li	a2,0
            if (zp[i] != 0) nonzero++;
    8000029c:	0007c703          	lbu	a4,0(a5)
        for (int i = 0; i < PGSIZE; i++)
    800002a0:	0785                	addi	a5,a5,1
            if (zp[i] != 0) nonzero++;
    800002a2:	c311                	beqz	a4,800002a6 <main+0x1ca>
    800002a4:	2605                	addiw	a2,a2,1
        for (int i = 0; i < PGSIZE; i++)
    800002a6:	fef69be3          	bne	a3,a5,8000029c <main+0x1c0>
        printf("[hart %d] dirty-then-realloc zero check: %d/%d bytes non-zero\n",
    800002aa:	6685                	lui	a3,0x1
    800002ac:	4581                	li	a1,0
    800002ae:	00001517          	auipc	a0,0x1
    800002b2:	b3a50513          	addi	a0,a0,-1222 # 80000de8 <kvminithart+0x27c>
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	37c080e7          	jalr	892(ra) # 80000632 <printf>
               (int)hartid, nonzero, PGSIZE);
        printf("[hart %d] expect: 0\n", (int)hartid);
    800002be:	4581                	li	a1,0
    800002c0:	00001517          	auipc	a0,0x1
    800002c4:	b1050513          	addi	a0,a0,-1264 # 80000dd0 <kvminithart+0x264>
    800002c8:	00000097          	auipc	ra,0x0
    800002cc:	36a080e7          	jalr	874(ra) # 80000632 <printf>
        kfree(zp);
    800002d0:	8526                	mv	a0,s1
    800002d2:	00000097          	auipc	ra,0x0
    800002d6:	710080e7          	jalr	1808(ra) # 800009e2 <kfree>

        // ============================================================
        // 测试 4: kfree 拒绝非法地址（不对齐、不在范围）
        // ============================================================
        printf("[hart %d] --- test4: kfree rejects bad addresses ---\n",
    800002da:	4581                	li	a1,0
    800002dc:	00001517          	auipc	a0,0x1
    800002e0:	b4c50513          	addi	a0,a0,-1204 # 80000e28 <kvminithart+0x2bc>
    800002e4:	00000097          	auipc	ra,0x0
    800002e8:	34e080e7          	jalr	846(ra) # 80000632 <printf>
               (int)hartid);
        kfree((void *)0x80001001);   // 不对齐
    800002ec:	00001517          	auipc	a0,0x1
    800002f0:	eac53503          	ld	a0,-340(a0) # 80001198 <digits+0x20>
    800002f4:	00000097          	auipc	ra,0x0
    800002f8:	6ee080e7          	jalr	1774(ra) # 800009e2 <kfree>
        kfree((void *)0x80000000);   // 低于 end（在内核代码段）
    800002fc:	4505                	li	a0,1
    800002fe:	057e                	slli	a0,a0,0x1f
    80000300:	00000097          	auipc	ra,0x0
    80000304:	6e2080e7          	jalr	1762(ra) # 800009e2 <kfree>
        kfree((void *)0x88000000);   // 等于 PHYSTOP（超范围）
    80000308:	4545                	li	a0,17
    8000030a:	056e                	slli	a0,a0,0x1b
    8000030c:	00000097          	auipc	ra,0x0
    80000310:	6d6080e7          	jalr	1750(ra) # 800009e2 <kfree>
        void *p4 = kalloc();
    80000314:	00000097          	auipc	ra,0x0
    80000318:	664080e7          	jalr	1636(ra) # 80000978 <kalloc>
        printf("[hart %d] alloc after bad frees: p4=%p\n", (int)hartid, p4);
    8000031c:	862a                	mv	a2,a0
        void *p4 = kalloc();
    8000031e:	84aa                	mv	s1,a0
        printf("[hart %d] alloc after bad frees: p4=%p\n", (int)hartid, p4);
    80000320:	4581                	li	a1,0
    80000322:	00001517          	auipc	a0,0x1
    80000326:	b3e50513          	addi	a0,a0,-1218 # 80000e60 <kvminithart+0x2f4>
    8000032a:	00000097          	auipc	ra,0x0
    8000032e:	308080e7          	jalr	776(ra) # 80000632 <printf>
        printf("[hart %d] expect: p4≠0 (bad frees silently ignored)\n",
    80000332:	4581                	li	a1,0
    80000334:	00001517          	auipc	a0,0x1
    80000338:	b5450513          	addi	a0,a0,-1196 # 80000e88 <kvminithart+0x31c>
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	2f6080e7          	jalr	758(ra) # 80000632 <printf>
               (int)hartid);
        kfree(p4);
    80000344:	8526                	mv	a0,s1
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	69c080e7          	jalr	1692(ra) # 800009e2 <kfree>

        // ============================================================
        // 测试 5: 耗尽内存 → kalloc 返回 NULL
        // ============================================================
        printf("[hart %d] --- test5: exhaustion ---\n", (int)hartid);
    8000034e:	4581                	li	a1,0
    80000350:	00001517          	auipc	a0,0x1
    80000354:	b7050513          	addi	a0,a0,-1168 # 80000ec0 <kvminithart+0x354>
    80000358:	00000097          	auipc	ra,0x0
    8000035c:	2da080e7          	jalr	730(ra) # 80000632 <printf>
        // 先留几个指针，测试 6 用来验证 "释放后可用"
        void *saved[3];
        int count = 0;
    80000360:	fb840913          	addi	s2,s0,-72
    80000364:	4481                	li	s1,0
        while (1) {
            void *q = kalloc();
            if (q == 0) break;
            if (count < 3) saved[count] = q;
    80000366:	4989                	li	s3,2
            void *q = kalloc();
    80000368:	00000097          	auipc	ra,0x0
    8000036c:	610080e7          	jalr	1552(ra) # 80000978 <kalloc>
            if (q == 0) break;
    80000370:	cd01                	beqz	a0,80000388 <main+0x2ac>
            if (count < 3) saved[count] = q;
    80000372:	0099c463          	blt	s3,s1,8000037a <main+0x29e>
    80000376:	00a93023          	sd	a0,0(s2) # 1000 <_entry-0x7ffff000>
            count++;
    8000037a:	2485                	addiw	s1,s1,1
        while (1) {
    8000037c:	0921                	addi	s2,s2,8
            void *q = kalloc();
    8000037e:	00000097          	auipc	ra,0x0
    80000382:	5fa080e7          	jalr	1530(ra) # 80000978 <kalloc>
            if (q == 0) break;
    80000386:	f575                	bnez	a0,80000372 <main+0x296>
        }
        printf("[hart %d] allocated %d pages before NULL\n",
    80000388:	8626                	mv	a2,s1
    8000038a:	4581                	li	a1,0
    8000038c:	00001517          	auipc	a0,0x1
    80000390:	b5c50513          	addi	a0,a0,-1188 # 80000ee8 <kvminithart+0x37c>
    80000394:	00000097          	auipc	ra,0x0
    80000398:	29e080e7          	jalr	670(ra) # 80000632 <printf>
               (int)hartid, count);
        printf("[hart %d] expect: >1000\n", (int)hartid);
    8000039c:	4581                	li	a1,0
    8000039e:	00001517          	auipc	a0,0x1
    800003a2:	b7a50513          	addi	a0,a0,-1158 # 80000f18 <kvminithart+0x3ac>
    800003a6:	00000097          	auipc	ra,0x0
    800003aa:	28c080e7          	jalr	652(ra) # 80000632 <printf>

        // ============================================================
        // 测试 6: 释放后恢复可用（不调 kinit，避免释放页表页）
        // ============================================================
        printf("[hart %d] --- test6: free-then-reuse after exhaustion ---\n",
    800003ae:	4581                	li	a1,0
    800003b0:	00001517          	auipc	a0,0x1
    800003b4:	b8850513          	addi	a0,a0,-1144 # 80000f38 <kvminithart+0x3cc>
    800003b8:	00000097          	auipc	ra,0x0
    800003bc:	27a080e7          	jalr	634(ra) # 80000632 <printf>
               (int)hartid);
        void *check = kalloc();
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	5b8080e7          	jalr	1464(ra) # 80000978 <kalloc>
    800003c8:	84aa                	mv	s1,a0
        printf("[hart %d] kalloc after exhaustion: %p\n",
    800003ca:	4581                	li	a1,0
    800003cc:	00001517          	auipc	a0,0x1
    800003d0:	bac50513          	addi	a0,a0,-1108 # 80000f78 <kvminithart+0x40c>
    800003d4:	8626                	mv	a2,s1
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	25c080e7          	jalr	604(ra) # 80000632 <printf>
               (int)hartid, check);
        printf("[hart %d] expect: 0x0 (really out of memory)\n", (int)hartid);
    800003de:	4581                	li	a1,0
    800003e0:	00001517          	auipc	a0,0x1
    800003e4:	bc050513          	addi	a0,a0,-1088 # 80000fa0 <kvminithart+0x434>
    800003e8:	00000097          	auipc	ra,0x0
    800003ec:	24a080e7          	jalr	586(ra) # 80000632 <printf>
        if (check != 0) kfree(check);  // 不应该到这里
    800003f0:	c491                	beqz	s1,800003fc <main+0x320>
    800003f2:	8526                	mv	a0,s1
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	5ee080e7          	jalr	1518(ra) # 800009e2 <kfree>

        // 释放测试 5 留下的两页
        kfree(saved[2]);
    800003fc:	fc843a03          	ld	s4,-56(s0)
    80000400:	8552                	mv	a0,s4
    80000402:	00000097          	auipc	ra,0x0
    80000406:	5e0080e7          	jalr	1504(ra) # 800009e2 <kfree>
        kfree(saved[1]);
    8000040a:	fc043983          	ld	s3,-64(s0)
    8000040e:	854e                	mv	a0,s3
    80000410:	00000097          	auipc	ra,0x0
    80000414:	5d2080e7          	jalr	1490(ra) # 800009e2 <kfree>
        void *r1 = kalloc();
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	560080e7          	jalr	1376(ra) # 80000978 <kalloc>
    80000420:	84aa                	mv	s1,a0
        void *r2 = kalloc();
    80000422:	00000097          	auipc	ra,0x0
    80000426:	556080e7          	jalr	1366(ra) # 80000978 <kalloc>
    8000042a:	892a                	mv	s2,a0
        printf("[hart %d] freed 2 pages, re-alloc'd r1=%p r2=%p\n",
    8000042c:	86aa                	mv	a3,a0
    8000042e:	8626                	mv	a2,s1
    80000430:	4581                	li	a1,0
    80000432:	00001517          	auipc	a0,0x1
    80000436:	b9e50513          	addi	a0,a0,-1122 # 80000fd0 <kvminithart+0x464>
    8000043a:	00000097          	auipc	ra,0x0
    8000043e:	1f8080e7          	jalr	504(ra) # 80000632 <printf>
               (int)hartid, r1, r2);
        printf("[hart %d] expect: r1==%p r2==%p (LIFO)\n",
    80000442:	86d2                	mv	a3,s4
    80000444:	864e                	mv	a2,s3
    80000446:	4581                	li	a1,0
    80000448:	00001517          	auipc	a0,0x1
    8000044c:	bc050513          	addi	a0,a0,-1088 # 80001008 <kvminithart+0x49c>
    80000450:	00000097          	auipc	ra,0x0
    80000454:	1e2080e7          	jalr	482(ra) # 80000632 <printf>
               (int)hartid, saved[1], saved[2]);
        kfree(r2);
    80000458:	854a                	mv	a0,s2
    8000045a:	00000097          	auipc	ra,0x0
    8000045e:	588080e7          	jalr	1416(ra) # 800009e2 <kfree>
        kfree(r1);
    80000462:	8526                	mv	a0,s1
    80000464:	00000097          	auipc	ra,0x0
    80000468:	57e080e7          	jalr	1406(ra) # 800009e2 <kfree>
        kfree(saved[0]);
    8000046c:	fb843503          	ld	a0,-72(s0)
    80000470:	00000097          	auipc	ra,0x0
    80000474:	572080e7          	jalr	1394(ra) # 800009e2 <kfree>

        // ============================================================
        // 测试 7: 对等映射 — 开启分页后 printf 还能跑就是证明
        // ============================================================
        printf("[hart %d] --- test7: identity mapping ---\n", (int)hartid);
    80000478:	4581                	li	a1,0
    8000047a:	00001517          	auipc	a0,0x1
    8000047e:	bb650513          	addi	a0,a0,-1098 # 80001030 <kvminithart+0x4c4>
    80000482:	00000097          	auipc	ra,0x0
    80000486:	1b0080e7          	jalr	432(ra) # 80000632 <printf>
    asm volatile("csrr %0, satp" : "=r"(x));
    8000048a:	18002673          	csrr	a2,satp
        uint64 satp = r_satp();
        printf("[hart %d] satp=%p, mode=%d (8=Sv39)\n",
    8000048e:	4581                	li	a1,0
    80000490:	03c65693          	srli	a3,a2,0x3c
    80000494:	00001517          	auipc	a0,0x1
    80000498:	bcc50513          	addi	a0,a0,-1076 # 80001060 <kvminithart+0x4f4>
    8000049c:	00000097          	auipc	ra,0x0
    800004a0:	196080e7          	jalr	406(ra) # 80000632 <printf>
               (int)hartid, (void *)satp, (int)(satp >> 60));
        printf("[hart %d] expect: mode=8\n", (int)hartid);
    800004a4:	4581                	li	a1,0
    800004a6:	00001517          	auipc	a0,0x1
    800004aa:	be250513          	addi	a0,a0,-1054 # 80001088 <kvminithart+0x51c>
    800004ae:	00000097          	auipc	ra,0x0
    800004b2:	184080e7          	jalr	388(ra) # 80000632 <printf>
        printf("[hart %d] printf after paging ON proves identity map works\n",
    800004b6:	4581                	li	a1,0
    800004b8:	00001517          	auipc	a0,0x1
    800004bc:	bf050513          	addi	a0,a0,-1040 # 800010a8 <kvminithart+0x53c>
    800004c0:	00000097          	auipc	ra,0x0
    800004c4:	172080e7          	jalr	370(ra) # 80000632 <printf>
               (int)hartid);

        printf("[hart %d] === ALL TESTS PASSED ===\n", (int)hartid);
    800004c8:	4581                	li	a1,0
    800004ca:	00001517          	auipc	a0,0x1
    800004ce:	c1e50513          	addi	a0,a0,-994 # 800010e8 <kvminithart+0x57c>
    800004d2:	00000097          	auipc	ra,0x0
    800004d6:	160080e7          	jalr	352(ra) # 80000632 <printf>
    asm volatile("wfi");
    800004da:	10500073          	wfi
    800004de:	b98d                	j	80000150 <main+0x74>
        kinit();
    800004e0:	00000097          	auipc	ra,0x0
    800004e4:	3f8080e7          	jalr	1016(ra) # 800008d8 <kinit>
        printf("[hart %d] kinit: free list built from %p to %p\n",
    800004e8:	4605                	li	a2,1
    800004ea:	46c5                	li	a3,17
    800004ec:	067e                	slli	a2,a2,0x1f
    800004ee:	4581                	li	a1,0
    800004f0:	00000517          	auipc	a0,0x0
    800004f4:	6b850513          	addi	a0,a0,1720 # 80000ba8 <kvminithart+0x3c>
    800004f8:	06ee                	slli	a3,a3,0x1b
    800004fa:	00000097          	auipc	ra,0x0
    800004fe:	138080e7          	jalr	312(ra) # 80000632 <printf>
        kvminit();
    80000502:	00000097          	auipc	ra,0x0
    80000506:	60a080e7          	jalr	1546(ra) # 80000b0c <kvminit>
        printf("[hart %d] kvminit: kernel page table at %p\n",
    8000050a:	0000a617          	auipc	a2,0xa
    8000050e:	b2e63603          	ld	a2,-1234(a2) # 8000a038 <kernel_pgdir>
    80000512:	4581                	li	a1,0
    80000514:	00000517          	auipc	a0,0x0
    80000518:	6c450513          	addi	a0,a0,1732 # 80000bd8 <kvminithart+0x6c>
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	116080e7          	jalr	278(ra) # 80000632 <printf>
    80000524:	bef5                	j	80000120 <main+0x44>

0000000080000526 <my_put>:
#define IER_TX_ENABLE   0x01  // 允许发送
#define LSR_TX_IDLE     0x20  // bit5: 发送器空闲

static volatile uint8 *const uart = (volatile uint8 *)UART0;

void my_put(int c) {
    80000526:	1141                	addi	sp,sp,-16
    80000528:	e422                	sd	s0,8(sp)
    8000052a:	0800                	addi	s0,sp,16
    // 等发送器空闲
    while ((uart[LSR] & LSR_TX_IDLE) == 0);
    8000052c:	10000737          	lui	a4,0x10000
    80000530:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000534:	0207f793          	andi	a5,a5,32
    80000538:	dfe5                	beqz	a5,80000530 <my_put+0xa>

    uart[THR] = (uint8)c;
    8000053a:	0ff57513          	zext.b	a0,a0
    8000053e:	00a70023          	sb	a0,0(a4)
}
    80000542:	6422                	ld	s0,8(sp)
    80000544:	0141                	addi	sp,sp,16
    80000546:	8082                	ret

0000000080000548 <uartinit>:

void uartinit() {
    80000548:	1141                	addi	sp,sp,-16
    8000054a:	e422                	sd	s0,8(sp)
    8000054c:	0800                	addi	s0,sp,16
    // 关中断
    uart[IER] = 0x00;
    8000054e:	100007b7          	lui	a5,0x10000
    80000552:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

    // 设置波特率
    uart[LCR] = LCR_BAUD_LATCH;
    80000556:	f8000713          	li	a4,-128
    8000055a:	00e781a3          	sb	a4,3(a5)
    uart[0] = 0x03;
    8000055e:	470d                	li	a4,3
    80000560:	00e78023          	sb	a4,0(a5)
    uart[1] = 0x00;
    80000564:	000780a3          	sb	zero,1(a5)

    uart[LCR] = LCR_EIGHT_BITS;
    80000568:	00e781a3          	sb	a4,3(a5)

    // 开 FIFO 清空
    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;
    8000056c:	471d                	li	a4,7
    8000056e:	00e78123          	sb	a4,2(a5)

    uart[IER] = IER_TX_ENABLE;
    80000572:	4705                	li	a4,1
    80000574:	00e780a3          	sb	a4,1(a5)
    80000578:	6422                	ld	s0,8(sp)
    8000057a:	0141                	addi	sp,sp,16
    8000057c:	8082                	ret

000000008000057e <printint>:

/* 按指定进制打印整数
   base: 10=十进制, 16=十六进制
   sign: 1=负号, 0=无负号 
*/
static void printint(int64 xx, int base, int sign) {
    8000057e:	715d                	addi	sp,sp,-80
    80000580:	e0a2                	sd	s0,64(sp)
    80000582:	e486                	sd	ra,72(sp)
    80000584:	fc26                	sd	s1,56(sp)
    80000586:	f84a                	sd	s2,48(sp)
    80000588:	f44e                	sd	s3,40(sp)
    8000058a:	f052                	sd	s4,32(sp)
    8000058c:	0880                	addi	s0,sp,80
    char buf[32];
    uint64 x;

    if (sign && xx < 0) {
    8000058e:	c609                	beqz	a2,80000598 <printint+0x1a>
        x = (uint64)(-xx);
    80000590:	40a00733          	neg	a4,a0
    if (sign && xx < 0) {
    80000594:	00054363          	bltz	a0,8000059a <printint+0x1c>
    } else {
        x = (uint64)xx;
    80000598:	872a                	mv	a4,a0
    }

    int i = 0;
    do {
        buf[i++] = digits[x % base];
    8000059a:	fb040693          	addi	a3,s0,-80
    8000059e:	4801                	li	a6,0
    800005a0:	00001317          	auipc	t1,0x1
    800005a4:	bd830313          	addi	t1,t1,-1064 # 80001178 <digits>
    800005a8:	02b777b3          	remu	a5,a4,a1
        x /= base;
    } while (x != 0);
    800005ac:	0685                	addi	a3,a3,1 # 1001 <_entry-0x7fffefff>
    800005ae:	88ba                	mv	a7,a4
    800005b0:	84c2                	mv	s1,a6
        buf[i++] = digits[x % base];
    800005b2:	2805                	addiw	a6,a6,1
    800005b4:	979a                	add	a5,a5,t1
    800005b6:	0007c783          	lbu	a5,0(a5)
        x /= base;
    800005ba:	02b75733          	divu	a4,a4,a1
        buf[i++] = digits[x % base];
    800005be:	fef68fa3          	sb	a5,-1(a3)
    } while (x != 0);
    800005c2:	feb8f3e3          	bgeu	a7,a1,800005a8 <printint+0x2a>

    if (sign && xx < 0) {
    800005c6:	c219                	beqz	a2,800005cc <printint+0x4e>
    800005c8:	04054a63          	bltz	a0,8000061c <printint+0x9e>
        buf[i++] = '-';
    }

    while (--i >= 0) {
    800005cc:	fb040713          	addi	a4,s0,-80
    800005d0:	94ba                	add	s1,s1,a4
    800005d2:	89ba                	mv	s3,a4
    if (c == '\n')
    800005d4:	4a29                	li	s4,10
    800005d6:	a819                	j	800005ec <printint+0x6e>
    my_put(c);
    800005d8:	854a                	mv	a0,s2
    800005da:	00000097          	auipc	ra,0x0
    800005de:	f4c080e7          	jalr	-180(ra) # 80000526 <my_put>
    while (--i >= 0) {
    800005e2:	02998563          	beq	s3,s1,8000060c <printint+0x8e>
        putc(buf[i]);
    800005e6:	fff4c783          	lbu	a5,-1(s1)
    800005ea:	14fd                	addi	s1,s1,-1
    800005ec:	0007891b          	sext.w	s2,a5
    if (c == '\n')
    800005f0:	ff4794e3          	bne	a5,s4,800005d8 <printint+0x5a>
        my_put('\r');
    800005f4:	4535                	li	a0,13
    800005f6:	00000097          	auipc	ra,0x0
    800005fa:	f30080e7          	jalr	-208(ra) # 80000526 <my_put>
    my_put(c);
    800005fe:	854a                	mv	a0,s2
    80000600:	00000097          	auipc	ra,0x0
    80000604:	f26080e7          	jalr	-218(ra) # 80000526 <my_put>
    while (--i >= 0) {
    80000608:	fc999fe3          	bne	s3,s1,800005e6 <printint+0x68>
    }
}
    8000060c:	60a6                	ld	ra,72(sp)
    8000060e:	6406                	ld	s0,64(sp)
    80000610:	74e2                	ld	s1,56(sp)
    80000612:	7942                	ld	s2,48(sp)
    80000614:	79a2                	ld	s3,40(sp)
    80000616:	7a02                	ld	s4,32(sp)
    80000618:	6161                	addi	sp,sp,80
    8000061a:	8082                	ret
        buf[i++] = '-';
    8000061c:	fd080793          	addi	a5,a6,-48
    80000620:	97a2                	add	a5,a5,s0
    80000622:	02d00713          	li	a4,45
    80000626:	fee78023          	sb	a4,-32(a5)
        buf[i++] = digits[x % base];
    8000062a:	84c2                	mv	s1,a6
        buf[i++] = '-';
    8000062c:	02d00793          	li	a5,45
    80000630:	bf71                	j	800005cc <printint+0x4e>

0000000080000632 <printf>:

static struct spinlock pr_lock;
static int pr_lock_inited;

// 格式化输出。支持 %d %u %x %p %s %c %%
void printf(const char *fmt, ...) {
    80000632:	7171                	addi	sp,sp,-176
    80000634:	f0a2                	sd	s0,96(sp)
    80000636:	eca6                	sd	s1,88(sp)
    80000638:	1880                	addi	s0,sp,112
    8000063a:	ec66                	sd	s9,24(sp)
    8000063c:	f486                	sd	ra,104(sp)
    8000063e:	e8ca                	sd	s2,80(sp)
    80000640:	e4ce                	sd	s3,72(sp)
    80000642:	e0d2                	sd	s4,64(sp)
    80000644:	fc56                	sd	s5,56(sp)
    80000646:	f85a                	sd	s6,48(sp)
    80000648:	f45e                	sd	s7,40(sp)
    8000064a:	f062                	sd	s8,32(sp)
    8000064c:	e86a                	sd	s10,16(sp)
    int c;
    const char *s;
    va_list ap;

    if (!pr_lock_inited) {
    8000064e:	0000a497          	auipc	s1,0xa
    80000652:	9da48493          	addi	s1,s1,-1574 # 8000a028 <pr_lock_inited>
    80000656:	0004a303          	lw	t1,0(s1)
void printf(const char *fmt, ...) {
    8000065a:	e40c                	sd	a1,8(s0)
    8000065c:	e810                	sd	a2,16(s0)
    8000065e:	ec14                	sd	a3,24(s0)
    80000660:	f018                	sd	a4,32(s0)
    80000662:	f41c                	sd	a5,40(s0)
    80000664:	03043823          	sd	a6,48(s0)
    80000668:	03143c23          	sd	a7,56(s0)
    8000066c:	8caa                	mv	s9,a0
    if (!pr_lock_inited) {
    8000066e:	1e030663          	beqz	t1,8000085a <printf+0x228>
        initlock(&pr_lock, "printf");
        pr_lock_inited = 1;
    }

    acquire(&pr_lock);
    80000672:	0000a517          	auipc	a0,0xa
    80000676:	98e50513          	addi	a0,a0,-1650 # 8000a000 <pr_lock>
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	21e080e7          	jalr	542(ra) # 80000898 <acquire>
    va_start(ap, fmt);
    for (; (c = *fmt) != 0; fmt++) {
    80000682:	000ccc03          	lbu	s8,0(s9)
    va_start(ap, fmt);
    80000686:	00840793          	addi	a5,s0,8
    8000068a:	f8f43c23          	sd	a5,-104(s0)
    for (; (c = *fmt) != 0; fmt++) {
    8000068e:	060c0863          	beqz	s8,800006fe <printf+0xcc>
        if (c != '%') {
    80000692:	02500993          	li	s3,37

        fmt++;
        if (*fmt == 0)
            break;

        switch (*fmt) {
    80000696:	4bd5                	li	s7,21
    if (c == '\n')
    80000698:	4929                	li	s2,10
        switch (*fmt) {
    8000069a:	00001b17          	auipc	s6,0x1
    8000069e:	a86b0b13          	addi	s6,s6,-1402 # 80001120 <kvminithart+0x5b4>
    800006a2:	00001a97          	auipc	s5,0x1
    800006a6:	ad6a8a93          	addi	s5,s5,-1322 # 80001178 <digits>
    for (int i = 0; i < 16; i++) {
    800006aa:	5a71                	li	s4,-4
        fmt++;
    800006ac:	001c8493          	addi	s1,s9,1
        if (c != '%') {
    800006b0:	173c1f63          	bne	s8,s3,8000082e <printf+0x1fc>
        if (*fmt == 0)
    800006b4:	001cc783          	lbu	a5,1(s9)
    800006b8:	c3b9                	beqz	a5,800006fe <printf+0xcc>
        switch (*fmt) {
    800006ba:	19378363          	beq	a5,s3,80000840 <printf+0x20e>
    800006be:	f9d7879b          	addiw	a5,a5,-99
    800006c2:	0ff7f793          	zext.b	a5,a5
    800006c6:	00fbe763          	bltu	s7,a5,800006d4 <printf+0xa2>
    800006ca:	078a                	slli	a5,a5,0x2
    800006cc:	97da                	add	a5,a5,s6
    800006ce:	439c                	lw	a5,0(a5)
    800006d0:	97da                	add	a5,a5,s6
    800006d2:	8782                	jr	a5
    my_put(c);
    800006d4:	02500513          	li	a0,37
    800006d8:	00000097          	auipc	ra,0x0
    800006dc:	e4e080e7          	jalr	-434(ra) # 80000526 <my_put>
        case '%':
            putc('%');
            break;
        default:
            putc('%');
            putc(*fmt);
    800006e0:	001ccc03          	lbu	s8,1(s9)
    if (c == '\n')
    800006e4:	132c0f63          	beq	s8,s2,80000822 <printf+0x1f0>
    my_put(c);
    800006e8:	8562                	mv	a0,s8
    800006ea:	00000097          	auipc	ra,0x0
    800006ee:	e3c080e7          	jalr	-452(ra) # 80000526 <my_put>
    for (; (c = *fmt) != 0; fmt++) {
    800006f2:	0014cc03          	lbu	s8,1(s1)
    800006f6:	00148c93          	addi	s9,s1,1
    800006fa:	fa0c19e3          	bnez	s8,800006ac <printf+0x7a>
            break;
        }
    }
    va_end(ap);
    release(&pr_lock);
    800006fe:	0000a517          	auipc	a0,0xa
    80000702:	90250513          	addi	a0,a0,-1790 # 8000a000 <pr_lock>
    80000706:	00000097          	auipc	ra,0x0
    8000070a:	1b4080e7          	jalr	436(ra) # 800008ba <release>
    8000070e:	70a6                	ld	ra,104(sp)
    80000710:	7406                	ld	s0,96(sp)
    80000712:	64e6                	ld	s1,88(sp)
    80000714:	6946                	ld	s2,80(sp)
    80000716:	69a6                	ld	s3,72(sp)
    80000718:	6a06                	ld	s4,64(sp)
    8000071a:	7ae2                	ld	s5,56(sp)
    8000071c:	7b42                	ld	s6,48(sp)
    8000071e:	7ba2                	ld	s7,40(sp)
    80000720:	7c02                	ld	s8,32(sp)
    80000722:	6ce2                	ld	s9,24(sp)
    80000724:	6d42                	ld	s10,16(sp)
    80000726:	614d                	addi	sp,sp,176
    80000728:	8082                	ret
            printint(va_arg(ap, unsigned int), 16, 0);
    8000072a:	f9843783          	ld	a5,-104(s0)
    8000072e:	4601                	li	a2,0
    80000730:	45c1                	li	a1,16
    80000732:	0007e503          	lwu	a0,0(a5)
    80000736:	07a1                	addi	a5,a5,8
    80000738:	f8f43c23          	sd	a5,-104(s0)
    8000073c:	00000097          	auipc	ra,0x0
    80000740:	e42080e7          	jalr	-446(ra) # 8000057e <printint>
            break;
    80000744:	b77d                	j	800006f2 <printf+0xc0>
            printint(va_arg(ap, unsigned int), 10, 0);
    80000746:	f9843783          	ld	a5,-104(s0)
    8000074a:	4601                	li	a2,0
    8000074c:	45a9                	li	a1,10
    8000074e:	0007e503          	lwu	a0,0(a5)
    80000752:	07a1                	addi	a5,a5,8
    80000754:	f8f43c23          	sd	a5,-104(s0)
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	e26080e7          	jalr	-474(ra) # 8000057e <printint>
            break;
    80000760:	bf49                	j	800006f2 <printf+0xc0>
            s = va_arg(ap, const char *);
    80000762:	f9843783          	ld	a5,-104(s0)
    80000766:	0007bc03          	ld	s8,0(a5)
    8000076a:	07a1                	addi	a5,a5,8
    8000076c:	f8f43c23          	sd	a5,-104(s0)
            if (s == 0)
    80000770:	000c1863          	bnez	s8,80000780 <printf+0x14e>
    80000774:	a211                	j	80000878 <printf+0x246>
    my_put(c);
    80000776:	8566                	mv	a0,s9
    80000778:	00000097          	auipc	ra,0x0
    8000077c:	dae080e7          	jalr	-594(ra) # 80000526 <my_put>
            while (*s)
    80000780:	000c4783          	lbu	a5,0(s8)
    80000784:	d7bd                	beqz	a5,800006f2 <printf+0xc0>
                putc(*s++);
    80000786:	0c05                	addi	s8,s8,1
    80000788:	00078c9b          	sext.w	s9,a5
    if (c == '\n')
    8000078c:	ff2795e3          	bne	a5,s2,80000776 <printf+0x144>
        my_put('\r');
    80000790:	4535                	li	a0,13
    80000792:	00000097          	auipc	ra,0x0
    80000796:	d94080e7          	jalr	-620(ra) # 80000526 <my_put>
    8000079a:	bff1                	j	80000776 <printf+0x144>
            printptr((uint64)va_arg(ap, void *));
    8000079c:	f9843783          	ld	a5,-104(s0)
    my_put(c);
    800007a0:	03000513          	li	a0,48
    800007a4:	03c00c93          	li	s9,60
            printptr((uint64)va_arg(ap, void *));
    800007a8:	00878713          	addi	a4,a5,8
    800007ac:	0007bc03          	ld	s8,0(a5)
    800007b0:	f8e43c23          	sd	a4,-104(s0)
    my_put(c);
    800007b4:	00000097          	auipc	ra,0x0
    800007b8:	d72080e7          	jalr	-654(ra) # 80000526 <my_put>
    800007bc:	07800513          	li	a0,120
    800007c0:	00000097          	auipc	ra,0x0
    800007c4:	d66080e7          	jalr	-666(ra) # 80000526 <my_put>
    for (int i = 0; i < 16; i++) {
    800007c8:	a809                	j	800007da <printf+0x1a8>
    800007ca:	3cf1                	addiw	s9,s9,-4
    my_put(c);
    800007cc:	856a                	mv	a0,s10
    800007ce:	00000097          	auipc	ra,0x0
    800007d2:	d58080e7          	jalr	-680(ra) # 80000526 <my_put>
    for (int i = 0; i < 16; i++) {
    800007d6:	f14c8ee3          	beq	s9,s4,800006f2 <printf+0xc0>
        putc(digits[(x >> shift) & 0xf]);
    800007da:	019c57b3          	srl	a5,s8,s9
    800007de:	8bbd                	andi	a5,a5,15
    800007e0:	97d6                	add	a5,a5,s5
    800007e2:	0007cd03          	lbu	s10,0(a5)
    if (c == '\n')
    800007e6:	ff2d12e3          	bne	s10,s2,800007ca <printf+0x198>
        my_put('\r');
    800007ea:	4535                	li	a0,13
    800007ec:	00000097          	auipc	ra,0x0
    800007f0:	d3a080e7          	jalr	-710(ra) # 80000526 <my_put>
    800007f4:	bfd9                	j	800007ca <printf+0x198>
            printint(va_arg(ap, int), 10, 1);
    800007f6:	f9843783          	ld	a5,-104(s0)
    800007fa:	4605                	li	a2,1
    800007fc:	45a9                	li	a1,10
    800007fe:	4388                	lw	a0,0(a5)
    80000800:	07a1                	addi	a5,a5,8
    80000802:	f8f43c23          	sd	a5,-104(s0)
    80000806:	00000097          	auipc	ra,0x0
    8000080a:	d78080e7          	jalr	-648(ra) # 8000057e <printint>
            break;
    8000080e:	b5d5                	j	800006f2 <printf+0xc0>
            putc(va_arg(ap, int));
    80000810:	f9843783          	ld	a5,-104(s0)
    80000814:	0007ac03          	lw	s8,0(a5)
    80000818:	07a1                	addi	a5,a5,8
    8000081a:	f8f43c23          	sd	a5,-104(s0)
    if (c == '\n')
    8000081e:	ed2c15e3          	bne	s8,s2,800006e8 <printf+0xb6>
        my_put('\r');
    80000822:	4535                	li	a0,13
    80000824:	00000097          	auipc	ra,0x0
    80000828:	d02080e7          	jalr	-766(ra) # 80000526 <my_put>
    8000082c:	bd75                	j	800006e8 <printf+0xb6>
    if (c == '\n')
    8000082e:	032c0063          	beq	s8,s2,8000084e <printf+0x21c>
    my_put(c);
    80000832:	8562                	mv	a0,s8
    80000834:	00000097          	auipc	ra,0x0
    80000838:	cf2080e7          	jalr	-782(ra) # 80000526 <my_put>
            continue;
    8000083c:	84e6                	mv	s1,s9
    8000083e:	bd55                	j	800006f2 <printf+0xc0>
    my_put(c);
    80000840:	02500513          	li	a0,37
    80000844:	00000097          	auipc	ra,0x0
    80000848:	ce2080e7          	jalr	-798(ra) # 80000526 <my_put>
}
    8000084c:	b55d                	j	800006f2 <printf+0xc0>
        my_put('\r');
    8000084e:	4535                	li	a0,13
    80000850:	00000097          	auipc	ra,0x0
    80000854:	cd6080e7          	jalr	-810(ra) # 80000526 <my_put>
    80000858:	bfe9                	j	80000832 <printf+0x200>
        initlock(&pr_lock, "printf");
    8000085a:	00001597          	auipc	a1,0x1
    8000085e:	8be58593          	addi	a1,a1,-1858 # 80001118 <kvminithart+0x5ac>
    80000862:	00009517          	auipc	a0,0x9
    80000866:	79e50513          	addi	a0,a0,1950 # 8000a000 <pr_lock>
    8000086a:	00000097          	auipc	ra,0x0
    8000086e:	01c080e7          	jalr	28(ra) # 80000886 <initlock>
        pr_lock_inited = 1;
    80000872:	4785                	li	a5,1
    80000874:	c09c                	sw	a5,0(s1)
    80000876:	bbf5                	j	80000672 <printf+0x40>
                s = "(null)";
    80000878:	00001c17          	auipc	s8,0x1
    8000087c:	898c0c13          	addi	s8,s8,-1896 # 80001110 <kvminithart+0x5a4>
            while (*s)
    80000880:	02800793          	li	a5,40
    80000884:	b709                	j	80000786 <printf+0x154>

0000000080000886 <initlock>:
#include "riscv.h"
#include "spinlock.h"

void initlock(struct spinlock *lk, const char *name) {
    80000886:	1141                	addi	sp,sp,-16
    80000888:	e422                	sd	s0,8(sp)
    8000088a:	0800                	addi	s0,sp,16
    lk->locked = 0;
    lk->name = name;
}
    8000088c:	6422                	ld	s0,8(sp)
    lk->locked = 0;
    8000088e:	00052023          	sw	zero,0(a0)
    lk->name = name;
    80000892:	e50c                	sd	a1,8(a0)
}
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <acquire>:
/*
acquire — 拿锁
先关中断，然后原子地抢锁
抢不到就在原地自旋，直到拿到为止
*/
void acquire(struct spinlock *lk) {
    80000898:	1141                	addi	sp,sp,-16
    8000089a:	e422                	sd	s0,8(sp)
    8000089c:	0800                	addi	s0,sp,16
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
    8000089e:	4789                	li	a5,2
    800008a0:	1007b073          	csrc	sstatus,a5
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0);
    800008a4:	4705                	li	a4,1
    800008a6:	87ba                	mv	a5,a4
    800008a8:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    800008ac:	2781                	sext.w	a5,a5
    800008ae:	ffe5                	bnez	a5,800008a6 <acquire+0xe>
    __sync_synchronize(); // 让其他核能看到 lock 的状态
    800008b0:	0ff0000f          	fence
}
    800008b4:	6422                	ld	s0,8(sp)
    800008b6:	0141                	addi	sp,sp,16
    800008b8:	8082                	ret

00000000800008ba <release>:

/*
release — 放锁
先保证之前的所有内存操作对别的核可见，然后原子放锁，最后开中断
*/
void release(struct spinlock *lk) {
    800008ba:	1141                	addi	sp,sp,-16
    800008bc:	e422                	sd	s0,8(sp)
    800008be:	0800                	addi	s0,sp,16
    __sync_synchronize();
    800008c0:	0ff0000f          	fence
    __sync_lock_release(&lk->locked);
    800008c4:	0f50000f          	fence	iorw,ow
    800008c8:	0805202f          	amoswap.w	zero,zero,(a0)
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
    800008cc:	4789                	li	a5,2
    800008ce:	1007a073          	csrs	sstatus,a5
    intr_on();
}
    800008d2:	6422                	ld	s0,8(sp)
    800008d4:	0141                	addi	sp,sp,16
    800008d6:	8082                	ret

00000000800008d8 <kinit>:
} kmem;

extern char end; // kernel.ld 定义，内核 BSS 之后的首地址

// 初始化
void kinit() {
    800008d8:	7139                	addi	sp,sp,-64
    800008da:	f822                	sd	s0,48(sp)
    800008dc:	f426                	sd	s1,40(sp)
    800008de:	ec4e                	sd	s3,24(sp)
    800008e0:	fc06                	sd	ra,56(sp)
    800008e2:	f04a                	sd	s2,32(sp)
    800008e4:	e852                	sd	s4,16(sp)
    800008e6:	e456                	sd	s5,8(sp)
    800008e8:	0080                	addi	s0,sp,64
    initlock(&kmem.lock, "kmem");
    800008ea:	00001597          	auipc	a1,0x1
    800008ee:	8a658593          	addi	a1,a1,-1882 # 80001190 <digits+0x18>
    800008f2:	00009517          	auipc	a0,0x9
    800008f6:	71e50513          	addi	a0,a0,1822 # 8000a010 <kmem>
    800008fa:	00000097          	auipc	ra,0x0
    800008fe:	f8c080e7          	jalr	-116(ra) # 80000886 <initlock>

    char *p = (char *)PGROUNDUP((uint64)&end);
    80000902:	77fd                	lui	a5,0xfffff
    80000904:	0000a497          	auipc	s1,0xa
    80000908:	72348493          	addi	s1,s1,1827 # 8000b027 <kernel_pgdir+0xfef>
    8000090c:	8cfd                	and	s1,s1,a5
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    8000090e:	49c5                	li	s3,17
    80000910:	6785                	lui	a5,0x1
    80000912:	97a6                	add	a5,a5,s1
    80000914:	09ee                	slli	s3,s3,0x1b
    80000916:	04f9e863          	bltu	s3,a5,80000966 <kinit+0x8e>
    8000091a:	00088937          	lui	s2,0x88
    8000091e:	197d                	addi	s2,s2,-1 # 87fff <_entry-0x7ff78001>
    80000920:	0932                	slli	s2,s2,0xc
    80000922:	40990933          	sub	s2,s2,s1
    80000926:	993e                	add	s2,s2,a5
    if (((uint64)pa % PGSIZE) != 0|| (char *)pa < (char *)PGROUNDUP((uint64)&end)|| (uint64)pa >= PHYSTOP) {
        return;
    }

    struct run *r = (struct run *)pa;
    acquire(&kmem.lock);
    80000928:	00009a97          	auipc	s5,0x9
    8000092c:	6e8a8a93          	addi	s5,s5,1768 # 8000a010 <kmem>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000930:	6a05                	lui	s4,0x1
    acquire(&kmem.lock);
    80000932:	00009517          	auipc	a0,0x9
    80000936:	6de50513          	addi	a0,a0,1758 # 8000a010 <kmem>
    if (((uint64)pa % PGSIZE) != 0|| (char *)pa < (char *)PGROUNDUP((uint64)&end)|| (uint64)pa >= PHYSTOP) {
    8000093a:	0334f363          	bgeu	s1,s3,80000960 <kinit+0x88>
    acquire(&kmem.lock);
    8000093e:	00000097          	auipc	ra,0x0
    80000942:	f5a080e7          	jalr	-166(ra) # 80000898 <acquire>
    r->next = kmem.freelist;
    80000946:	010ab783          	ld	a5,16(s5)
    kmem.freelist = r;
    release(&kmem.lock);
    8000094a:	00009517          	auipc	a0,0x9
    8000094e:	6c650513          	addi	a0,a0,1734 # 8000a010 <kmem>
    r->next = kmem.freelist;
    80000952:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000954:	009ab823          	sd	s1,16(s5)
    release(&kmem.lock);
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	f62080e7          	jalr	-158(ra) # 800008ba <release>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000960:	94d2                	add	s1,s1,s4
    80000962:	fd2498e3          	bne	s1,s2,80000932 <kinit+0x5a>
}
    80000966:	70e2                	ld	ra,56(sp)
    80000968:	7442                	ld	s0,48(sp)
    8000096a:	74a2                	ld	s1,40(sp)
    8000096c:	7902                	ld	s2,32(sp)
    8000096e:	69e2                	ld	s3,24(sp)
    80000970:	6a42                	ld	s4,16(sp)
    80000972:	6aa2                	ld	s5,8(sp)
    80000974:	6121                	addi	sp,sp,64
    80000976:	8082                	ret

0000000080000978 <kalloc>:
void *kalloc() {
    80000978:	1101                	addi	sp,sp,-32
    8000097a:	e822                	sd	s0,16(sp)
    8000097c:	e426                	sd	s1,8(sp)
    8000097e:	e04a                	sd	s2,0(sp)
    80000980:	ec06                	sd	ra,24(sp)
    80000982:	1000                	addi	s0,sp,32
    acquire(&kmem.lock);
    80000984:	00009917          	auipc	s2,0x9
    80000988:	68c90913          	addi	s2,s2,1676 # 8000a010 <kmem>
    8000098c:	854a                	mv	a0,s2
    8000098e:	00000097          	auipc	ra,0x0
    80000992:	f0a080e7          	jalr	-246(ra) # 80000898 <acquire>
    struct run *r = kmem.freelist;
    80000996:	01093483          	ld	s1,16(s2)
    if (r) {
    8000099a:	c885                	beqz	s1,800009ca <kalloc+0x52>
        kmem.freelist = r->next;
    8000099c:	609c                	ld	a5,0(s1)
    release(&kmem.lock);
    8000099e:	854a                	mv	a0,s2
        kmem.freelist = r->next;
    800009a0:	00f93823          	sd	a5,16(s2)
    release(&kmem.lock);
    800009a4:	00000097          	auipc	ra,0x0
    800009a8:	f16080e7          	jalr	-234(ra) # 800008ba <release>
        for (int i = 0; i < PGSIZE; i++) {
    800009ac:	6705                	lui	a4,0x1
    800009ae:	87a6                	mv	a5,s1
    800009b0:	9726                	add	a4,a4,s1
            v[i] = 0;
    800009b2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
        for (int i = 0; i < PGSIZE; i++) {
    800009b6:	0785                	addi	a5,a5,1
    800009b8:	fef71de3          	bne	a4,a5,800009b2 <kalloc+0x3a>
}
    800009bc:	60e2                	ld	ra,24(sp)
    800009be:	6442                	ld	s0,16(sp)
    800009c0:	6902                	ld	s2,0(sp)
    800009c2:	8526                	mv	a0,s1
    800009c4:	64a2                	ld	s1,8(sp)
    800009c6:	6105                	addi	sp,sp,32
    800009c8:	8082                	ret
    release(&kmem.lock);
    800009ca:	854a                	mv	a0,s2
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	eee080e7          	jalr	-274(ra) # 800008ba <release>
}
    800009d4:	60e2                	ld	ra,24(sp)
    800009d6:	6442                	ld	s0,16(sp)
    800009d8:	6902                	ld	s2,0(sp)
    800009da:	8526                	mv	a0,s1
    800009dc:	64a2                	ld	s1,8(sp)
    800009de:	6105                	addi	sp,sp,32
    800009e0:	8082                	ret

00000000800009e2 <kfree>:
    if (((uint64)pa % PGSIZE) != 0|| (char *)pa < (char *)PGROUNDUP((uint64)&end)|| (uint64)pa >= PHYSTOP) {
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	e3b5                	bnez	a5,80000a4a <kfree+0x68>
void kfree(void *pa) {
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	e822                	sd	s0,16(sp)
    800009ec:	e426                	sd	s1,8(sp)
    800009ee:	ec06                	sd	ra,24(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
    if (((uint64)pa % PGSIZE) != 0|| (char *)pa < (char *)PGROUNDUP((uint64)&end)|| (uint64)pa >= PHYSTOP) {
    800009f4:	0000a797          	auipc	a5,0xa
    800009f8:	63378793          	addi	a5,a5,1587 # 8000b027 <kernel_pgdir+0xfef>
    800009fc:	777d                	lui	a4,0xfffff
    800009fe:	8ff9                	and	a5,a5,a4
    80000a00:	84aa                	mv	s1,a0
    80000a02:	02f56e63          	bltu	a0,a5,80000a3e <kfree+0x5c>
    80000a06:	47c5                	li	a5,17
    80000a08:	07ee                	slli	a5,a5,0x1b
    80000a0a:	02f57a63          	bgeu	a0,a5,80000a3e <kfree+0x5c>
    acquire(&kmem.lock);
    80000a0e:	00009917          	auipc	s2,0x9
    80000a12:	60290913          	addi	s2,s2,1538 # 8000a010 <kmem>
    80000a16:	854a                	mv	a0,s2
    80000a18:	00000097          	auipc	ra,0x0
    80000a1c:	e80080e7          	jalr	-384(ra) # 80000898 <acquire>
    r->next = kmem.freelist;
    80000a20:	01093783          	ld	a5,16(s2)
}
    80000a24:	6442                	ld	s0,16(sp)
    80000a26:	60e2                	ld	ra,24(sp)
    r->next = kmem.freelist;
    80000a28:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000a2a:	00993823          	sd	s1,16(s2)
    release(&kmem.lock);
    80000a2e:	854a                	mv	a0,s2
}
    80000a30:	64a2                	ld	s1,8(sp)
    80000a32:	6902                	ld	s2,0(sp)
    80000a34:	6105                	addi	sp,sp,32
    release(&kmem.lock);
    80000a36:	00000317          	auipc	t1,0x0
    80000a3a:	e8430067          	jr	-380(t1) # 800008ba <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    80000a4a:	8082                	ret

0000000080000a4c <kvmmap>:
    }
    return &pgdir[PX(va, 0)];
}

// 在 pgdir 中对等映射 va→pa，覆盖 sz 字节，权限 perm
static void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
    80000a4c:	711d                	addi	sp,sp,-96
    80000a4e:	e8a2                	sd	s0,80(sp)
    80000a50:	fc4e                	sd	s3,56(sp)
    80000a52:	ec86                	sd	ra,88(sp)
    80000a54:	e4a6                	sd	s1,72(sp)
    80000a56:	e0ca                	sd	s2,64(sp)
    80000a58:	f852                	sd	s4,48(sp)
    80000a5a:	f456                	sd	s5,40(sp)
    80000a5c:	f05a                	sd	s6,32(sp)
    80000a5e:	ec5e                	sd	s7,24(sp)
    80000a60:	e862                	sd	s8,16(sp)
    80000a62:	e466                	sd	s9,8(sp)
    80000a64:	e06a                	sd	s10,0(sp)
    80000a66:	1080                	addi	s0,sp,96
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    80000a68:	00d589b3          	add	s3,a1,a3
    80000a6c:	0935f263          	bgeu	a1,s3,80000af0 <kvmmap+0xa4>
    80000a70:	8c2e                	mv	s8,a1
    80000a72:	8a2a                	mv	s4,a0
    80000a74:	8aba                	mv	s5,a4
    80000a76:	40b60933          	sub	s2,a2,a1
    for (int level = 2; level >= 1; level--) {
    80000a7a:	4c85                	li	s9,1
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    80000a7c:	6b05                	lui	s6,0x1
    80000a7e:	a025                	j	80000aa6 <kvmmap+0x5a>
    return &pgdir[PX(va, 0)];
    80000a80:	00cc5793          	srli	a5,s8,0xc
    80000a84:	1ff7f793          	andi	a5,a5,511
    80000a88:	078e                	slli	a5,a5,0x3
    80000a8a:	953e                	add	a0,a0,a5
        uint64 *pte = walk(pgdir, a, 1);
        if (pte == 0) {
    80000a8c:	c135                	beqz	a0,80000af0 <kvmmap+0xa4>
            return;
        }
        *pte = PA2PTE(pa) | perm | PTE_V;
    80000a8e:	00cbdb93          	srli	s7,s7,0xc
    80000a92:	0baa                	slli	s7,s7,0xa
    80000a94:	015bebb3          	or	s7,s7,s5
    80000a98:	001beb93          	ori	s7,s7,1
    80000a9c:	01753023          	sd	s7,0(a0)
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    80000aa0:	9c5a                	add	s8,s8,s6
    80000aa2:	053c7763          	bgeu	s8,s3,80000af0 <kvmmap+0xa4>
    80000aa6:	01890bb3          	add	s7,s2,s8
    80000aaa:	8552                	mv	a0,s4
    80000aac:	4d09                	li	s10,2
    for (int level = 2; level >= 1; level--) {
    80000aae:	4789                	li	a5,2
        uint64 *pte = &pgdir[PX(va, level)];
    80000ab0:	0037949b          	slliw	s1,a5,0x3
    80000ab4:	9cbd                	addw	s1,s1,a5
    80000ab6:	24b1                	addiw	s1,s1,12
    80000ab8:	009c54b3          	srl	s1,s8,s1
    80000abc:	1ff4f493          	andi	s1,s1,511
    80000ac0:	048e                	slli	s1,s1,0x3
    80000ac2:	94aa                	add	s1,s1,a0
        if (*pte & PTE_V) {
    80000ac4:	6088                	ld	a0,0(s1)
    80000ac6:	00157793          	andi	a5,a0,1
            pgdir = (uint64 *)PTE2PA(*pte);
    80000aca:	8129                	srli	a0,a0,0xa
    80000acc:	0532                	slli	a0,a0,0xc
        if (*pte & PTE_V) {
    80000ace:	ef81                	bnez	a5,80000ae6 <kvmmap+0x9a>
            pgdir = (uint64 *)kalloc();
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	ea8080e7          	jalr	-344(ra) # 80000978 <kalloc>
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
    80000ad8:	00c55793          	srli	a5,a0,0xc
    80000adc:	07aa                	slli	a5,a5,0xa
    80000ade:	0017e793          	ori	a5,a5,1
            if (pgdir == 0)
    80000ae2:	c519                	beqz	a0,80000af0 <kvmmap+0xa4>
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
    80000ae4:	e09c                	sd	a5,0(s1)
    for (int level = 2; level >= 1; level--) {
    80000ae6:	4785                	li	a5,1
    80000ae8:	f99d0ce3          	beq	s10,s9,80000a80 <kvmmap+0x34>
    80000aec:	4d05                	li	s10,1
    80000aee:	b7c9                	j	80000ab0 <kvmmap+0x64>
    }
}
    80000af0:	60e6                	ld	ra,88(sp)
    80000af2:	6446                	ld	s0,80(sp)
    80000af4:	64a6                	ld	s1,72(sp)
    80000af6:	6906                	ld	s2,64(sp)
    80000af8:	79e2                	ld	s3,56(sp)
    80000afa:	7a42                	ld	s4,48(sp)
    80000afc:	7aa2                	ld	s5,40(sp)
    80000afe:	7b02                	ld	s6,32(sp)
    80000b00:	6be2                	ld	s7,24(sp)
    80000b02:	6c42                	ld	s8,16(sp)
    80000b04:	6ca2                	ld	s9,8(sp)
    80000b06:	6d02                	ld	s10,0(sp)
    80000b08:	6125                	addi	sp,sp,96
    80000b0a:	8082                	ret

0000000080000b0c <kvminit>:

// 创建内核页表 — 映射 UART MMIO 和全部 RAM（对等映射）
void kvminit() {
    80000b0c:	1101                	addi	sp,sp,-32
    80000b0e:	e822                	sd	s0,16(sp)
    80000b10:	e426                	sd	s1,8(sp)
    80000b12:	ec06                	sd	ra,24(sp)
    80000b14:	e04a                	sd	s2,0(sp)
    80000b16:	1000                	addi	s0,sp,32
    kernel_pgdir = (uint64 *)kalloc();
    80000b18:	00000097          	auipc	ra,0x0
    80000b1c:	e60080e7          	jalr	-416(ra) # 80000978 <kalloc>
    80000b20:	00009497          	auipc	s1,0x9
    80000b24:	51848493          	addi	s1,s1,1304 # 8000a038 <kernel_pgdir>
    80000b28:	e088                	sd	a0,0(s1)
    if (kernel_pgdir == 0) {
    80000b2a:	c91d                	beqz	a0,80000b60 <kvminit+0x54>
        return;
    }

    kvmmap(kernel_pgdir, UART0, UART0, PGSIZE, PTE_KERN_RW);
    80000b2c:	4719                	li	a4,6
    80000b2e:	6685                	lui	a3,0x1
    80000b30:	10000637          	lui	a2,0x10000
    80000b34:	100005b7          	lui	a1,0x10000
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	f14080e7          	jalr	-236(ra) # 80000a4c <kvmmap>
    kvmmap(kernel_pgdir, KERNBASE, KERNBASE, PHYSTOP - KERNBASE, PTE_KERN_RWX);
    80000b40:	4905                	li	s2,1
    80000b42:	6088                	ld	a0,0(s1)
    80000b44:	01f91613          	slli	a2,s2,0x1f
    80000b48:	4739                	li	a4,14
    80000b4a:	080006b7          	lui	a3,0x8000
    80000b4e:	85b2                	mv	a1,a2
    80000b50:	00000097          	auipc	ra,0x0
    80000b54:	efc080e7          	jalr	-260(ra) # 80000a4c <kvmmap>

    kvminit_done = 1;
    80000b58:	00009797          	auipc	a5,0x9
    80000b5c:	4d27ac23          	sw	s2,1240(a5) # 8000a030 <kvminit_done>
}
    80000b60:	60e2                	ld	ra,24(sp)
    80000b62:	6442                	ld	s0,16(sp)
    80000b64:	64a2                	ld	s1,8(sp)
    80000b66:	6902                	ld	s2,0(sp)
    80000b68:	6105                	addi	sp,sp,32
    80000b6a:	8082                	ret

0000000080000b6c <kvminithart>:

// 启用内核页表（每个 hart 调用）
void kvminithart() {
    80000b6c:	1141                	addi	sp,sp,-16
    80000b6e:	e422                	sd	s0,8(sp)
    80000b70:	0800                	addi	s0,sp,16
    w_satp(MAKE_SATP(kernel_pgdir));
    80000b72:	00009797          	auipc	a5,0x9
    80000b76:	4c67b783          	ld	a5,1222(a5) # 8000a038 <kernel_pgdir>
    80000b7a:	577d                	li	a4,-1
    80000b7c:	177e                	slli	a4,a4,0x3f
    80000b7e:	83b1                	srli	a5,a5,0xc
    80000b80:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    80000b82:	18079073          	csrw	satp,a5
    return x;
}

// 刷新 TLB
static inline void sfence_vma() {
    asm volatile("sfence.vma");
    80000b86:	12000073          	sfence.vma
    sfence_vma();
}
    80000b8a:	6422                	ld	s0,8(sp)
    80000b8c:	0141                	addi	sp,sp,16
    80000b8e:	8082                	ret
