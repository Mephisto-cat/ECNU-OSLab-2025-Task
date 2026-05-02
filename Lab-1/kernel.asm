
kernel-qemu.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
.section .text
.global _entry

_entry:
    csrr a0, mhartid
    80000000:	f1402573          	csrr	a0,mhartid
    la sp, stacks
    80000004:	00001117          	auipc	sp,0x1
    80000008:	ffc10113          	addi	sp,sp,-4 # 80001000 <stacks>
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
    8000009a:	177d                	addi	a4,a4,-1 # ffffffffffffefff <pr_lock_inited+0xffffffff7fff5fef>
    8000009c:	8ff9                	and	a5,a5,a4
    x |=  (1UL << 11);   // 设 bit11 = S-mode
    8000009e:	6705                	lui	a4,0x1
    800000a0:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a4:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800000a6:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc, %0" : : "r"(x));
    800000aa:	00000797          	auipc	a5,0x0
    800000ae:	02078793          	addi	a5,a5,32 # 800000ca <main>
    800000b2:	34179073          	csrw	mepc,a5
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000b6:	57fd                	li	a5,-1
    800000b8:	83a9                	srli	a5,a5,0xa
    800000ba:	3b079073          	csrw	pmpaddr0,a5
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000be:	47bd                	li	a5,15
    800000c0:	3a079073          	csrw	pmpcfg0,a5
    w_mepc((uint64)main);

    w_pmpaddr0(0x3fffffffffffffull);    // 放行全部物理地址
    w_pmpcfg0(0xf);                     // 可读可写可执行

    asm volatile("mret");
    800000c4:	30200073          	mret

    while (1);
    800000c8:	a001                	j	800000c8 <start+0x40>

00000000800000ca <main>:
#include "printf.h"
#include "riscv.h"
#include "uart.h"

void main(void) {
    800000ca:	1141                	addi	sp,sp,-16
    800000cc:	e022                	sd	s0,0(sp)
    800000ce:	e406                	sd	ra,8(sp)
    800000d0:	0800                	addi	s0,sp,16
    uartinit();
    800000d2:	00000097          	auipc	ra,0x0
    800000d6:	0fe080e7          	jalr	254(ra) # 800001d0 <uartinit>
#include "types.h"

// 读 tp 寄存器 (hartid 从 M-mode 带下来存在这里)
static inline uint64 r_tp(void) {
    uint64 x;
    asm volatile("mv %0, tp" : "=r"(x));
    800000da:	8792                	mv	a5,tp

    if (r_tp() == 0) {
    800000dc:	efd5                	bnez	a5,80000198 <main+0xce>
        printf("=== printf test ===\n");
    800000de:	00000517          	auipc	a0,0x0
    800000e2:	48250513          	addi	a0,a0,1154 # 80000560 <release+0x1e>
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	1d4080e7          	jalr	468(ra) # 800002ba <printf>
        printf("%%d: %d\n", -42);
    800000ee:	fd600593          	li	a1,-42
    800000f2:	00000517          	auipc	a0,0x0
    800000f6:	48650513          	addi	a0,a0,1158 # 80000578 <release+0x36>
    800000fa:	00000097          	auipc	ra,0x0
    800000fe:	1c0080e7          	jalr	448(ra) # 800002ba <printf>
        printf("%%u: %u\n", 12345U);
    80000102:	658d                	lui	a1,0x3
    80000104:	03958593          	addi	a1,a1,57 # 3039 <_entry-0x7fffcfc7>
    80000108:	00000517          	auipc	a0,0x0
    8000010c:	48050513          	addi	a0,a0,1152 # 80000588 <release+0x46>
    80000110:	00000097          	auipc	ra,0x0
    80000114:	1aa080e7          	jalr	426(ra) # 800002ba <printf>
        printf("%%x: %x\n", 0xdeadU);
    80000118:	65b9                	lui	a1,0xe
    8000011a:	ead58593          	addi	a1,a1,-339 # dead <_entry-0x7fff2153>
    8000011e:	00000517          	auipc	a0,0x0
    80000122:	47a50513          	addi	a0,a0,1146 # 80000598 <release+0x56>
    80000126:	00000097          	auipc	ra,0x0
    8000012a:	194080e7          	jalr	404(ra) # 800002ba <printf>
        printf("%%p: %p\n", (void *)0x80000000UL);
    8000012e:	4585                	li	a1,1
    80000130:	05fe                	slli	a1,a1,0x1f
    80000132:	00000517          	auipc	a0,0x0
    80000136:	47650513          	addi	a0,a0,1142 # 800005a8 <release+0x66>
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	180080e7          	jalr	384(ra) # 800002ba <printf>
        printf("%%s: %s\n", "hello");
    80000142:	00000597          	auipc	a1,0x0
    80000146:	47658593          	addi	a1,a1,1142 # 800005b8 <release+0x76>
    8000014a:	00000517          	auipc	a0,0x0
    8000014e:	47650513          	addi	a0,a0,1142 # 800005c0 <release+0x7e>
    80000152:	00000097          	auipc	ra,0x0
    80000156:	168080e7          	jalr	360(ra) # 800002ba <printf>
        printf("%%c: %c\n", 'X');
    8000015a:	05800593          	li	a1,88
    8000015e:	00000517          	auipc	a0,0x0
    80000162:	47250513          	addi	a0,a0,1138 # 800005d0 <release+0x8e>
    80000166:	00000097          	auipc	ra,0x0
    8000016a:	154080e7          	jalr	340(ra) # 800002ba <printf>
        printf("%%%%: 100%%\n");
    8000016e:	00000517          	auipc	a0,0x0
    80000172:	47250513          	addi	a0,a0,1138 # 800005e0 <release+0x9e>
    80000176:	00000097          	auipc	ra,0x0
    8000017a:	144080e7          	jalr	324(ra) # 800002ba <printf>
        printf("=== done ===\n");
    8000017e:	00000517          	auipc	a0,0x0
    80000182:	47250513          	addi	a0,a0,1138 # 800005f0 <release+0xae>
    80000186:	00000097          	auipc	ra,0x0
    8000018a:	134080e7          	jalr	308(ra) # 800002ba <printf>
    return x;
}

// 停机等待中断
static inline void wfi(void) {
    asm volatile("wfi");
    8000018e:	10500073          	wfi
    80000192:	10500073          	wfi
    80000196:	bfe5                	j	8000018e <main+0xc4>
    } else {
        printf("Hello, os!\n");
    80000198:	00000517          	auipc	a0,0x0
    8000019c:	46850513          	addi	a0,a0,1128 # 80000600 <release+0xbe>
    800001a0:	00000097          	auipc	ra,0x0
    800001a4:	11a080e7          	jalr	282(ra) # 800002ba <printf>
    800001a8:	10500073          	wfi
    800001ac:	b7dd                	j	80000192 <main+0xc8>

00000000800001ae <my_put>:
#define IER_TX_ENABLE   0x01  // 允许发送
#define LSR_TX_IDLE     0x20  // bit5: 发送器空闲

static volatile uint8 *const uart = (volatile uint8 *)UART0;

void my_put(int c) {
    800001ae:	1141                	addi	sp,sp,-16
    800001b0:	e422                	sd	s0,8(sp)
    800001b2:	0800                	addi	s0,sp,16
    // 等发送器空闲
    while ((uart[LSR] & LSR_TX_IDLE) == 0);
    800001b4:	10000737          	lui	a4,0x10000
    800001b8:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800001bc:	0207f793          	andi	a5,a5,32
    800001c0:	dfe5                	beqz	a5,800001b8 <my_put+0xa>

    uart[THR] = (uint8)c;
    800001c2:	0ff57513          	zext.b	a0,a0
    800001c6:	00a70023          	sb	a0,0(a4)
}
    800001ca:	6422                	ld	s0,8(sp)
    800001cc:	0141                	addi	sp,sp,16
    800001ce:	8082                	ret

00000000800001d0 <uartinit>:

void uartinit() {
    800001d0:	1141                	addi	sp,sp,-16
    800001d2:	e422                	sd	s0,8(sp)
    800001d4:	0800                	addi	s0,sp,16
    // 关中断
    uart[IER] = 0x00;
    800001d6:	100007b7          	lui	a5,0x10000
    800001da:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

    // 设置波特率
    uart[LCR] = LCR_BAUD_LATCH;
    800001de:	f8000713          	li	a4,-128
    800001e2:	00e781a3          	sb	a4,3(a5)
    uart[0] = 0x03;
    800001e6:	470d                	li	a4,3
    800001e8:	00e78023          	sb	a4,0(a5)
    uart[1] = 0x00;
    800001ec:	000780a3          	sb	zero,1(a5)

    uart[LCR] = LCR_EIGHT_BITS;
    800001f0:	00e781a3          	sb	a4,3(a5)

    // 开 FIFO 清空
    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;
    800001f4:	471d                	li	a4,7
    800001f6:	00e78123          	sb	a4,2(a5)

    uart[IER] = IER_TX_ENABLE;
    800001fa:	4705                	li	a4,1
    800001fc:	00e780a3          	sb	a4,1(a5)
    80000200:	6422                	ld	s0,8(sp)
    80000202:	0141                	addi	sp,sp,16
    80000204:	8082                	ret

0000000080000206 <printint>:

/* 按指定进制打印整数
   base: 10=十进制, 16=十六进制
   sign: 1=负号, 0=无负号 
*/
static void printint(int64 xx, int base, int sign) {
    80000206:	715d                	addi	sp,sp,-80
    80000208:	e0a2                	sd	s0,64(sp)
    8000020a:	e486                	sd	ra,72(sp)
    8000020c:	fc26                	sd	s1,56(sp)
    8000020e:	f84a                	sd	s2,48(sp)
    80000210:	f44e                	sd	s3,40(sp)
    80000212:	f052                	sd	s4,32(sp)
    80000214:	0880                	addi	s0,sp,80
    char buf[32];
    uint64 x;

    if (sign && xx < 0) {
    80000216:	c609                	beqz	a2,80000220 <printint+0x1a>
        x = (uint64)(-xx);
    80000218:	40a00733          	neg	a4,a0
    if (sign && xx < 0) {
    8000021c:	00054363          	bltz	a0,80000222 <printint+0x1c>
    } else {
        x = (uint64)xx;
    80000220:	872a                	mv	a4,a0
    }

    int i = 0;
    do {
        buf[i++] = digits[x % base];
    80000222:	fb040693          	addi	a3,s0,-80
    80000226:	4801                	li	a6,0
    80000228:	00000317          	auipc	t1,0x0
    8000022c:	45030313          	addi	t1,t1,1104 # 80000678 <digits>
    80000230:	02b777b3          	remu	a5,a4,a1
        x /= base;
    } while (x != 0);
    80000234:	0685                	addi	a3,a3,1
    80000236:	88ba                	mv	a7,a4
    80000238:	84c2                	mv	s1,a6
        buf[i++] = digits[x % base];
    8000023a:	2805                	addiw	a6,a6,1
    8000023c:	979a                	add	a5,a5,t1
    8000023e:	0007c783          	lbu	a5,0(a5)
        x /= base;
    80000242:	02b75733          	divu	a4,a4,a1
        buf[i++] = digits[x % base];
    80000246:	fef68fa3          	sb	a5,-1(a3)
    } while (x != 0);
    8000024a:	feb8f3e3          	bgeu	a7,a1,80000230 <printint+0x2a>

    if (sign && xx < 0) {
    8000024e:	c219                	beqz	a2,80000254 <printint+0x4e>
    80000250:	04054a63          	bltz	a0,800002a4 <printint+0x9e>
        buf[i++] = '-';
    }

    while (--i >= 0) {
    80000254:	fb040713          	addi	a4,s0,-80
    80000258:	94ba                	add	s1,s1,a4
    8000025a:	89ba                	mv	s3,a4
    if (c == '\n')
    8000025c:	4a29                	li	s4,10
    8000025e:	a819                	j	80000274 <printint+0x6e>
    my_put(c);
    80000260:	854a                	mv	a0,s2
    80000262:	00000097          	auipc	ra,0x0
    80000266:	f4c080e7          	jalr	-180(ra) # 800001ae <my_put>
    while (--i >= 0) {
    8000026a:	02998563          	beq	s3,s1,80000294 <printint+0x8e>
        putc(buf[i]);
    8000026e:	fff4c783          	lbu	a5,-1(s1)
    80000272:	14fd                	addi	s1,s1,-1
    80000274:	0007891b          	sext.w	s2,a5
    if (c == '\n')
    80000278:	ff4794e3          	bne	a5,s4,80000260 <printint+0x5a>
        my_put('\r');
    8000027c:	4535                	li	a0,13
    8000027e:	00000097          	auipc	ra,0x0
    80000282:	f30080e7          	jalr	-208(ra) # 800001ae <my_put>
    my_put(c);
    80000286:	854a                	mv	a0,s2
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	f26080e7          	jalr	-218(ra) # 800001ae <my_put>
    while (--i >= 0) {
    80000290:	fc999fe3          	bne	s3,s1,8000026e <printint+0x68>
    }
}
    80000294:	60a6                	ld	ra,72(sp)
    80000296:	6406                	ld	s0,64(sp)
    80000298:	74e2                	ld	s1,56(sp)
    8000029a:	7942                	ld	s2,48(sp)
    8000029c:	79a2                	ld	s3,40(sp)
    8000029e:	7a02                	ld	s4,32(sp)
    800002a0:	6161                	addi	sp,sp,80
    800002a2:	8082                	ret
        buf[i++] = '-';
    800002a4:	fd080793          	addi	a5,a6,-48
    800002a8:	97a2                	add	a5,a5,s0
    800002aa:	02d00713          	li	a4,45
    800002ae:	fee78023          	sb	a4,-32(a5)
        buf[i++] = digits[x % base];
    800002b2:	84c2                	mv	s1,a6
        buf[i++] = '-';
    800002b4:	02d00793          	li	a5,45
    800002b8:	bf71                	j	80000254 <printint+0x4e>

00000000800002ba <printf>:

static struct spinlock pr_lock;
static int pr_lock_inited;

// 格式化输出。支持 %d %u %x %p %s %c %%
void printf(const char *fmt, ...) {
    800002ba:	7171                	addi	sp,sp,-176
    800002bc:	f0a2                	sd	s0,96(sp)
    800002be:	eca6                	sd	s1,88(sp)
    800002c0:	1880                	addi	s0,sp,112
    800002c2:	ec66                	sd	s9,24(sp)
    800002c4:	f486                	sd	ra,104(sp)
    800002c6:	e8ca                	sd	s2,80(sp)
    800002c8:	e4ce                	sd	s3,72(sp)
    800002ca:	e0d2                	sd	s4,64(sp)
    800002cc:	fc56                	sd	s5,56(sp)
    800002ce:	f85a                	sd	s6,48(sp)
    800002d0:	f45e                	sd	s7,40(sp)
    800002d2:	f062                	sd	s8,32(sp)
    800002d4:	e86a                	sd	s10,16(sp)
    int c;
    const char *s;
    va_list ap;

    if (!pr_lock_inited) {
    800002d6:	00009497          	auipc	s1,0x9
    800002da:	d3a48493          	addi	s1,s1,-710 # 80009010 <pr_lock_inited>
    800002de:	0004a303          	lw	t1,0(s1)
void printf(const char *fmt, ...) {
    800002e2:	e40c                	sd	a1,8(s0)
    800002e4:	e810                	sd	a2,16(s0)
    800002e6:	ec14                	sd	a3,24(s0)
    800002e8:	f018                	sd	a4,32(s0)
    800002ea:	f41c                	sd	a5,40(s0)
    800002ec:	03043823          	sd	a6,48(s0)
    800002f0:	03143c23          	sd	a7,56(s0)
    800002f4:	8caa                	mv	s9,a0
    if (!pr_lock_inited) {
    800002f6:	1e030663          	beqz	t1,800004e2 <printf+0x228>
        initlock(&pr_lock, "printf");
        pr_lock_inited = 1;
    }

    acquire(&pr_lock);
    800002fa:	00009517          	auipc	a0,0x9
    800002fe:	d0650513          	addi	a0,a0,-762 # 80009000 <pr_lock>
    80000302:	00000097          	auipc	ra,0x0
    80000306:	21e080e7          	jalr	542(ra) # 80000520 <acquire>
    va_start(ap, fmt);
    for (; (c = *fmt) != 0; fmt++) {
    8000030a:	000ccc03          	lbu	s8,0(s9)
    va_start(ap, fmt);
    8000030e:	00840793          	addi	a5,s0,8
    80000312:	f8f43c23          	sd	a5,-104(s0)
    for (; (c = *fmt) != 0; fmt++) {
    80000316:	060c0863          	beqz	s8,80000386 <printf+0xcc>
        if (c != '%') {
    8000031a:	02500993          	li	s3,37

        fmt++;
        if (*fmt == 0)
            break;

        switch (*fmt) {
    8000031e:	4bd5                	li	s7,21
    if (c == '\n')
    80000320:	4929                	li	s2,10
        switch (*fmt) {
    80000322:	00000b17          	auipc	s6,0x0
    80000326:	2feb0b13          	addi	s6,s6,766 # 80000620 <release+0xde>
    8000032a:	00000a97          	auipc	s5,0x0
    8000032e:	34ea8a93          	addi	s5,s5,846 # 80000678 <digits>
    for (int i = 0; i < 16; i++) {
    80000332:	5a71                	li	s4,-4
        fmt++;
    80000334:	001c8493          	addi	s1,s9,1
        if (c != '%') {
    80000338:	173c1f63          	bne	s8,s3,800004b6 <printf+0x1fc>
        if (*fmt == 0)
    8000033c:	001cc783          	lbu	a5,1(s9)
    80000340:	c3b9                	beqz	a5,80000386 <printf+0xcc>
        switch (*fmt) {
    80000342:	19378363          	beq	a5,s3,800004c8 <printf+0x20e>
    80000346:	f9d7879b          	addiw	a5,a5,-99
    8000034a:	0ff7f793          	zext.b	a5,a5
    8000034e:	00fbe763          	bltu	s7,a5,8000035c <printf+0xa2>
    80000352:	078a                	slli	a5,a5,0x2
    80000354:	97da                	add	a5,a5,s6
    80000356:	439c                	lw	a5,0(a5)
    80000358:	97da                	add	a5,a5,s6
    8000035a:	8782                	jr	a5
    my_put(c);
    8000035c:	02500513          	li	a0,37
    80000360:	00000097          	auipc	ra,0x0
    80000364:	e4e080e7          	jalr	-434(ra) # 800001ae <my_put>
        case '%':
            putc('%');
            break;
        default:
            putc('%');
            putc(*fmt);
    80000368:	001ccc03          	lbu	s8,1(s9)
    if (c == '\n')
    8000036c:	132c0f63          	beq	s8,s2,800004aa <printf+0x1f0>
    my_put(c);
    80000370:	8562                	mv	a0,s8
    80000372:	00000097          	auipc	ra,0x0
    80000376:	e3c080e7          	jalr	-452(ra) # 800001ae <my_put>
    for (; (c = *fmt) != 0; fmt++) {
    8000037a:	0014cc03          	lbu	s8,1(s1)
    8000037e:	00148c93          	addi	s9,s1,1
    80000382:	fa0c19e3          	bnez	s8,80000334 <printf+0x7a>
            break;
        }
    }
    va_end(ap);
    release(&pr_lock);
    80000386:	00009517          	auipc	a0,0x9
    8000038a:	c7a50513          	addi	a0,a0,-902 # 80009000 <pr_lock>
    8000038e:	00000097          	auipc	ra,0x0
    80000392:	1b4080e7          	jalr	436(ra) # 80000542 <release>
    80000396:	70a6                	ld	ra,104(sp)
    80000398:	7406                	ld	s0,96(sp)
    8000039a:	64e6                	ld	s1,88(sp)
    8000039c:	6946                	ld	s2,80(sp)
    8000039e:	69a6                	ld	s3,72(sp)
    800003a0:	6a06                	ld	s4,64(sp)
    800003a2:	7ae2                	ld	s5,56(sp)
    800003a4:	7b42                	ld	s6,48(sp)
    800003a6:	7ba2                	ld	s7,40(sp)
    800003a8:	7c02                	ld	s8,32(sp)
    800003aa:	6ce2                	ld	s9,24(sp)
    800003ac:	6d42                	ld	s10,16(sp)
    800003ae:	614d                	addi	sp,sp,176
    800003b0:	8082                	ret
            printint(va_arg(ap, unsigned int), 16, 0);
    800003b2:	f9843783          	ld	a5,-104(s0)
    800003b6:	4601                	li	a2,0
    800003b8:	45c1                	li	a1,16
    800003ba:	0007e503          	lwu	a0,0(a5)
    800003be:	07a1                	addi	a5,a5,8
    800003c0:	f8f43c23          	sd	a5,-104(s0)
    800003c4:	00000097          	auipc	ra,0x0
    800003c8:	e42080e7          	jalr	-446(ra) # 80000206 <printint>
            break;
    800003cc:	b77d                	j	8000037a <printf+0xc0>
            printint(va_arg(ap, unsigned int), 10, 0);
    800003ce:	f9843783          	ld	a5,-104(s0)
    800003d2:	4601                	li	a2,0
    800003d4:	45a9                	li	a1,10
    800003d6:	0007e503          	lwu	a0,0(a5)
    800003da:	07a1                	addi	a5,a5,8
    800003dc:	f8f43c23          	sd	a5,-104(s0)
    800003e0:	00000097          	auipc	ra,0x0
    800003e4:	e26080e7          	jalr	-474(ra) # 80000206 <printint>
            break;
    800003e8:	bf49                	j	8000037a <printf+0xc0>
            s = va_arg(ap, const char *);
    800003ea:	f9843783          	ld	a5,-104(s0)
    800003ee:	0007bc03          	ld	s8,0(a5)
    800003f2:	07a1                	addi	a5,a5,8
    800003f4:	f8f43c23          	sd	a5,-104(s0)
            if (s == 0)
    800003f8:	000c1863          	bnez	s8,80000408 <printf+0x14e>
    800003fc:	a211                	j	80000500 <printf+0x246>
    my_put(c);
    800003fe:	8566                	mv	a0,s9
    80000400:	00000097          	auipc	ra,0x0
    80000404:	dae080e7          	jalr	-594(ra) # 800001ae <my_put>
            while (*s)
    80000408:	000c4783          	lbu	a5,0(s8)
    8000040c:	d7bd                	beqz	a5,8000037a <printf+0xc0>
                putc(*s++);
    8000040e:	0c05                	addi	s8,s8,1
    80000410:	00078c9b          	sext.w	s9,a5
    if (c == '\n')
    80000414:	ff2795e3          	bne	a5,s2,800003fe <printf+0x144>
        my_put('\r');
    80000418:	4535                	li	a0,13
    8000041a:	00000097          	auipc	ra,0x0
    8000041e:	d94080e7          	jalr	-620(ra) # 800001ae <my_put>
    80000422:	bff1                	j	800003fe <printf+0x144>
            printptr((uint64)va_arg(ap, void *));
    80000424:	f9843783          	ld	a5,-104(s0)
    my_put(c);
    80000428:	03000513          	li	a0,48
    8000042c:	03c00c93          	li	s9,60
            printptr((uint64)va_arg(ap, void *));
    80000430:	00878713          	addi	a4,a5,8
    80000434:	0007bc03          	ld	s8,0(a5)
    80000438:	f8e43c23          	sd	a4,-104(s0)
    my_put(c);
    8000043c:	00000097          	auipc	ra,0x0
    80000440:	d72080e7          	jalr	-654(ra) # 800001ae <my_put>
    80000444:	07800513          	li	a0,120
    80000448:	00000097          	auipc	ra,0x0
    8000044c:	d66080e7          	jalr	-666(ra) # 800001ae <my_put>
    for (int i = 0; i < 16; i++) {
    80000450:	a809                	j	80000462 <printf+0x1a8>
    80000452:	3cf1                	addiw	s9,s9,-4
    my_put(c);
    80000454:	856a                	mv	a0,s10
    80000456:	00000097          	auipc	ra,0x0
    8000045a:	d58080e7          	jalr	-680(ra) # 800001ae <my_put>
    for (int i = 0; i < 16; i++) {
    8000045e:	f14c8ee3          	beq	s9,s4,8000037a <printf+0xc0>
        putc(digits[(x >> shift) & 0xf]);
    80000462:	019c57b3          	srl	a5,s8,s9
    80000466:	8bbd                	andi	a5,a5,15
    80000468:	97d6                	add	a5,a5,s5
    8000046a:	0007cd03          	lbu	s10,0(a5)
    if (c == '\n')
    8000046e:	ff2d12e3          	bne	s10,s2,80000452 <printf+0x198>
        my_put('\r');
    80000472:	4535                	li	a0,13
    80000474:	00000097          	auipc	ra,0x0
    80000478:	d3a080e7          	jalr	-710(ra) # 800001ae <my_put>
    8000047c:	bfd9                	j	80000452 <printf+0x198>
            printint(va_arg(ap, int), 10, 1);
    8000047e:	f9843783          	ld	a5,-104(s0)
    80000482:	4605                	li	a2,1
    80000484:	45a9                	li	a1,10
    80000486:	4388                	lw	a0,0(a5)
    80000488:	07a1                	addi	a5,a5,8
    8000048a:	f8f43c23          	sd	a5,-104(s0)
    8000048e:	00000097          	auipc	ra,0x0
    80000492:	d78080e7          	jalr	-648(ra) # 80000206 <printint>
            break;
    80000496:	b5d5                	j	8000037a <printf+0xc0>
            putc(va_arg(ap, int));
    80000498:	f9843783          	ld	a5,-104(s0)
    8000049c:	0007ac03          	lw	s8,0(a5)
    800004a0:	07a1                	addi	a5,a5,8
    800004a2:	f8f43c23          	sd	a5,-104(s0)
    if (c == '\n')
    800004a6:	ed2c15e3          	bne	s8,s2,80000370 <printf+0xb6>
        my_put('\r');
    800004aa:	4535                	li	a0,13
    800004ac:	00000097          	auipc	ra,0x0
    800004b0:	d02080e7          	jalr	-766(ra) # 800001ae <my_put>
    800004b4:	bd75                	j	80000370 <printf+0xb6>
    if (c == '\n')
    800004b6:	032c0063          	beq	s8,s2,800004d6 <printf+0x21c>
    my_put(c);
    800004ba:	8562                	mv	a0,s8
    800004bc:	00000097          	auipc	ra,0x0
    800004c0:	cf2080e7          	jalr	-782(ra) # 800001ae <my_put>
            continue;
    800004c4:	84e6                	mv	s1,s9
    800004c6:	bd55                	j	8000037a <printf+0xc0>
    my_put(c);
    800004c8:	02500513          	li	a0,37
    800004cc:	00000097          	auipc	ra,0x0
    800004d0:	ce2080e7          	jalr	-798(ra) # 800001ae <my_put>
}
    800004d4:	b55d                	j	8000037a <printf+0xc0>
        my_put('\r');
    800004d6:	4535                	li	a0,13
    800004d8:	00000097          	auipc	ra,0x0
    800004dc:	cd6080e7          	jalr	-810(ra) # 800001ae <my_put>
    800004e0:	bfe9                	j	800004ba <printf+0x200>
        initlock(&pr_lock, "printf");
    800004e2:	00000597          	auipc	a1,0x0
    800004e6:	13658593          	addi	a1,a1,310 # 80000618 <release+0xd6>
    800004ea:	00009517          	auipc	a0,0x9
    800004ee:	b1650513          	addi	a0,a0,-1258 # 80009000 <pr_lock>
    800004f2:	00000097          	auipc	ra,0x0
    800004f6:	01c080e7          	jalr	28(ra) # 8000050e <initlock>
        pr_lock_inited = 1;
    800004fa:	4785                	li	a5,1
    800004fc:	c09c                	sw	a5,0(s1)
    800004fe:	bbf5                	j	800002fa <printf+0x40>
                s = "(null)";
    80000500:	00000c17          	auipc	s8,0x0
    80000504:	110c0c13          	addi	s8,s8,272 # 80000610 <release+0xce>
            while (*s)
    80000508:	02800793          	li	a5,40
    8000050c:	b709                	j	8000040e <printf+0x154>

000000008000050e <initlock>:
#include "riscv.h"
#include "spinlock.h"

void initlock(struct spinlock *lk, const char *name) {
    8000050e:	1141                	addi	sp,sp,-16
    80000510:	e422                	sd	s0,8(sp)
    80000512:	0800                	addi	s0,sp,16
    lk->locked = 0;
    lk->name = name;
}
    80000514:	6422                	ld	s0,8(sp)
    lk->locked = 0;
    80000516:	00052023          	sw	zero,0(a0)
    lk->name = name;
    8000051a:	e50c                	sd	a1,8(a0)
}
    8000051c:	0141                	addi	sp,sp,16
    8000051e:	8082                	ret

0000000080000520 <acquire>:
/*
acquire — 拿锁
先关中断，然后原子地抢锁
抢不到就在原地自旋，直到拿到为止
*/
void acquire(struct spinlock *lk) {
    80000520:	1141                	addi	sp,sp,-16
    80000522:	e422                	sd	s0,8(sp)
    80000524:	0800                	addi	s0,sp,16
}

// 关 S-mode 中断
static inline void intr_off(void) {
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
    80000526:	4789                	li	a5,2
    80000528:	1007b073          	csrc	sstatus,a5
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0);
    8000052c:	4705                	li	a4,1
    8000052e:	87ba                	mv	a5,a4
    80000530:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    80000534:	2781                	sext.w	a5,a5
    80000536:	ffe5                	bnez	a5,8000052e <acquire+0xe>
    __sync_synchronize(); // 让其他核能看到 lock 的状态
    80000538:	0ff0000f          	fence
}
    8000053c:	6422                	ld	s0,8(sp)
    8000053e:	0141                	addi	sp,sp,16
    80000540:	8082                	ret

0000000080000542 <release>:

/*
release — 放锁
先保证之前的所有内存操作对别的核可见，然后原子放锁，最后开中断
*/
void release(struct spinlock *lk) {
    80000542:	1141                	addi	sp,sp,-16
    80000544:	e422                	sd	s0,8(sp)
    80000546:	0800                	addi	s0,sp,16
    __sync_synchronize();
    80000548:	0ff0000f          	fence
    __sync_lock_release(&lk->locked);
    8000054c:	0f50000f          	fence	iorw,ow
    80000550:	0805202f          	amoswap.w	zero,zero,(a0)
}

// 开 S-mode 中断
static inline void intr_on(void) {
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
    80000554:	4789                	li	a5,2
    80000556:	1007a073          	csrs	sstatus,a5
    intr_on();
}
    8000055a:	6422                	ld	s0,8(sp)
    8000055c:	0141                	addi	sp,sp,16
    8000055e:	8082                	ret
