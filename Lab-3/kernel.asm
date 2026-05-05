
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
    80000016:	00000097          	auipc	ra,0x0
    8000001a:	076080e7          	jalr	118(ra) # 8000008c <start>

000000008000001e <r_mstatus>:
#include "types.h"

void main();
extern void timer_vector();

uint64 r_mstatus() {
    8000001e:	1141                	addi	sp,sp,-16
    80000020:	e422                	sd	s0,8(sp)
    80000022:	0800                	addi	s0,sp,16
    uint64 x;
    // asm volatile("汇编指令" : 输出列表 : 输入列表);
    asm volatile("csrr %0, mstatus" : "=r"(x));
    80000024:	30002573          	csrr	a0,mstatus
    return x;
}
    80000028:	6422                	ld	s0,8(sp)
    8000002a:	0141                	addi	sp,sp,16
    8000002c:	8082                	ret

000000008000002e <w_mstatus>:

void w_mstatus(uint64 x) {
    8000002e:	1141                	addi	sp,sp,-16
    80000030:	e422                	sd	s0,8(sp)
    80000032:	0800                	addi	s0,sp,16
    asm volatile("csrw mstatus, %0" : : "r"(x));
    80000034:	30051073          	csrw	mstatus,a0
}
    80000038:	6422                	ld	s0,8(sp)
    8000003a:	0141                	addi	sp,sp,16
    8000003c:	8082                	ret

000000008000003e <w_mepc>:

void w_mepc(uint64 x) {
    8000003e:	1141                	addi	sp,sp,-16
    80000040:	e422                	sd	s0,8(sp)
    80000042:	0800                	addi	s0,sp,16
    asm volatile("csrw mepc, %0" : : "r"(x));
    80000044:	34151073          	csrw	mepc,a0
}
    80000048:	6422                	ld	s0,8(sp)
    8000004a:	0141                	addi	sp,sp,16
    8000004c:	8082                	ret

000000008000004e <w_pmpaddr0>:

void w_pmpaddr0(uint64 x) {
    8000004e:	1141                	addi	sp,sp,-16
    80000050:	e422                	sd	s0,8(sp)
    80000052:	0800                	addi	s0,sp,16
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    80000054:	3b051073          	csrw	pmpaddr0,a0
}
    80000058:	6422                	ld	s0,8(sp)
    8000005a:	0141                	addi	sp,sp,16
    8000005c:	8082                	ret

000000008000005e <w_pmpcfg0>:

void w_pmpcfg0(uint64 x) {
    8000005e:	1141                	addi	sp,sp,-16
    80000060:	e422                	sd	s0,8(sp)
    80000062:	0800                	addi	s0,sp,16
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    80000064:	3a051073          	csrw	pmpcfg0,a0
}
    80000068:	6422                	ld	s0,8(sp)
    8000006a:	0141                	addi	sp,sp,16
    8000006c:	8082                	ret

000000008000006e <r_mhartid>:

uint64 r_mhartid(void) {
    8000006e:	1141                	addi	sp,sp,-16
    80000070:	e422                	sd	s0,8(sp)
    80000072:	0800                	addi	s0,sp,16
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    80000074:	f1402573          	csrr	a0,mhartid
    return x;
}
    80000078:	6422                	ld	s0,8(sp)
    8000007a:	0141                	addi	sp,sp,16
    8000007c:	8082                	ret

000000008000007e <w_tp>:

void w_tp(uint64 x) {
    8000007e:	1141                	addi	sp,sp,-16
    80000080:	e422                	sd	s0,8(sp)
    80000082:	0800                	addi	s0,sp,16
    asm volatile("mv tp, %0" : : "r"(x));
    80000084:	822a                	mv	tp,a0
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:


void start() {
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e422                	sd	s0,8(sp)
    80000090:	0800                	addi	s0,sp,16
    asm volatile("csrr %0, mhartid" : "=r"(x));
    80000092:	f14027f3          	csrr	a5,mhartid
    asm volatile("mv tp, %0" : : "r"(x));
    80000096:	823e                	mv	tp,a5
    asm volatile("csrr %0, mstatus" : "=r"(x));
    80000098:	300027f3          	csrr	a5,mstatus
    // 3（二进制 11）	M-mode
    // 1（二进制 01）	S-mode
    // 0（二进制 00）	U-mode

    // x 现在是 M-mode，将其变为 S-mode
    x &= ~(2UL << 11);   // 清 bit12 (M-mode → 不设就是 U-mode)
    8000009c:	76fd                	lui	a3,0xfffff
    8000009e:	16fd                	addi	a3,a3,-1 # ffffffffffffefff <ticks+0xffffffff7fff46ff>
    x |=  (1UL << 11);   // 设 bit11 = S-mode
    x |=  (1UL << 7);    // MPIE = 1, mret 后 MIE 自动 = 1 (允许 M-mode 中断打断 S-mode)
    800000a0:	6705                	lui	a4,0x1
    x &= ~(2UL << 11);   // 清 bit12 (M-mode → 不设就是 U-mode)
    800000a2:	8ff5                	and	a5,a5,a3
    x |=  (1UL << 7);    // MPIE = 1, mret 后 MIE 自动 = 1 (允许 M-mode 中断打断 S-mode)
    800000a4:	88070713          	addi	a4,a4,-1920 # 880 <_entry-0x7ffff780>
    800000a8:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800000aa:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc, %0" : : "r"(x));
    800000ae:	00000797          	auipc	a5,0x0
    800000b2:	04c78793          	addi	a5,a5,76 # 800000fa <main>
    800000b6:	34179073          	csrw	mepc,a5
    w_mstatus(x);

    w_mepc((uint64)main);

    // 开启分页前先关 MMU
    asm volatile("csrw satp, %0" : : "r"(0));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5

    // medeleg: 不委托异常（全部留在 M-mode）
    asm volatile("csrw medeleg, %0" : : "r"(0));
    800000c0:	30279073          	csrw	medeleg,a5

    // mideleg: 委托 S-mode 软件中断、时钟中断、外部中断
    // bit1=SSIP, bit5=STIP, bit9=SEIP
    asm volatile("csrw mideleg, %0" : : "r"((1UL << 1) | (1UL << 5) | (1UL << 9)));
    800000c4:	22200793          	li	a5,546
    800000c8:	30379073          	csrw	mideleg,a5

    // mtvec → timer_vector: M-mode 时钟中断由此处理
    asm volatile("csrw mtvec, %0" : : "r"(timer_vector));
    800000cc:	00001797          	auipc	a5,0x1
    800000d0:	b1478793          	addi	a5,a5,-1260 # 80000be0 <timer_vector>
    800000d4:	30579073          	csrw	mtvec,a5

    // mie: 开 M-mode 时钟中断 (MTIE=bit7)
    asm volatile("csrs mie, %0" : : "r"(1UL << 7));
    800000d8:	08000793          	li	a5,128
    800000dc:	3047a073          	csrs	mie,a5

    // 允许 S-mode 读 time/cycle/instret CSR (bit0=cycle, bit1=time, bit2=instret)
    asm volatile("csrw mcounteren, %0" : : "r"(7));
    800000e0:	479d                	li	a5,7
    800000e2:	30679073          	csrw	mcounteren,a5
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000e6:	57fd                	li	a5,-1
    800000e8:	83a9                	srli	a5,a5,0xa
    800000ea:	3b079073          	csrw	pmpaddr0,a5
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000ee:	47bd                	li	a5,15
    800000f0:	3a079073          	csrw	pmpcfg0,a5

    w_pmpaddr0(0x3fffffffffffffull);    // 放行全部物理地址
    w_pmpcfg0(0xf);                     // 可读可写可执行

    asm volatile("mret");
    800000f4:	30200073          	mret

    while (1) {}
    800000f8:	a001                	j	800000f8 <start+0x6c>

00000000800000fa <main>:
#include "uart.h"
#include "vm.h"

extern volatile uint64 ticks;

void main() {
    800000fa:	1101                	addi	sp,sp,-32
    800000fc:	e822                	sd	s0,16(sp)
    800000fe:	ec06                	sd	ra,24(sp)
    80000100:	e426                	sd	s1,8(sp)
    80000102:	e04a                	sd	s2,0(sp)
    80000104:	1000                	addi	s0,sp,32
    uint64 hartid;

    uartinit();
    80000106:	00000097          	auipc	ra,0x0
    8000010a:	1d6080e7          	jalr	470(ra) # 800002dc <uartinit>
#include "types.h"

// 读 tp 寄存器 (hartid 从 M-mode 带下来存在这里)
static inline uint64 r_tp(void) {
    uint64 x;
    asm volatile("mv %0, tp" : "=r"(x));
    8000010e:	8492                	mv	s1,tp
    hartid = r_tp();

    printf("\n");
    80000110:	00001517          	auipc	a0,0x1
    80000114:	b6050513          	addi	a0,a0,-1184 # 80000c70 <clock_intr+0x20>
    80000118:	00000097          	auipc	ra,0x0
    8000011c:	2fe080e7          	jalr	766(ra) # 80000416 <printf>
    printf("=== Lab3: hart %d ===\n", (int)hartid);
    80000120:	0004891b          	sext.w	s2,s1
    80000124:	85ca                	mv	a1,s2
    80000126:	00001517          	auipc	a0,0x1
    8000012a:	b5250513          	addi	a0,a0,-1198 # 80000c78 <clock_intr+0x28>
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	2e8080e7          	jalr	744(ra) # 80000416 <printf>

    // hart 0 负责初始化物理内存和内核页表
    if (hartid == 0) {
    80000136:	10048f63          	beqz	s1,80000254 <main+0x15a>
    8000013a:	0000a717          	auipc	a4,0xa
    8000013e:	7b670713          	addi	a4,a4,1974 # 8000a8f0 <kvminit_done>
        printf("[hart %d] trap_kernel_init: stvec set, PLIC inited\n",
               (int)hartid);
    }

    // 其他 hart 自旋等待 hart 0 完成 kvminit
    while (!kvminit_done) {}
    80000142:	431c                	lw	a5,0(a4)
    80000144:	dffd                	beqz	a5,80000142 <main+0x48>

    // 每个 hart 启用内核页表
    kvminithart();
    80000146:	00001097          	auipc	ra,0x1
    8000014a:	850080e7          	jalr	-1968(ra) # 80000996 <kvminithart>
    asm volatile("csrw satp, %0" : : "r"(x));
}

static inline uint64 r_satp() {
    uint64 x;
    asm volatile("csrr %0, satp" : "=r"(x));
    8000014e:	18002673          	csrr	a2,satp
    printf("[hart %d] kvminithart: satp = %p, paging enabled\n", (int)hartid, (void *)r_satp());
    80000152:	00001517          	auipc	a0,0x1
    80000156:	bd650513          	addi	a0,a0,-1066 # 80000d28 <clock_intr+0xd8>
    8000015a:	85ca                	mv	a1,s2
    8000015c:	00000097          	auipc	ra,0x0
    80000160:	2ba080e7          	jalr	698(ra) # 80000416 <printf>

    // 每个 hart 配置自己的陷阱入口和中断
    trap_kernel_inithart();
    80000164:	00001097          	auipc	ra,0x1
    80000168:	93c080e7          	jalr	-1732(ra) # 80000aa0 <trap_kernel_inithart>
    printf("[hart %d] trap_kernel_inithart: interrupts enabled\n", (int)hartid);
    8000016c:	85ca                	mv	a1,s2
    8000016e:	00001517          	auipc	a0,0x1
    80000172:	bf250513          	addi	a0,a0,-1038 # 80000d60 <clock_intr+0x110>
    80000176:	00000097          	auipc	ra,0x0
    8000017a:	2a0080e7          	jalr	672(ra) # 80000416 <printf>

    if (hartid == 0) {
    8000017e:	c491                	beqz	s1,8000018a <main+0x90>
    asm volatile("wfi");
    80000180:	10500073          	wfi
    80000184:	10500073          	wfi

        printf("[hart %d] --- test8 done ---\n", (int)hartid);
        printf("[hart %d] === ALL TESTS PASSED ===\n", (int)hartid);
    }

    for (;;) {
    80000188:	bfe5                	j	80000180 <main+0x86>
        timer_init();
    8000018a:	00001097          	auipc	ra,0x1
    8000018e:	a98080e7          	jalr	-1384(ra) # 80000c22 <timer_init>
        printf("[hart %d] --- test8: interrupt system ---\n", (int)hartid);
    80000192:	4581                	li	a1,0
    80000194:	00001517          	auipc	a0,0x1
    80000198:	c0450513          	addi	a0,a0,-1020 # 80000d98 <clock_intr+0x148>
        uint64 t0 = ticks;
    8000019c:	0000a497          	auipc	s1,0xa
    800001a0:	76448493          	addi	s1,s1,1892 # 8000a900 <ticks>
        printf("[hart %d] --- test8: interrupt system ---\n", (int)hartid);
    800001a4:	00000097          	auipc	ra,0x0
    800001a8:	272080e7          	jalr	626(ra) # 80000416 <printf>
        uint64 t0 = ticks;
    800001ac:	0004b903          	ld	s2,0(s1)
        printf("[hart %d] initial ticks=%d\n", (int)hartid, (int)t0);
    800001b0:	4581                	li	a1,0
    800001b2:	00001517          	auipc	a0,0x1
    800001b6:	c1650513          	addi	a0,a0,-1002 # 80000dc8 <clock_intr+0x178>
    800001ba:	0009061b          	sext.w	a2,s2
    800001be:	00000097          	auipc	ra,0x0
    800001c2:	258080e7          	jalr	600(ra) # 80000416 <printf>
        printf("[hart %d] waiting for 5 clock interrupts...\n", (int)hartid);
    800001c6:	4581                	li	a1,0
    800001c8:	00001517          	auipc	a0,0x1
    800001cc:	c2050513          	addi	a0,a0,-992 # 80000de8 <clock_intr+0x198>
    800001d0:	00000097          	auipc	ra,0x0
    800001d4:	246080e7          	jalr	582(ra) # 80000416 <printf>
        while (ticks < t0 + 5) {}
    800001d8:	00590713          	addi	a4,s2,5
    800001dc:	609c                	ld	a5,0(s1)
    800001de:	fee7efe3          	bltu	a5,a4,800001dc <main+0xe2>
        printf("[hart %d] final ticks=%d\n", (int)hartid, (int)ticks);
    800001e2:	6090                	ld	a2,0(s1)
    800001e4:	4581                	li	a1,0
    800001e6:	00001517          	auipc	a0,0x1
    800001ea:	c3250513          	addi	a0,a0,-974 # 80000e18 <clock_intr+0x1c8>
    800001ee:	2601                	sext.w	a2,a2
    800001f0:	00000097          	auipc	ra,0x0
    800001f4:	226080e7          	jalr	550(ra) # 80000416 <printf>
        printf("[hart %d] expect: ticks >= %d\n",
    800001f8:	0059061b          	addiw	a2,s2,5
    800001fc:	4581                	li	a1,0
    800001fe:	00001517          	auipc	a0,0x1
    80000202:	c3a50513          	addi	a0,a0,-966 # 80000e38 <clock_intr+0x1e8>
    80000206:	00000097          	auipc	ra,0x0
    8000020a:	210080e7          	jalr	528(ra) # 80000416 <printf>
        printf("[hart %d] UART interrupt is ready, press some keys...\n",
    8000020e:	4581                	li	a1,0
    80000210:	00001517          	auipc	a0,0x1
    80000214:	c4850513          	addi	a0,a0,-952 # 80000e58 <clock_intr+0x208>
    80000218:	00000097          	auipc	ra,0x0
    8000021c:	1fe080e7          	jalr	510(ra) # 80000416 <printf>
        while (ticks < t0 + 20) {}
    80000220:	01490713          	addi	a4,s2,20
    80000224:	609c                	ld	a5,0(s1)
    80000226:	fee7efe3          	bltu	a5,a4,80000224 <main+0x12a>
        printf("[hart %d] --- test8 done ---\n", (int)hartid);
    8000022a:	4581                	li	a1,0
    8000022c:	00001517          	auipc	a0,0x1
    80000230:	c6450513          	addi	a0,a0,-924 # 80000e90 <clock_intr+0x240>
    80000234:	00000097          	auipc	ra,0x0
    80000238:	1e2080e7          	jalr	482(ra) # 80000416 <printf>
        printf("[hart %d] === ALL TESTS PASSED ===\n", (int)hartid);
    8000023c:	4581                	li	a1,0
    8000023e:	00001517          	auipc	a0,0x1
    80000242:	c7250513          	addi	a0,a0,-910 # 80000eb0 <clock_intr+0x260>
    80000246:	00000097          	auipc	ra,0x0
    8000024a:	1d0080e7          	jalr	464(ra) # 80000416 <printf>
    8000024e:	10500073          	wfi
    for (;;) {
    80000252:	bf0d                	j	80000184 <main+0x8a>
        kinit();
    80000254:	00000097          	auipc	ra,0x0
    80000258:	486080e7          	jalr	1158(ra) # 800006da <kinit>
        printf("[hart %d] kinit: free list built from %p to %p\n",
    8000025c:	46c5                	li	a3,17
    8000025e:	4605                	li	a2,1
    80000260:	06ee                	slli	a3,a3,0x1b
    80000262:	067e                	slli	a2,a2,0x1f
    80000264:	4581                	li	a1,0
    80000266:	00001517          	auipc	a0,0x1
    8000026a:	a2a50513          	addi	a0,a0,-1494 # 80000c90 <clock_intr+0x40>
    8000026e:	00000097          	auipc	ra,0x0
    80000272:	1a8080e7          	jalr	424(ra) # 80000416 <printf>
        kvminit();
    80000276:	00000097          	auipc	ra,0x0
    8000027a:	696080e7          	jalr	1686(ra) # 8000090c <kvminit>
        printf("[hart %d] kvminit: kernel page table at %p\n",
    8000027e:	0000a617          	auipc	a2,0xa
    80000282:	67a63603          	ld	a2,1658(a2) # 8000a8f8 <kernel_pgdir>
    80000286:	4581                	li	a1,0
    80000288:	00001517          	auipc	a0,0x1
    8000028c:	a3850513          	addi	a0,a0,-1480 # 80000cc0 <clock_intr+0x70>
    80000290:	00000097          	auipc	ra,0x0
    80000294:	186080e7          	jalr	390(ra) # 80000416 <printf>
        trap_kernel_init();
    80000298:	00000097          	auipc	ra,0x0
    8000029c:	7f6080e7          	jalr	2038(ra) # 80000a8e <trap_kernel_init>
        printf("[hart %d] trap_kernel_init: stvec set, PLIC inited\n",
    800002a0:	4581                	li	a1,0
    800002a2:	00001517          	auipc	a0,0x1
    800002a6:	a4e50513          	addi	a0,a0,-1458 # 80000cf0 <clock_intr+0xa0>
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	16c080e7          	jalr	364(ra) # 80000416 <printf>
    800002b2:	b561                	j	8000013a <main+0x40>

00000000800002b4 <my_put>:
#define LSR_TX_IDLE     0x20  // bit5: 发送器空闲
#define LSR_RX_READY    0x01  // bit0: 有数据

static volatile uint8 *const uart = (volatile uint8 *)UART0;

void my_put(int c) {
    800002b4:	1141                	addi	sp,sp,-16
    800002b6:	e422                	sd	s0,8(sp)
    // 等发送器空闲
    while ((uart[LSR] & LSR_TX_IDLE) == 0) {}
    800002b8:	10000737          	lui	a4,0x10000
void my_put(int c) {
    800002bc:	0800                	addi	s0,sp,16
    while ((uart[LSR] & LSR_TX_IDLE) == 0) {}
    800002be:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800002c0:	00074783          	lbu	a5,0(a4)
    800002c4:	0207f793          	andi	a5,a5,32
    800002c8:	dfe5                	beqz	a5,800002c0 <my_put+0xc>

    uart[THR] = (uint8)c;
    800002ca:	0ff57513          	zext.b	a0,a0
    800002ce:	100007b7          	lui	a5,0x10000
    800002d2:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    800002d6:	6422                	ld	s0,8(sp)
    800002d8:	0141                	addi	sp,sp,16
    800002da:	8082                	ret

00000000800002dc <uartinit>:

void uartinit() {
    800002dc:	1141                	addi	sp,sp,-16
    800002de:	e422                	sd	s0,8(sp)
    800002e0:	0800                	addi	s0,sp,16
    // 关中断
    uart[IER] = 0x00;
    800002e2:	100007b7          	lui	a5,0x10000
    800002e6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

    // 设置波特率
    uart[LCR] = LCR_BAUD_LATCH;
    800002ea:	10000737          	lui	a4,0x10000
    800002ee:	f8000693          	li	a3,-128
    800002f2:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>
    uart[0] = 0x03;
    800002f6:	460d                	li	a2,3
    uart[IER] = 0x00;
    800002f8:	100006b7          	lui	a3,0x10000
    uart[0] = 0x03;
    800002fc:	00c68023          	sb	a2,0(a3) # 10000000 <_entry-0x70000000>
    uart[1] = 0x00;
    80000300:	000780a3          	sb	zero,1(a5)

    uart[LCR] = LCR_EIGHT_BITS;
    80000304:	00c701a3          	sb	a2,3(a4)

    // 开 FIFO 清空
    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;
    80000308:	471d                	li	a4,7
    8000030a:	00e68123          	sb	a4,2(a3)

    // 使能接收和发送中断
    uart[IER] = IER_RX_TX;
    8000030e:	4705                	li	a4,1
    80000310:	00e780a3          	sb	a4,1(a5)
}
    80000314:	6422                	ld	s0,8(sp)
    80000316:	0141                	addi	sp,sp,16
    80000318:	8082                	ret

000000008000031a <uart_intr>:

// 中断驱动接收 — 读取收到的字符并回显
void uart_intr() {
    8000031a:	7179                	addi	sp,sp,-48
    8000031c:	f022                	sd	s0,32(sp)
    8000031e:	ec26                	sd	s1,24(sp)
    80000320:	f406                	sd	ra,40(sp)
    80000322:	1800                	addi	s0,sp,48
    while (uart[LSR] & LSR_RX_READY) {
    80000324:	100004b7          	lui	s1,0x10000
    80000328:	0054c783          	lbu	a5,5(s1) # 10000005 <_entry-0x6ffffffb>
    8000032c:	8b85                	andi	a5,a5,1
    8000032e:	c79d                	beqz	a5,8000035c <uart_intr+0x42>
    80000330:	e84a                	sd	s2,16(sp)
    80000332:	e44e                	sd	s3,8(sp)
    80000334:	0495                	addi	s1,s1,5
        int c = uart[RHR];
    80000336:	100009b7          	lui	s3,0x10000
        printf("[UART intr] received: '%c'\n", c);
    8000033a:	00001917          	auipc	s2,0x1
    8000033e:	b9e90913          	addi	s2,s2,-1122 # 80000ed8 <clock_intr+0x288>
        int c = uart[RHR];
    80000342:	0009c583          	lbu	a1,0(s3) # 10000000 <_entry-0x70000000>
        printf("[UART intr] received: '%c'\n", c);
    80000346:	854a                	mv	a0,s2
    80000348:	00000097          	auipc	ra,0x0
    8000034c:	0ce080e7          	jalr	206(ra) # 80000416 <printf>
    while (uart[LSR] & LSR_RX_READY) {
    80000350:	0004c783          	lbu	a5,0(s1)
    80000354:	8b85                	andi	a5,a5,1
    80000356:	f7f5                	bnez	a5,80000342 <uart_intr+0x28>
    80000358:	6942                	ld	s2,16(sp)
    8000035a:	69a2                	ld	s3,8(sp)
    }
    8000035c:	70a2                	ld	ra,40(sp)
    8000035e:	7402                	ld	s0,32(sp)
    80000360:	64e2                	ld	s1,24(sp)
    80000362:	6145                	addi	sp,sp,48
    80000364:	8082                	ret

0000000080000366 <printint>:

/* 按指定进制打印整数
   base: 10=十进制, 16=十六进制
   sign: 1=负号, 0=无负号 
*/
static void printint(int64 xx, int base, int sign) {
    80000366:	715d                	addi	sp,sp,-80
    80000368:	e0a2                	sd	s0,64(sp)
    8000036a:	e486                	sd	ra,72(sp)
    8000036c:	fc26                	sd	s1,56(sp)
    8000036e:	f84a                	sd	s2,48(sp)
    80000370:	f44e                	sd	s3,40(sp)
    80000372:	f052                	sd	s4,32(sp)
    80000374:	0880                	addi	s0,sp,80
    char buf[32];
    uint64 x;

    if (sign && xx < 0) {
    80000376:	c609                	beqz	a2,80000380 <printint+0x1a>
        x = (uint64)(-xx);
    80000378:	40a007b3          	neg	a5,a0
    if (sign && xx < 0) {
    8000037c:	00054363          	bltz	a0,80000382 <printint+0x1c>
    } else {
        x = (uint64)xx;
    80000380:	87aa                	mv	a5,a0
    }

    int i = 0;
    do {
        buf[i++] = digits[x % base];
    80000382:	fb040693          	addi	a3,s0,-80
    80000386:	4801                	li	a6,0
    80000388:	00001317          	auipc	t1,0x1
    8000038c:	be030313          	addi	t1,t1,-1056 # 80000f68 <digits>
    80000390:	02b7f733          	remu	a4,a5,a1
        x /= base;
    } while (x != 0);
    80000394:	0685                	addi	a3,a3,1
    80000396:	88be                	mv	a7,a5
    80000398:	84c2                	mv	s1,a6
        buf[i++] = digits[x % base];
    8000039a:	2805                	addiw	a6,a6,1
    8000039c:	971a                	add	a4,a4,t1
    8000039e:	00074703          	lbu	a4,0(a4)
        x /= base;
    800003a2:	02b7d7b3          	divu	a5,a5,a1
        buf[i++] = digits[x % base];
    800003a6:	fee68fa3          	sb	a4,-1(a3)
    } while (x != 0);
    800003aa:	feb8f3e3          	bgeu	a7,a1,80000390 <printint+0x2a>

    if (sign && xx < 0) {
    800003ae:	c219                	beqz	a2,800003b4 <printint+0x4e>
    800003b0:	04054a63          	bltz	a0,80000404 <printint+0x9e>
    800003b4:	fb040793          	addi	a5,s0,-80
    800003b8:	94be                	add	s1,s1,a5
    800003ba:	fff78993          	addi	s3,a5,-1
    if (c == '\n') {
    800003be:	4a29                	li	s4,10
    800003c0:	a809                	j	800003d2 <printint+0x6c>
    my_put(c);
    800003c2:	854a                	mv	a0,s2
        buf[i++] = '-';
    }

    while (--i >= 0) {
    800003c4:	14fd                	addi	s1,s1,-1
    my_put(c);
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	eee080e7          	jalr	-274(ra) # 800002b4 <my_put>
    while (--i >= 0) {
    800003ce:	03348363          	beq	s1,s3,800003f4 <printint+0x8e>
        putc(buf[i]);
    800003d2:	0004c903          	lbu	s2,0(s1)
    if (c == '\n') {
    800003d6:	ff4916e3          	bne	s2,s4,800003c2 <printint+0x5c>
        my_put('\r');
    800003da:	4535                	li	a0,13
    800003dc:	00000097          	auipc	ra,0x0
    800003e0:	ed8080e7          	jalr	-296(ra) # 800002b4 <my_put>
    my_put(c);
    800003e4:	854a                	mv	a0,s2
    while (--i >= 0) {
    800003e6:	14fd                	addi	s1,s1,-1
    my_put(c);
    800003e8:	00000097          	auipc	ra,0x0
    800003ec:	ecc080e7          	jalr	-308(ra) # 800002b4 <my_put>
    while (--i >= 0) {
    800003f0:	ff3491e3          	bne	s1,s3,800003d2 <printint+0x6c>
    }
}
    800003f4:	60a6                	ld	ra,72(sp)
    800003f6:	6406                	ld	s0,64(sp)
    800003f8:	74e2                	ld	s1,56(sp)
    800003fa:	7942                	ld	s2,48(sp)
    800003fc:	79a2                	ld	s3,40(sp)
    800003fe:	7a02                	ld	s4,32(sp)
    80000400:	6161                	addi	sp,sp,80
    80000402:	8082                	ret
        buf[i++] = '-';
    80000404:	fd080793          	addi	a5,a6,-48
    80000408:	97a2                	add	a5,a5,s0
    8000040a:	02d00713          	li	a4,45
    8000040e:	fee78023          	sb	a4,-32(a5)
    while (--i >= 0) {
    80000412:	84c2                	mv	s1,a6
    80000414:	b745                	j	800003b4 <printint+0x4e>

0000000080000416 <printf>:

static struct spinlock pr_lock;
static int pr_lock_inited;

// 格式化输出。支持 %d %u %x %p %s %c %%
void printf(const char *fmt, ...) {
    80000416:	7131                	addi	sp,sp,-192
    80000418:	f8a2                	sd	s0,112(sp)
    8000041a:	f4a6                	sd	s1,104(sp)
    8000041c:	0100                	addi	s0,sp,128
    8000041e:	f0ca                	sd	s2,96(sp)
    80000420:	fc86                	sd	ra,120(sp)
    80000422:	ecce                	sd	s3,88(sp)
    int c;
    const char *s;
    va_list ap;

    if (!pr_lock_inited) {
    80000424:	0000a917          	auipc	s2,0xa
    80000428:	4c490913          	addi	s2,s2,1220 # 8000a8e8 <pr_lock_inited>
    8000042c:	00092303          	lw	t1,0(s2)
void printf(const char *fmt, ...) {
    80000430:	e40c                	sd	a1,8(s0)
    80000432:	e810                	sd	a2,16(s0)
    80000434:	ec14                	sd	a3,24(s0)
    80000436:	f018                	sd	a4,32(s0)
    80000438:	f41c                	sd	a5,40(s0)
    8000043a:	03043823          	sd	a6,48(s0)
    8000043e:	03143c23          	sd	a7,56(s0)
    80000442:	84aa                	mv	s1,a0
    if (!pr_lock_inited) {
    80000444:	20030b63          	beqz	t1,8000065a <printf+0x244>
        initlock(&pr_lock, "printf");
        pr_lock_inited = 1;
    }

    acquire(&pr_lock);
    80000448:	0000a517          	auipc	a0,0xa
    8000044c:	bb850513          	addi	a0,a0,-1096 # 8000a000 <pr_lock>
    80000450:	00000097          	auipc	ra,0x0
    80000454:	24a080e7          	jalr	586(ra) # 8000069a <acquire>
    va_start(ap, fmt);
    for (; (c = *fmt) != 0; fmt++) {
    80000458:	0004c983          	lbu	s3,0(s1)
    va_start(ap, fmt);
    8000045c:	00840793          	addi	a5,s0,8
    80000460:	f8f43423          	sd	a5,-120(s0)
    for (; (c = *fmt) != 0; fmt++) {
    80000464:	06098c63          	beqz	s3,800004dc <printf+0xc6>
    80000468:	fc5e                	sd	s7,56(sp)
    8000046a:	f862                	sd	s8,48(sp)
    8000046c:	f466                	sd	s9,40(sp)
    8000046e:	e8d2                	sd	s4,80(sp)
    80000470:	e4d6                	sd	s5,72(sp)
        if (c != '%') {
    80000472:	02500913          	li	s2,37
        fmt++;
        if (*fmt == 0) {
            break;
        }

        switch (*fmt) {
    80000476:	4c55                	li	s8,21
    80000478:	00001b97          	auipc	s7,0x1
    8000047c:	a98b8b93          	addi	s7,s7,-1384 # 80000f10 <clock_intr+0x2c0>
    if (c == '\n') {
    80000480:	4ca9                	li	s9,10
        if (c != '%') {
    80000482:	1b299763          	bne	s3,s2,80000630 <printf+0x21a>
        if (*fmt == 0) {
    80000486:	0014c783          	lbu	a5,1(s1)
    8000048a:	c7a1                	beqz	a5,800004d2 <printf+0xbc>
        switch (*fmt) {
    8000048c:	1b278a63          	beq	a5,s2,80000640 <printf+0x22a>
    80000490:	f9d7879b          	addiw	a5,a5,-99
    80000494:	0ff7f793          	zext.b	a5,a5
    80000498:	00fc6763          	bltu	s8,a5,800004a6 <printf+0x90>
    8000049c:	078a                	slli	a5,a5,0x2
    8000049e:	97de                	add	a5,a5,s7
    800004a0:	439c                	lw	a5,0(a5)
    800004a2:	97de                	add	a5,a5,s7
    800004a4:	8782                	jr	a5
    my_put(c);
    800004a6:	02500513          	li	a0,37
    800004aa:	00000097          	auipc	ra,0x0
    800004ae:	e0a080e7          	jalr	-502(ra) # 800002b4 <my_put>
        case '%':
            putc('%');
            break;
        default:
            putc('%');
            putc(*fmt);
    800004b2:	0014c983          	lbu	s3,1(s1)
    if (c == '\n') {
    800004b6:	47a9                	li	a5,10
    800004b8:	16f98663          	beq	s3,a5,80000624 <printf+0x20e>
    my_put(c);
    800004bc:	854e                	mv	a0,s3
    800004be:	00000097          	auipc	ra,0x0
    800004c2:	df6080e7          	jalr	-522(ra) # 800002b4 <my_put>
        fmt++;
    800004c6:	0485                	addi	s1,s1,1
    for (; (c = *fmt) != 0; fmt++) {
    800004c8:	0014c983          	lbu	s3,1(s1)
    800004cc:	0485                	addi	s1,s1,1
    800004ce:	fa099ae3          	bnez	s3,80000482 <printf+0x6c>
    800004d2:	6a46                	ld	s4,80(sp)
    800004d4:	6aa6                	ld	s5,72(sp)
    800004d6:	7be2                	ld	s7,56(sp)
    800004d8:	7c42                	ld	s8,48(sp)
    800004da:	7ca2                	ld	s9,40(sp)
            break;
        }
    }
    va_end(ap);
    release(&pr_lock);
    800004dc:	0000a517          	auipc	a0,0xa
    800004e0:	b2450513          	addi	a0,a0,-1244 # 8000a000 <pr_lock>
    800004e4:	00000097          	auipc	ra,0x0
    800004e8:	1d8080e7          	jalr	472(ra) # 800006bc <release>
    800004ec:	70e6                	ld	ra,120(sp)
    800004ee:	7446                	ld	s0,112(sp)
    800004f0:	74a6                	ld	s1,104(sp)
    800004f2:	7906                	ld	s2,96(sp)
    800004f4:	69e6                	ld	s3,88(sp)
    800004f6:	6129                	addi	sp,sp,192
    800004f8:	8082                	ret
            printint(va_arg(ap, unsigned int), 16, 0);
    800004fa:	f8843783          	ld	a5,-120(s0)
    800004fe:	4601                	li	a2,0
    80000500:	45c1                	li	a1,16
    80000502:	0007e503          	lwu	a0,0(a5)
    80000506:	07a1                	addi	a5,a5,8
    80000508:	f8f43423          	sd	a5,-120(s0)
    8000050c:	00000097          	auipc	ra,0x0
    80000510:	e5a080e7          	jalr	-422(ra) # 80000366 <printint>
            break;
    80000514:	bf4d                	j	800004c6 <printf+0xb0>
            printint(va_arg(ap, unsigned int), 10, 0);
    80000516:	f8843783          	ld	a5,-120(s0)
    8000051a:	4601                	li	a2,0
    8000051c:	45a9                	li	a1,10
    8000051e:	0007e503          	lwu	a0,0(a5)
    80000522:	07a1                	addi	a5,a5,8
    80000524:	f8f43423          	sd	a5,-120(s0)
    80000528:	00000097          	auipc	ra,0x0
    8000052c:	e3e080e7          	jalr	-450(ra) # 80000366 <printint>
            break;
    80000530:	bf59                	j	800004c6 <printf+0xb0>
            s = va_arg(ap, const char *);
    80000532:	f8843783          	ld	a5,-120(s0)
    80000536:	0007b983          	ld	s3,0(a5)
    8000053a:	07a1                	addi	a5,a5,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
            if (s == 0) {
    80000540:	12098d63          	beqz	s3,8000067a <printf+0x264>
            while (*s) {
    80000544:	0009c783          	lbu	a5,0(s3)
    80000548:	dfbd                	beqz	a5,800004c6 <printf+0xb0>
    if (c == '\n') {
    8000054a:	4aa9                	li	s5,10
    8000054c:	a809                	j	8000055e <printf+0x148>
    my_put(c);
    8000054e:	8552                	mv	a0,s4
    80000550:	00000097          	auipc	ra,0x0
    80000554:	d64080e7          	jalr	-668(ra) # 800002b4 <my_put>
            while (*s) {
    80000558:	0009c783          	lbu	a5,0(s3)
    8000055c:	d7ad                	beqz	a5,800004c6 <printf+0xb0>
                putc(*s++);
    8000055e:	0985                	addi	s3,s3,1
    80000560:	00078a1b          	sext.w	s4,a5
    if (c == '\n') {
    80000564:	ff5795e3          	bne	a5,s5,8000054e <printf+0x138>
        my_put('\r');
    80000568:	4535                	li	a0,13
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	d4a080e7          	jalr	-694(ra) # 800002b4 <my_put>
    80000572:	bff1                	j	8000054e <printf+0x138>
            printptr((uint64)va_arg(ap, void *));
    80000574:	f8843783          	ld	a5,-120(s0)
    my_put(c);
    80000578:	03000513          	li	a0,48
    8000057c:	e0da                	sd	s6,64(sp)
            printptr((uint64)va_arg(ap, void *));
    8000057e:	00878713          	addi	a4,a5,8
    80000582:	0007bb03          	ld	s6,0(a5)
    80000586:	f06a                	sd	s10,32(sp)
    80000588:	f8e43423          	sd	a4,-120(s0)
    8000058c:	ec6e                	sd	s11,24(sp)
    my_put(c);
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	d26080e7          	jalr	-730(ra) # 800002b4 <my_put>
    80000596:	07800513          	li	a0,120
    8000059a:	00000097          	auipc	ra,0x0
    8000059e:	d1a080e7          	jalr	-742(ra) # 800002b4 <my_put>
    800005a2:	03c00d13          	li	s10,60
    800005a6:	00001a97          	auipc	s5,0x1
    800005aa:	9c2a8a93          	addi	s5,s5,-1598 # 80000f68 <digits>
    if (c == '\n') {
    800005ae:	4a29                	li	s4,10
    for (int i = 0; i < 16; i++) {
    800005b0:	59f1                	li	s3,-4
    800005b2:	a809                	j	800005c4 <printf+0x1ae>
    my_put(c);
    800005b4:	856e                	mv	a0,s11
    for (int i = 0; i < 16; i++) {
    800005b6:	3d71                	addiw	s10,s10,-4
    my_put(c);
    800005b8:	00000097          	auipc	ra,0x0
    800005bc:	cfc080e7          	jalr	-772(ra) # 800002b4 <my_put>
    for (int i = 0; i < 16; i++) {
    800005c0:	033d0763          	beq	s10,s3,800005ee <printf+0x1d8>
        putc(digits[(x >> shift) & 0xf]);
    800005c4:	01ab57b3          	srl	a5,s6,s10
    800005c8:	8bbd                	andi	a5,a5,15
    800005ca:	97d6                	add	a5,a5,s5
    800005cc:	0007cd83          	lbu	s11,0(a5)
    if (c == '\n') {
    800005d0:	ff4d92e3          	bne	s11,s4,800005b4 <printf+0x19e>
        my_put('\r');
    800005d4:	4535                	li	a0,13
    800005d6:	00000097          	auipc	ra,0x0
    800005da:	cde080e7          	jalr	-802(ra) # 800002b4 <my_put>
    my_put(c);
    800005de:	856e                	mv	a0,s11
    for (int i = 0; i < 16; i++) {
    800005e0:	3d71                	addiw	s10,s10,-4
    my_put(c);
    800005e2:	00000097          	auipc	ra,0x0
    800005e6:	cd2080e7          	jalr	-814(ra) # 800002b4 <my_put>
    for (int i = 0; i < 16; i++) {
    800005ea:	fd3d1de3          	bne	s10,s3,800005c4 <printf+0x1ae>
    800005ee:	6b06                	ld	s6,64(sp)
    800005f0:	7d02                	ld	s10,32(sp)
    800005f2:	6de2                	ld	s11,24(sp)
    800005f4:	bdc9                	j	800004c6 <printf+0xb0>
            printint(va_arg(ap, int), 10, 1);
    800005f6:	f8843783          	ld	a5,-120(s0)
    800005fa:	4605                	li	a2,1
    800005fc:	45a9                	li	a1,10
    800005fe:	4388                	lw	a0,0(a5)
    80000600:	07a1                	addi	a5,a5,8
    80000602:	f8f43423          	sd	a5,-120(s0)
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	d60080e7          	jalr	-672(ra) # 80000366 <printint>
            break;
    8000060e:	bd65                	j	800004c6 <printf+0xb0>
            putc(va_arg(ap, int));
    80000610:	f8843783          	ld	a5,-120(s0)
    if (c == '\n') {
    80000614:	4729                	li	a4,10
            putc(va_arg(ap, int));
    80000616:	0007a983          	lw	s3,0(a5)
    8000061a:	07a1                	addi	a5,a5,8
    8000061c:	f8f43423          	sd	a5,-120(s0)
    if (c == '\n') {
    80000620:	e8e99ee3          	bne	s3,a4,800004bc <printf+0xa6>
        my_put('\r');
    80000624:	4535                	li	a0,13
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	c8e080e7          	jalr	-882(ra) # 800002b4 <my_put>
    8000062e:	b579                	j	800004bc <printf+0xa6>
    if (c == '\n') {
    80000630:	01998f63          	beq	s3,s9,8000064e <printf+0x238>
    my_put(c);
    80000634:	854e                	mv	a0,s3
    80000636:	00000097          	auipc	ra,0x0
    8000063a:	c7e080e7          	jalr	-898(ra) # 800002b4 <my_put>
            continue;
    8000063e:	b569                	j	800004c8 <printf+0xb2>
    my_put(c);
    80000640:	02500513          	li	a0,37
    80000644:	00000097          	auipc	ra,0x0
    80000648:	c70080e7          	jalr	-912(ra) # 800002b4 <my_put>
}
    8000064c:	bdad                	j	800004c6 <printf+0xb0>
        my_put('\r');
    8000064e:	4535                	li	a0,13
    80000650:	00000097          	auipc	ra,0x0
    80000654:	c64080e7          	jalr	-924(ra) # 800002b4 <my_put>
    80000658:	bff1                	j	80000634 <printf+0x21e>
        initlock(&pr_lock, "printf");
    8000065a:	00001597          	auipc	a1,0x1
    8000065e:	8a658593          	addi	a1,a1,-1882 # 80000f00 <clock_intr+0x2b0>
    80000662:	0000a517          	auipc	a0,0xa
    80000666:	99e50513          	addi	a0,a0,-1634 # 8000a000 <pr_lock>
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	01e080e7          	jalr	30(ra) # 80000688 <initlock>
        pr_lock_inited = 1;
    80000672:	4785                	li	a5,1
    80000674:	00f92023          	sw	a5,0(s2)
    80000678:	bbc1                	j	80000448 <printf+0x32>
    8000067a:	02800793          	li	a5,40
                s = "(null)";
    8000067e:	00001997          	auipc	s3,0x1
    80000682:	87a98993          	addi	s3,s3,-1926 # 80000ef8 <clock_intr+0x2a8>
    80000686:	b5d1                	j	8000054a <printf+0x134>

0000000080000688 <initlock>:
#include "riscv.h"
#include "spinlock.h"

void initlock(struct spinlock *lk, const char *name) {
    80000688:	1141                	addi	sp,sp,-16
    8000068a:	e422                	sd	s0,8(sp)
    8000068c:	0800                	addi	s0,sp,16
    lk->locked = 0;
    lk->name = name;
}
    8000068e:	6422                	ld	s0,8(sp)
    lk->locked = 0;
    80000690:	00052023          	sw	zero,0(a0)
    lk->name = name;
    80000694:	e50c                	sd	a1,8(a0)
}
    80000696:	0141                	addi	sp,sp,16
    80000698:	8082                	ret

000000008000069a <acquire>:
/*
acquire — 拿锁
先关中断，然后原子地抢锁
抢不到就在原地自旋，直到拿到为止
*/
void acquire(struct spinlock *lk) {
    8000069a:	1141                	addi	sp,sp,-16
    8000069c:	e422                	sd	s0,8(sp)
    8000069e:	0800                	addi	s0,sp,16
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
    800006a0:	4789                	li	a5,2
    800006a2:	1007b073          	csrc	sstatus,a5
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0) {}
    800006a6:	4705                	li	a4,1
    800006a8:	87ba                	mv	a5,a4
    800006aa:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    800006ae:	2781                	sext.w	a5,a5
    800006b0:	ffe5                	bnez	a5,800006a8 <acquire+0xe>
    __sync_synchronize(); // 让其他核能看到 lock 的状态
    800006b2:	0330000f          	fence	rw,rw
}
    800006b6:	6422                	ld	s0,8(sp)
    800006b8:	0141                	addi	sp,sp,16
    800006ba:	8082                	ret

00000000800006bc <release>:

/*
release — 放锁
先保证之前的所有内存操作对别的核可见，然后原子放锁，最后开中断
*/
void release(struct spinlock *lk) {
    800006bc:	1141                	addi	sp,sp,-16
    800006be:	e422                	sd	s0,8(sp)
    800006c0:	0800                	addi	s0,sp,16
    __sync_synchronize();
    800006c2:	0330000f          	fence	rw,rw
    __sync_lock_release(&lk->locked);
    800006c6:	0310000f          	fence	rw,w
    800006ca:	00052023          	sw	zero,0(a0)
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
    800006ce:	4789                	li	a5,2
    800006d0:	1007a073          	csrs	sstatus,a5
    intr_on();
}
    800006d4:	6422                	ld	s0,8(sp)
    800006d6:	0141                	addi	sp,sp,16
    800006d8:	8082                	ret

00000000800006da <kinit>:
} kmem;

extern char end; // kernel.ld 定义，内核 BSS 之后的首地址

// 初始化
void kinit() {
    800006da:	7139                	addi	sp,sp,-64
    800006dc:	f822                	sd	s0,48(sp)
    800006de:	f426                	sd	s1,40(sp)
    800006e0:	f04a                	sd	s2,32(sp)
    800006e2:	fc06                	sd	ra,56(sp)
    800006e4:	0080                	addi	s0,sp,64
    initlock(&kmem.lock, "kmem");
    800006e6:	00001597          	auipc	a1,0x1
    800006ea:	82258593          	addi	a1,a1,-2014 # 80000f08 <clock_intr+0x2b8>
    800006ee:	0000a517          	auipc	a0,0xa
    800006f2:	92250513          	addi	a0,a0,-1758 # 8000a010 <kmem>
    800006f6:	00000097          	auipc	ra,0x0
    800006fa:	f92080e7          	jalr	-110(ra) # 80000688 <initlock>

    char *p = (char *)PGROUNDUP((uint64)&end);
    800006fe:	77fd                	lui	a5,0xfffff
    80000700:	0000b497          	auipc	s1,0xb
    80000704:	1e748493          	addi	s1,s1,487 # 8000b8e7 <ticks+0xfe7>
    80000708:	8cfd                	and	s1,s1,a5
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    8000070a:	4945                	li	s2,17
    8000070c:	6785                	lui	a5,0x1
    8000070e:	97a6                	add	a5,a5,s1
    80000710:	096e                	slli	s2,s2,0x1b
    80000712:	02f96c63          	bltu	s2,a5,8000074a <kinit+0x70>
    80000716:	ec4e                	sd	s3,24(sp)
    80000718:	e852                	sd	s4,16(sp)
    8000071a:	e456                	sd	s5,8(sp)
    8000071c:	89a6                	mv	s3,s1
    8000071e:	6a05                	lui	s4,0x1
    if (((uint64)pa % PGSIZE) != 0|| (char *)pa < (char *)PGROUNDUP((uint64)&end)|| (uint64)pa >= PHYSTOP) {
        return;
    }

    struct run *r = (struct run *)pa;
    acquire(&kmem.lock);
    80000720:	0000aa97          	auipc	s5,0xa
    80000724:	8f0a8a93          	addi	s5,s5,-1808 # 8000a010 <kmem>
    if (((uint64)pa % PGSIZE) != 0|| (char *)pa < (char *)PGROUNDUP((uint64)&end)|| (uint64)pa >= PHYSTOP) {
    80000728:	0134eb63          	bltu	s1,s3,8000073e <kinit+0x64>
    acquire(&kmem.lock);
    8000072c:	0000a517          	auipc	a0,0xa
    80000730:	8e450513          	addi	a0,a0,-1820 # 8000a010 <kmem>
    if (((uint64)pa % PGSIZE) != 0|| (char *)pa < (char *)PGROUNDUP((uint64)&end)|| (uint64)pa >= PHYSTOP) {
    80000734:	0324e163          	bltu	s1,s2,80000756 <kinit+0x7c>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000738:	94d2                	add	s1,s1,s4
    if (((uint64)pa % PGSIZE) != 0|| (char *)pa < (char *)PGROUNDUP((uint64)&end)|| (uint64)pa >= PHYSTOP) {
    8000073a:	ff34f9e3          	bgeu	s1,s3,8000072c <kinit+0x52>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    8000073e:	94d2                	add	s1,s1,s4
    80000740:	ff2494e3          	bne	s1,s2,80000728 <kinit+0x4e>
    80000744:	69e2                	ld	s3,24(sp)
    80000746:	6a42                	ld	s4,16(sp)
    80000748:	6aa2                	ld	s5,8(sp)
}
    8000074a:	70e2                	ld	ra,56(sp)
    8000074c:	7442                	ld	s0,48(sp)
    8000074e:	74a2                	ld	s1,40(sp)
    80000750:	7902                	ld	s2,32(sp)
    80000752:	6121                	addi	sp,sp,64
    80000754:	8082                	ret
    acquire(&kmem.lock);
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	f44080e7          	jalr	-188(ra) # 8000069a <acquire>
    r->next = kmem.freelist;
    8000075e:	010ab783          	ld	a5,16(s5)
    kmem.freelist = r;
    release(&kmem.lock);
    80000762:	0000a517          	auipc	a0,0xa
    80000766:	8ae50513          	addi	a0,a0,-1874 # 8000a010 <kmem>
    r->next = kmem.freelist;
    8000076a:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    8000076c:	009ab823          	sd	s1,16(s5)
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000770:	94d2                	add	s1,s1,s4
    release(&kmem.lock);
    80000772:	00000097          	auipc	ra,0x0
    80000776:	f4a080e7          	jalr	-182(ra) # 800006bc <release>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    8000077a:	fb2497e3          	bne	s1,s2,80000728 <kinit+0x4e>
    8000077e:	b7d9                	j	80000744 <kinit+0x6a>

0000000080000780 <kalloc>:
void *kalloc() {
    80000780:	1101                	addi	sp,sp,-32
    80000782:	e822                	sd	s0,16(sp)
    80000784:	e426                	sd	s1,8(sp)
    80000786:	e04a                	sd	s2,0(sp)
    80000788:	ec06                	sd	ra,24(sp)
    8000078a:	1000                	addi	s0,sp,32
    acquire(&kmem.lock);
    8000078c:	0000a917          	auipc	s2,0xa
    80000790:	88490913          	addi	s2,s2,-1916 # 8000a010 <kmem>
    80000794:	854a                	mv	a0,s2
    80000796:	00000097          	auipc	ra,0x0
    8000079a:	f04080e7          	jalr	-252(ra) # 8000069a <acquire>
    struct run *r = kmem.freelist;
    8000079e:	01093483          	ld	s1,16(s2)
    if (r) {
    800007a2:	c885                	beqz	s1,800007d2 <kalloc+0x52>
        kmem.freelist = r->next;
    800007a4:	609c                	ld	a5,0(s1)
    release(&kmem.lock);
    800007a6:	854a                	mv	a0,s2
        kmem.freelist = r->next;
    800007a8:	00f93823          	sd	a5,16(s2)
    release(&kmem.lock);
    800007ac:	00000097          	auipc	ra,0x0
    800007b0:	f10080e7          	jalr	-240(ra) # 800006bc <release>
        for (int i = 0; i < PGSIZE; i++) {
    800007b4:	6705                	lui	a4,0x1
    800007b6:	87a6                	mv	a5,s1
    800007b8:	9726                	add	a4,a4,s1
            v[i] = 0;
    800007ba:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
        for (int i = 0; i < PGSIZE; i++) {
    800007be:	0785                	addi	a5,a5,1
    800007c0:	fee79de3          	bne	a5,a4,800007ba <kalloc+0x3a>
}
    800007c4:	60e2                	ld	ra,24(sp)
    800007c6:	6442                	ld	s0,16(sp)
    800007c8:	6902                	ld	s2,0(sp)
    800007ca:	8526                	mv	a0,s1
    800007cc:	64a2                	ld	s1,8(sp)
    800007ce:	6105                	addi	sp,sp,32
    800007d0:	8082                	ret
    release(&kmem.lock);
    800007d2:	854a                	mv	a0,s2
    800007d4:	00000097          	auipc	ra,0x0
    800007d8:	ee8080e7          	jalr	-280(ra) # 800006bc <release>
}
    800007dc:	60e2                	ld	ra,24(sp)
    800007de:	6442                	ld	s0,16(sp)
    800007e0:	6902                	ld	s2,0(sp)
    800007e2:	8526                	mv	a0,s1
    800007e4:	64a2                	ld	s1,8(sp)
    800007e6:	6105                	addi	sp,sp,32
    800007e8:	8082                	ret

00000000800007ea <kfree>:
    if (((uint64)pa % PGSIZE) != 0|| (char *)pa < (char *)PGROUNDUP((uint64)&end)|| (uint64)pa >= PHYSTOP) {
    800007ea:	03451793          	slli	a5,a0,0x34
    800007ee:	e3ad                	bnez	a5,80000850 <kfree+0x66>
void kfree(void *pa) {
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	e822                	sd	s0,16(sp)
    800007f4:	e426                	sd	s1,8(sp)
    800007f6:	ec06                	sd	ra,24(sp)
    800007f8:	1000                	addi	s0,sp,32
    if (((uint64)pa % PGSIZE) != 0|| (char *)pa < (char *)PGROUNDUP((uint64)&end)|| (uint64)pa >= PHYSTOP) {
    800007fa:	0000b797          	auipc	a5,0xb
    800007fe:	0ed78793          	addi	a5,a5,237 # 8000b8e7 <ticks+0xfe7>
    80000802:	777d                	lui	a4,0xfffff
    80000804:	8ff9                	and	a5,a5,a4
    80000806:	84aa                	mv	s1,a0
    80000808:	02f56f63          	bltu	a0,a5,80000846 <kfree+0x5c>
    8000080c:	47c5                	li	a5,17
    8000080e:	07ee                	slli	a5,a5,0x1b
    80000810:	02f57b63          	bgeu	a0,a5,80000846 <kfree+0x5c>
    80000814:	e04a                	sd	s2,0(sp)
    acquire(&kmem.lock);
    80000816:	00009917          	auipc	s2,0x9
    8000081a:	7fa90913          	addi	s2,s2,2042 # 8000a010 <kmem>
    8000081e:	854a                	mv	a0,s2
    80000820:	00000097          	auipc	ra,0x0
    80000824:	e7a080e7          	jalr	-390(ra) # 8000069a <acquire>
    r->next = kmem.freelist;
    80000828:	01093783          	ld	a5,16(s2)
}
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	60e2                	ld	ra,24(sp)
    r->next = kmem.freelist;
    80000830:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000832:	00993823          	sd	s1,16(s2)
    release(&kmem.lock);
    80000836:	854a                	mv	a0,s2
}
    80000838:	64a2                	ld	s1,8(sp)
    release(&kmem.lock);
    8000083a:	6902                	ld	s2,0(sp)
}
    8000083c:	6105                	addi	sp,sp,32
    release(&kmem.lock);
    8000083e:	00000317          	auipc	t1,0x0
    80000842:	e7e30067          	jr	-386(t1) # 800006bc <release>
}
    80000846:	60e2                	ld	ra,24(sp)
    80000848:	6442                	ld	s0,16(sp)
    8000084a:	64a2                	ld	s1,8(sp)
    8000084c:	6105                	addi	sp,sp,32
    8000084e:	8082                	ret
    80000850:	8082                	ret

0000000080000852 <kvmmap>:
    }
    return &pgdir[PX(va, 0)];
}

// 在 pgdir 中对等映射 va→pa，覆盖 sz 字节，权限 perm
static void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
    80000852:	711d                	addi	sp,sp,-96
    80000854:	e8a2                	sd	s0,80(sp)
    80000856:	e0ca                	sd	s2,64(sp)
    80000858:	fc4e                	sd	s3,56(sp)
    8000085a:	f852                	sd	s4,48(sp)
    8000085c:	f456                	sd	s5,40(sp)
    8000085e:	f05a                	sd	s6,32(sp)
    80000860:	e862                	sd	s8,16(sp)
    80000862:	e466                	sd	s9,8(sp)
    80000864:	ec86                	sd	ra,88(sp)
    80000866:	e4a6                	sd	s1,72(sp)
    80000868:	ec5e                	sd	s7,24(sp)
    8000086a:	e06a                	sd	s10,0(sp)
    8000086c:	1080                	addi	s0,sp,96
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    8000086e:	8c2e                	mv	s8,a1
static void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
    80000870:	8a2a                	mv	s4,a0
    80000872:	8aba                	mv	s5,a4
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    80000874:	00d58933          	add	s2,a1,a3
    80000878:	40b609b3          	sub	s3,a2,a1
    8000087c:	4c85                	li	s9,1
    8000087e:	6b05                	lui	s6,0x1
    80000880:	013c0bb3          	add	s7,s8,s3
    for (int level = 2; level >= 1; level--) {
    80000884:	8552                	mv	a0,s4
    80000886:	4d09                	li	s10,2
    80000888:	4789                	li	a5,2
        uint64 *pte = &pgdir[PX(va, level)];
    8000088a:	0037949b          	slliw	s1,a5,0x3
    8000088e:	9cbd                	addw	s1,s1,a5
    80000890:	24b1                	addiw	s1,s1,12
    80000892:	009c54b3          	srl	s1,s8,s1
    80000896:	1ff4f493          	andi	s1,s1,511
    8000089a:	048e                	slli	s1,s1,0x3
    8000089c:	94aa                	add	s1,s1,a0
        if (*pte & PTE_V) {
    8000089e:	6088                	ld	a0,0(s1)
    800008a0:	00157793          	andi	a5,a0,1
            pgdir = (uint64 *)PTE2PA(*pte);
    800008a4:	8129                	srli	a0,a0,0xa
    800008a6:	0532                	slli	a0,a0,0xc
        if (*pte & PTE_V) {
    800008a8:	ef81                	bnez	a5,800008c0 <kvmmap+0x6e>
            pgdir = (uint64 *)kalloc();
    800008aa:	00000097          	auipc	ra,0x0
    800008ae:	ed6080e7          	jalr	-298(ra) # 80000780 <kalloc>
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
    800008b2:	00c55793          	srli	a5,a0,0xc
    800008b6:	07aa                	slli	a5,a5,0xa
    800008b8:	0017e793          	ori	a5,a5,1
            if (pgdir == 0) {
    800008bc:	c915                	beqz	a0,800008f0 <kvmmap+0x9e>
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
    800008be:	e09c                	sd	a5,0(s1)
    for (int level = 2; level >= 1; level--) {
    800008c0:	4785                	li	a5,1
    800008c2:	019d0463          	beq	s10,s9,800008ca <kvmmap+0x78>
    800008c6:	4d05                	li	s10,1
    800008c8:	b7c9                	j	8000088a <kvmmap+0x38>
    return &pgdir[PX(va, 0)];
    800008ca:	00cc5793          	srli	a5,s8,0xc
    800008ce:	1ff7f793          	andi	a5,a5,511
    800008d2:	078e                	slli	a5,a5,0x3
    800008d4:	953e                	add	a0,a0,a5
        uint64 *pte = walk(pgdir, a, 1);
        if (pte == 0) {
    800008d6:	cd09                	beqz	a0,800008f0 <kvmmap+0x9e>
            return;
        }
        *pte = PA2PTE(pa) | perm | PTE_V;
    800008d8:	00cbdb93          	srli	s7,s7,0xc
    800008dc:	0baa                	slli	s7,s7,0xa
    800008de:	015bebb3          	or	s7,s7,s5
    800008e2:	001beb93          	ori	s7,s7,1
    800008e6:	01753023          	sd	s7,0(a0)
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    800008ea:	9c5a                	add	s8,s8,s6
    800008ec:	f92c6ae3          	bltu	s8,s2,80000880 <kvmmap+0x2e>
    }
}
    800008f0:	60e6                	ld	ra,88(sp)
    800008f2:	6446                	ld	s0,80(sp)
    800008f4:	64a6                	ld	s1,72(sp)
    800008f6:	6906                	ld	s2,64(sp)
    800008f8:	79e2                	ld	s3,56(sp)
    800008fa:	7a42                	ld	s4,48(sp)
    800008fc:	7aa2                	ld	s5,40(sp)
    800008fe:	7b02                	ld	s6,32(sp)
    80000900:	6be2                	ld	s7,24(sp)
    80000902:	6c42                	ld	s8,16(sp)
    80000904:	6ca2                	ld	s9,8(sp)
    80000906:	6d02                	ld	s10,0(sp)
    80000908:	6125                	addi	sp,sp,96
    8000090a:	8082                	ret

000000008000090c <kvminit>:

// 创建内核页表 — 映射 UART/PLIC/CLINT MMIO 和全部 RAM（对等映射）
void kvminit() {
    8000090c:	1101                	addi	sp,sp,-32
    8000090e:	e822                	sd	s0,16(sp)
    80000910:	e426                	sd	s1,8(sp)
    80000912:	ec06                	sd	ra,24(sp)
    80000914:	1000                	addi	s0,sp,32
    kernel_pgdir = (uint64 *)kalloc();
    80000916:	00000097          	auipc	ra,0x0
    8000091a:	e6a080e7          	jalr	-406(ra) # 80000780 <kalloc>
    8000091e:	0000a497          	auipc	s1,0xa
    80000922:	fda48493          	addi	s1,s1,-38 # 8000a8f8 <kernel_pgdir>
    80000926:	e088                	sd	a0,0(s1)
    if (kernel_pgdir == 0) {
    80000928:	c135                	beqz	a0,8000098c <kvminit+0x80>
        return;
    }

    kvmmap(kernel_pgdir, UART0, UART0, PGSIZE, PTE_KERN_RW);
    8000092a:	4719                	li	a4,6
    8000092c:	6685                	lui	a3,0x1
    8000092e:	10000637          	lui	a2,0x10000
    80000932:	100005b7          	lui	a1,0x10000
    80000936:	00000097          	auipc	ra,0x0
    8000093a:	f1c080e7          	jalr	-228(ra) # 80000852 <kvmmap>
    kvmmap(kernel_pgdir, PLIC, PLIC, 0x400000, PTE_KERN_RW);     // PLIC MMIO 区域
    8000093e:	6088                	ld	a0,0(s1)
    80000940:	4719                	li	a4,6
    80000942:	004006b7          	lui	a3,0x400
    80000946:	0c000637          	lui	a2,0xc000
    8000094a:	0c0005b7          	lui	a1,0xc000
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	f04080e7          	jalr	-252(ra) # 80000852 <kvmmap>
    kvmmap(kernel_pgdir, CLINT, CLINT, 0x10000, PTE_KERN_RW);    // CLINT MMIO 区域
    80000956:	6088                	ld	a0,0(s1)
    80000958:	4719                	li	a4,6
    8000095a:	66c1                	lui	a3,0x10
    8000095c:	02000637          	lui	a2,0x2000
    80000960:	020005b7          	lui	a1,0x2000
    80000964:	00000097          	auipc	ra,0x0
    80000968:	eee080e7          	jalr	-274(ra) # 80000852 <kvmmap>
    kvmmap(kernel_pgdir, KERNBASE, KERNBASE, PHYSTOP - KERNBASE, PTE_KERN_RWX);
    8000096c:	6088                	ld	a0,0(s1)
    8000096e:	4605                	li	a2,1
    80000970:	067e                	slli	a2,a2,0x1f
    80000972:	4739                	li	a4,14
    80000974:	080006b7          	lui	a3,0x8000
    80000978:	85b2                	mv	a1,a2
    8000097a:	00000097          	auipc	ra,0x0
    8000097e:	ed8080e7          	jalr	-296(ra) # 80000852 <kvmmap>

    kvminit_done = 1;
    80000982:	4785                	li	a5,1
    80000984:	0000a717          	auipc	a4,0xa
    80000988:	f6f72623          	sw	a5,-148(a4) # 8000a8f0 <kvminit_done>
}
    8000098c:	60e2                	ld	ra,24(sp)
    8000098e:	6442                	ld	s0,16(sp)
    80000990:	64a2                	ld	s1,8(sp)
    80000992:	6105                	addi	sp,sp,32
    80000994:	8082                	ret

0000000080000996 <kvminithart>:

// 启用内核页表（每个 hart 调用）
void kvminithart() {
    80000996:	1141                	addi	sp,sp,-16
    80000998:	e422                	sd	s0,8(sp)
    8000099a:	0800                	addi	s0,sp,16
    w_satp(MAKE_SATP(kernel_pgdir));
    8000099c:	0000a797          	auipc	a5,0xa
    800009a0:	f5c7b783          	ld	a5,-164(a5) # 8000a8f8 <kernel_pgdir>
    800009a4:	577d                	li	a4,-1
    800009a6:	177e                	slli	a4,a4,0x3f
    800009a8:	83b1                	srli	a5,a5,0xc
    800009aa:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    800009ac:	18079073          	csrw	satp,a5
    return x;
}

// 刷新 TLB
static inline void sfence_vma() {
    asm volatile("sfence.vma");
    800009b0:	12000073          	sfence.vma
    sfence_vma();
}
    800009b4:	6422                	ld	s0,8(sp)
    800009b6:	0141                	addi	sp,sp,16
    800009b8:	8082                	ret
    800009ba:	0000                	unimp
    800009bc:	0000                	unimp
	...

00000000800009c0 <kernel_vector>:
    800009c0:	14011173          	csrrw	sp,sscratch,sp
    800009c4:	e006                	sd	ra,0(sp)
    800009c6:	e80e                	sd	gp,16(sp)
    800009c8:	ec12                	sd	tp,24(sp)
    800009ca:	f016                	sd	t0,32(sp)
    800009cc:	f41a                	sd	t1,40(sp)
    800009ce:	f81e                	sd	t2,48(sp)
    800009d0:	fc22                	sd	s0,56(sp)
    800009d2:	e0a6                	sd	s1,64(sp)
    800009d4:	e4aa                	sd	a0,72(sp)
    800009d6:	e8ae                	sd	a1,80(sp)
    800009d8:	ecb2                	sd	a2,88(sp)
    800009da:	f0b6                	sd	a3,96(sp)
    800009dc:	f4ba                	sd	a4,104(sp)
    800009de:	f8be                	sd	a5,112(sp)
    800009e0:	fcc2                	sd	a6,120(sp)
    800009e2:	e146                	sd	a7,128(sp)
    800009e4:	e54a                	sd	s2,136(sp)
    800009e6:	e94e                	sd	s3,144(sp)
    800009e8:	ed52                	sd	s4,152(sp)
    800009ea:	f156                	sd	s5,160(sp)
    800009ec:	f55a                	sd	s6,168(sp)
    800009ee:	f95e                	sd	s7,176(sp)
    800009f0:	fd62                	sd	s8,184(sp)
    800009f2:	e1e6                	sd	s9,192(sp)
    800009f4:	e5ea                	sd	s10,200(sp)
    800009f6:	e9ee                	sd	s11,208(sp)
    800009f8:	edf2                	sd	t3,216(sp)
    800009fa:	f1f6                	sd	t4,224(sp)
    800009fc:	f5fa                	sd	t5,232(sp)
    800009fe:	f9fe                	sd	t6,240(sp)
    80000a00:	140022f3          	csrr	t0,sscratch
    80000a04:	e416                	sd	t0,8(sp)
    80000a06:	141022f3          	csrr	t0,sepc
    80000a0a:	fd96                	sd	t0,248(sp)
    80000a0c:	100022f3          	csrr	t0,sstatus
    80000a10:	e216                	sd	t0,256(sp)
    80000a12:	142022f3          	csrr	t0,scause
    80000a16:	e616                	sd	t0,264(sp)
    80000a18:	143022f3          	csrr	t0,stval
    80000a1c:	ea16                	sd	t0,272(sp)
    80000a1e:	14011073          	csrw	sscratch,sp
    80000a22:	6122                	ld	sp,8(sp)
    80000a24:	14002573          	csrr	a0,sscratch
    80000a28:	0c4000ef          	jal	80000aec <trap_kernel_handler>

0000000080000a2c <trap_return>:
    80000a2c:	14011173          	csrrw	sp,sscratch,sp
    80000a30:	72ee                	ld	t0,248(sp)
    80000a32:	14129073          	csrw	sepc,t0
    80000a36:	6292                	ld	t0,256(sp)
    80000a38:	10029073          	csrw	sstatus,t0
    80000a3c:	6082                	ld	ra,0(sp)
    80000a3e:	61c2                	ld	gp,16(sp)
    80000a40:	6262                	ld	tp,24(sp)
    80000a42:	7282                	ld	t0,32(sp)
    80000a44:	7322                	ld	t1,40(sp)
    80000a46:	73c2                	ld	t2,48(sp)
    80000a48:	7462                	ld	s0,56(sp)
    80000a4a:	6486                	ld	s1,64(sp)
    80000a4c:	6526                	ld	a0,72(sp)
    80000a4e:	65c6                	ld	a1,80(sp)
    80000a50:	6666                	ld	a2,88(sp)
    80000a52:	7686                	ld	a3,96(sp)
    80000a54:	7726                	ld	a4,104(sp)
    80000a56:	77c6                	ld	a5,112(sp)
    80000a58:	7866                	ld	a6,120(sp)
    80000a5a:	688a                	ld	a7,128(sp)
    80000a5c:	692a                	ld	s2,136(sp)
    80000a5e:	69ca                	ld	s3,144(sp)
    80000a60:	6a6a                	ld	s4,152(sp)
    80000a62:	7a8a                	ld	s5,160(sp)
    80000a64:	7b2a                	ld	s6,168(sp)
    80000a66:	7bca                	ld	s7,176(sp)
    80000a68:	7c6a                	ld	s8,184(sp)
    80000a6a:	6c8e                	ld	s9,192(sp)
    80000a6c:	6d2e                	ld	s10,200(sp)
    80000a6e:	6dce                	ld	s11,208(sp)
    80000a70:	6e6e                	ld	t3,216(sp)
    80000a72:	7e8e                	ld	t4,224(sp)
    80000a74:	7f2e                	ld	t5,232(sp)
    80000a76:	7fce                	ld	t6,240(sp)
    80000a78:	828a                	mv	t0,sp
    80000a7a:	6122                	ld	sp,8(sp)
    80000a7c:	14029073          	csrw	sscratch,t0
    80000a80:	10200073          	sret
	...

0000000080000a8e <trap_kernel_init>:
struct trapframe trapframe[NCPU];

extern void kernel_vector();

// hart 0 初始化陷阱系统: 设置 stvec, 初始化 PLIC
void trap_kernel_init() {
    80000a8e:	1141                	addi	sp,sp,-16
    80000a90:	e422                	sd	s0,8(sp)
    80000a92:	0800                	addi	s0,sp,16
    plic_init();
}
    80000a94:	6422                	ld	s0,8(sp)
    80000a96:	0141                	addi	sp,sp,16
    plic_init();
    80000a98:	00000317          	auipc	t1,0x0
    80000a9c:	0c630067          	jr	198(t1) # 80000b5e <plic_init>

0000000080000aa0 <trap_kernel_inithart>:

// 每个 hart 设置自己的 trapframe 并启用中断
void trap_kernel_inithart() {
    80000aa0:	1141                	addi	sp,sp,-16
    80000aa2:	e022                	sd	s0,0(sp)
    80000aa4:	e406                	sd	ra,8(sp)
    80000aa6:	0800                	addi	s0,sp,16
    asm volatile("mv %0, tp" : "=r"(x));
    80000aa8:	8792                	mv	a5,tp
    int hartid = r_tp();

    // 设置 stvec 指向 S-mode 陷阱入口
    asm volatile("csrw stvec, %0" : : "r"(kernel_vector));
    80000aaa:	00000717          	auipc	a4,0x0
    80000aae:	f1670713          	addi	a4,a4,-234 # 800009c0 <kernel_vector>
    80000ab2:	10571073          	csrw	stvec,a4

    // sscratch 存当前 hart 的 trapframe 指针
    asm volatile("csrw sscratch, %0" : : "r"(&trapframe[hartid]));
    80000ab6:	11800713          	li	a4,280
    80000aba:	2781                	sext.w	a5,a5
    80000abc:	02e787b3          	mul	a5,a5,a4
    80000ac0:	00009717          	auipc	a4,0x9
    80000ac4:	56870713          	addi	a4,a4,1384 # 8000a028 <trapframe>
    80000ac8:	97ba                	add	a5,a5,a4
    80000aca:	14079073          	csrw	sscratch,a5

    plic_inithart();
    80000ace:	00000097          	auipc	ra,0x0
    80000ad2:	0a4080e7          	jalr	164(ra) # 80000b72 <plic_inithart>

    // 开 S-mode 中断: sie[1]=software, sie[5]=timer, sie[9]=external
    asm volatile("csrs sie, %0" : : "r"((1UL << 1) | (1UL << 5) | (1UL << 9)));
    80000ad6:	22200793          	li	a5,546
    80000ada:	1047a073          	csrs	sie,a5
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
    80000ade:	4789                	li	a5,2
    80000ae0:	1007a073          	csrs	sstatus,a5

    // 全局开中断 (sstatus[1]=SIE)
    intr_on();
}
    80000ae4:	60a2                	ld	ra,8(sp)
    80000ae6:	6402                	ld	s0,0(sp)
    80000ae8:	0141                	addi	sp,sp,16
    80000aea:	8082                	ret

0000000080000aec <trap_kernel_handler>:
    asm volatile("mv %0, tp" : "=r"(x));
    80000aec:	8712                	mv	a4,tp
    plic_complete(irq);
}

// S-mode 陷阱总入口 (由 kernel_vector 调用)
void trap_kernel_handler() {
    uint64 scause = trapframe[r_tp()].scause;
    80000aee:	11800793          	li	a5,280
    80000af2:	02f70733          	mul	a4,a4,a5
    80000af6:	00009797          	auipc	a5,0x9
    80000afa:	53278793          	addi	a5,a5,1330 # 8000a028 <trapframe>
    80000afe:	97ba                	add	a5,a5,a4
    80000b00:	1087b783          	ld	a5,264(a5)

    if (scause & (1UL << 63)) {
    80000b04:	0007c363          	bltz	a5,80000b0a <trap_kernel_handler+0x1e>
    80000b08:	8082                	ret
        // 中断
        uint64 code = scause & 0xFF;
    80000b0a:	0ff7f793          	zext.b	a5,a5
        switch (code) {
    80000b0e:	4715                	li	a4,5
    80000b10:	00e78863          	beq	a5,a4,80000b20 <trap_kernel_handler+0x34>
    80000b14:	4725                	li	a4,9
    80000b16:	00e78963          	beq	a5,a4,80000b28 <trap_kernel_handler+0x3c>
    80000b1a:	4705                	li	a4,1
    80000b1c:	fee796e3          	bne	a5,a4,80000b08 <trap_kernel_handler+0x1c>
        case 1:   // S-mode software interrupt → 时钟 tick
            clock_intr();
    80000b20:	00000317          	auipc	t1,0x0
    80000b24:	13030067          	jr	304(t1) # 80000c50 <clock_intr>
void trap_kernel_handler() {
    80000b28:	1101                	addi	sp,sp,-32
    80000b2a:	e822                	sd	s0,16(sp)
    80000b2c:	ec06                	sd	ra,24(sp)
    80000b2e:	1000                	addi	s0,sp,32
    int irq = plic_claim();
    80000b30:	00000097          	auipc	ra,0x0
    80000b34:	076080e7          	jalr	118(ra) # 80000ba6 <plic_claim>
    if (irq == 10) {
    80000b38:	47a9                	li	a5,10
    80000b3a:	00f50963          	beq	a0,a5,80000b4c <trap_kernel_handler+0x60>
        default:
            break;
        }
    }
    // 异常暂不处理，Lab-3 只涉及中断
}
    80000b3e:	6442                	ld	s0,16(sp)
    80000b40:	60e2                	ld	ra,24(sp)
    80000b42:	6105                	addi	sp,sp,32
    plic_complete(irq);
    80000b44:	00000317          	auipc	t1,0x0
    80000b48:	07e30067          	jr	126(t1) # 80000bc2 <plic_complete>
    80000b4c:	fea43423          	sd	a0,-24(s0)
        uart_intr();
    80000b50:	fffff097          	auipc	ra,0xfffff
    80000b54:	7ca080e7          	jalr	1994(ra) # 8000031a <uart_intr>
    80000b58:	fe843503          	ld	a0,-24(s0)
    80000b5c:	b7cd                	j	80000b3e <trap_kernel_handler+0x52>

0000000080000b5e <plic_init>:
#define PLIC_CLAIM       0x200004  // 声明/读取中断 (per context)
#define PLIC_COMPLETE    0x200004  // 完成中断 (同 claim)

#define UART0_IRQ 10

void plic_init() {
    80000b5e:	1141                	addi	sp,sp,-16
    80000b60:	e422                	sd	s0,8(sp)
    80000b62:	0800                	addi	s0,sp,16
    volatile uint8 *plic = (volatile uint8 *)PLIC;

    // 设置 UART0 中断优先级
    *(volatile uint32 *)(plic + PLIC_PRIORITY + UART0_IRQ * 4) = 1;
}
    80000b64:	6422                	ld	s0,8(sp)
    *(volatile uint32 *)(plic + PLIC_PRIORITY + UART0_IRQ * 4) = 1;
    80000b66:	0c0007b7          	lui	a5,0xc000
    80000b6a:	4705                	li	a4,1
    80000b6c:	d798                	sw	a4,40(a5)
}
    80000b6e:	0141                	addi	sp,sp,16
    80000b70:	8082                	ret

0000000080000b72 <plic_inithart>:

void plic_inithart() {
    80000b72:	1141                	addi	sp,sp,-16
    80000b74:	e422                	sd	s0,8(sp)
    80000b76:	0800                	addi	s0,sp,16
    80000b78:	8792                	mv	a5,tp
    int hartid = r_tp();
    volatile uint8 *plic = (volatile uint8 *)PLIC;

    // 使能当前 hart 的 UART0 中断
    uint32 en = *(volatile uint32 *)(plic + PLIC_ENABLE + hartid * 0x80);
    80000b7a:	6609                	lui	a2,0x2
    80000b7c:	0077971b          	slliw	a4,a5,0x7
    80000b80:	0c0006b7          	lui	a3,0xc000
    80000b84:	9732                	add	a4,a4,a2
    80000b86:	9736                	add	a4,a4,a3
    80000b88:	4310                	lw	a2,0(a4)
    en |= (1U << UART0_IRQ);
    *(volatile uint32 *)(plic + PLIC_ENABLE + hartid * 0x80) = en;

    // 设置优先级阈值为 0（接收所有优先级的中断）
    *(volatile uint32 *)(plic + PLIC_THRESHOLD + hartid * 0x1000) = 0;
    80000b8a:	00c7979b          	slliw	a5,a5,0xc
    80000b8e:	002005b7          	lui	a1,0x200
}
    80000b92:	6422                	ld	s0,8(sp)
    en |= (1U << UART0_IRQ);
    80000b94:	40066613          	ori	a2,a2,1024
    *(volatile uint32 *)(plic + PLIC_THRESHOLD + hartid * 0x1000) = 0;
    80000b98:	97ae                	add	a5,a5,a1
    *(volatile uint32 *)(plic + PLIC_ENABLE + hartid * 0x80) = en;
    80000b9a:	c310                	sw	a2,0(a4)
    *(volatile uint32 *)(plic + PLIC_THRESHOLD + hartid * 0x1000) = 0;
    80000b9c:	96be                	add	a3,a3,a5
    80000b9e:	0006a023          	sw	zero,0(a3) # c000000 <_entry-0x74000000>
}
    80000ba2:	0141                	addi	sp,sp,16
    80000ba4:	8082                	ret

0000000080000ba6 <plic_claim>:

int plic_claim() {
    80000ba6:	1141                	addi	sp,sp,-16
    80000ba8:	e422                	sd	s0,8(sp)
    80000baa:	0800                	addi	s0,sp,16
    80000bac:	8792                	mv	a5,tp
    int hartid = r_tp();
    volatile uint8 *plic = (volatile uint8 *)PLIC;

    return *(volatile int *)(plic + PLIC_CLAIM + hartid * 0x1000);
    80000bae:	0c200737          	lui	a4,0xc200
}
    80000bb2:	6422                	ld	s0,8(sp)
    return *(volatile int *)(plic + PLIC_CLAIM + hartid * 0x1000);
    80000bb4:	00c7979b          	slliw	a5,a5,0xc
    80000bb8:	0711                	addi	a4,a4,4 # c200004 <_entry-0x73dffffc>
    80000bba:	97ba                	add	a5,a5,a4
    80000bbc:	4388                	lw	a0,0(a5)
}
    80000bbe:	0141                	addi	sp,sp,16
    80000bc0:	8082                	ret

0000000080000bc2 <plic_complete>:

void plic_complete(int irq) {
    80000bc2:	1141                	addi	sp,sp,-16
    80000bc4:	e422                	sd	s0,8(sp)
    80000bc6:	0800                	addi	s0,sp,16
    80000bc8:	8792                	mv	a5,tp
    int hartid = r_tp();
    volatile uint8 *plic = (volatile uint8 *)PLIC;

    *(volatile uint32 *)(plic + PLIC_COMPLETE + hartid * 0x1000) = irq;
    80000bca:	0c200737          	lui	a4,0xc200
}
    80000bce:	6422                	ld	s0,8(sp)
    *(volatile uint32 *)(plic + PLIC_COMPLETE + hartid * 0x1000) = irq;
    80000bd0:	00c7979b          	slliw	a5,a5,0xc
    80000bd4:	0711                	addi	a4,a4,4 # c200004 <_entry-0x73dffffc>
    80000bd6:	97ba                	add	a5,a5,a4
    80000bd8:	2501                	sext.w	a0,a0
    80000bda:	c388                	sw	a0,0(a5)
}
    80000bdc:	0141                	addi	sp,sp,16
    80000bde:	8082                	ret

0000000080000be0 <timer_vector>:
    80000be0:	1101                	addi	sp,sp,-32
    80000be2:	e02a                	sd	a0,0(sp)
    80000be4:	e42e                	sd	a1,8(sp)
    80000be6:	e816                	sd	t0,16(sp)
    80000be8:	ec06                	sd	ra,24(sp)
    80000bea:	c0102573          	rdtime	a0
    80000bee:	009895b7          	lui	a1,0x989
    80000bf2:	6805859b          	addiw	a1,a1,1664 # 989680 <_entry-0x7f676980>
    80000bf6:	952e                	add	a0,a0,a1
    80000bf8:	f14025f3          	csrr	a1,mhartid
    80000bfc:	020042b7          	lui	t0,0x2004
    80000c00:	058e                	slli	a1,a1,0x3
    80000c02:	92ae                	add	t0,t0,a1
    80000c04:	00a2b023          	sd	a0,0(t0) # 2004000 <_entry-0x7dffc000>
    80000c08:	4289                	li	t0,2
    80000c0a:	3442a073          	csrs	mip,t0
    80000c0e:	60e2                	ld	ra,24(sp)
    80000c10:	62c2                	ld	t0,16(sp)
    80000c12:	65a2                	ld	a1,8(sp)
    80000c14:	6502                	ld	a0,0(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	30200073          	mret
    80000c1c:	0000                	unimp
    80000c1e:	0000                	unimp
	...

0000000080000c22 <timer_init>:
volatile uint64 ticks;

#define INTERVAL 10000000UL  // 约 10ms (@1GHz)

// 初始化时钟中断 — 设置第一个 mtimecmp 触发点
void timer_init() {
    80000c22:	1141                	addi	sp,sp,-16
    80000c24:	e422                	sd	s0,8(sp)
    80000c26:	0800                	addi	s0,sp,16
    80000c28:	8792                	mv	a5,tp
    uint64 hartid = r_tp();
    volatile uint64 *mtimecmp = (volatile uint64 *)(CLINT + 0x4000 + 8 * hartid);
    volatile uint64 *mtime    = (volatile uint64 *)(CLINT + 0xBFF8);

    *mtimecmp = *mtime + INTERVAL;
    80000c2a:	0200c6b7          	lui	a3,0x200c
    80000c2e:	ff86b703          	ld	a4,-8(a3) # 200bff8 <_entry-0x7dff4008>
    volatile uint64 *mtimecmp = (volatile uint64 *)(CLINT + 0x4000 + 8 * hartid);
    80000c32:	004015b7          	lui	a1,0x401
    80000c36:	80058593          	addi	a1,a1,-2048 # 400800 <_entry-0x7fbff800>
    *mtimecmp = *mtime + INTERVAL;
    80000c3a:	00989637          	lui	a2,0x989
}
    80000c3e:	6422                	ld	s0,8(sp)
    volatile uint64 *mtimecmp = (volatile uint64 *)(CLINT + 0x4000 + 8 * hartid);
    80000c40:	97ae                	add	a5,a5,a1
    *mtimecmp = *mtime + INTERVAL;
    80000c42:	68060613          	addi	a2,a2,1664 # 989680 <_entry-0x7f676980>
    volatile uint64 *mtimecmp = (volatile uint64 *)(CLINT + 0x4000 + 8 * hartid);
    80000c46:	078e                	slli	a5,a5,0x3
    *mtimecmp = *mtime + INTERVAL;
    80000c48:	9732                	add	a4,a4,a2
    80000c4a:	e398                	sd	a4,0(a5)
}
    80000c4c:	0141                	addi	sp,sp,16
    80000c4e:	8082                	ret

0000000080000c50 <clock_intr>:

// S-mode 时钟中断处理 — 在 trap_kernel_handler 中由 software interrupt 触发
void clock_intr() {
    80000c50:	1141                	addi	sp,sp,-16
    80000c52:	e422                	sd	s0,8(sp)
    80000c54:	0800                	addi	s0,sp,16
    ticks++;
    80000c56:	0000a717          	auipc	a4,0xa
    80000c5a:	caa70713          	addi	a4,a4,-854 # 8000a900 <ticks>
    80000c5e:	631c                	ld	a5,0(a4)
    80000c60:	0785                	addi	a5,a5,1 # c000001 <_entry-0x73ffffff>
    80000c62:	e31c                	sd	a5,0(a4)
    // 清除 S-mode 软件中断
    asm volatile("csrc sip, %0" : : "r"(2UL));
    80000c64:	4789                	li	a5,2
    80000c66:	1447b073          	csrc	sip,a5
}
    80000c6a:	6422                	ld	s0,8(sp)
    80000c6c:	0141                	addi	sp,sp,16
    80000c6e:	8082                	ret
