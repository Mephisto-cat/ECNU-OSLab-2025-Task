
build/kernel-qemu.elf:     file format elf64-littleriscv


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
    8000001a:	56a080e7          	jalr	1386(ra) # 80000580 <start>

000000008000001e <main>:
#include "lib/mod.h"
#include "arch/method.h"

void main() {
    8000001e:	1101                	addi	sp,sp,-32
    80000020:	e822                	sd	s0,16(sp)
    80000022:	ec06                	sd	ra,24(sp)
    80000024:	e426                	sd	s1,8(sp)
    80000026:	1000                	addi	s0,sp,32
    uartinit();
    80000028:	00000097          	auipc	ra,0x0
    8000002c:	138080e7          	jalr	312(ra) # 80000160 <uartinit>
#include "arch/type.h"

// 读 cpuid (启动时从 mhartid 写入 tp 寄存器)
static inline uint64 r_cpuid(void) {
    uint64 x;
    asm volatile("mv %0, tp" : "=r"(x));
    80000030:	8492                	mv	s1,tp

    int cpuid = r_cpuid();
    printf("\n");
    80000032:	00000517          	auipc	a0,0x0
    80000036:	5be50513          	addi	a0,a0,1470 # 800005f0 <start+0x70>
    int cpuid = r_cpuid();
    8000003a:	2481                	sext.w	s1,s1
    printf("\n");
    8000003c:	00000097          	auipc	ra,0x0
    80000040:	212080e7          	jalr	530(ra) # 8000024e <printf>
    printf("cpu %d is booting\n", cpuid);
    80000044:	85a6                	mv	a1,s1
    80000046:	00000517          	auipc	a0,0x0
    8000004a:	5b250513          	addi	a0,a0,1458 # 800005f8 <start+0x78>
    8000004e:	00000097          	auipc	ra,0x0
    80000052:	200080e7          	jalr	512(ra) # 8000024e <printf>

    if (cpuid == 0) {
    80000056:	e4f1                	bnez	s1,80000122 <main+0x104>
        printf("Hello, World!\n");
    80000058:	00000517          	auipc	a0,0x0
    8000005c:	5b850513          	addi	a0,a0,1464 # 80000610 <start+0x90>
    80000060:	00000097          	auipc	ra,0x0
    80000064:	1ee080e7          	jalr	494(ra) # 8000024e <printf>
        printf("=== printf test ===\n");
    80000068:	00000517          	auipc	a0,0x0
    8000006c:	5b850513          	addi	a0,a0,1464 # 80000620 <start+0xa0>
    80000070:	00000097          	auipc	ra,0x0
    80000074:	1de080e7          	jalr	478(ra) # 8000024e <printf>
        printf("%%d: %d\n", -42);
    80000078:	fd600593          	li	a1,-42
    8000007c:	00000517          	auipc	a0,0x0
    80000080:	5bc50513          	addi	a0,a0,1468 # 80000638 <start+0xb8>
    80000084:	00000097          	auipc	ra,0x0
    80000088:	1ca080e7          	jalr	458(ra) # 8000024e <printf>
        printf("%%u: %u\n", 12345U);
    8000008c:	658d                	lui	a1,0x3
    8000008e:	03958593          	addi	a1,a1,57 # 3039 <_entry-0x7fffcfc7>
    80000092:	00000517          	auipc	a0,0x0
    80000096:	5b650513          	addi	a0,a0,1462 # 80000648 <start+0xc8>
    8000009a:	00000097          	auipc	ra,0x0
    8000009e:	1b4080e7          	jalr	436(ra) # 8000024e <printf>
        printf("%%x: %x\n", 0xdeadU);
    800000a2:	65b9                	lui	a1,0xe
    800000a4:	ead58593          	addi	a1,a1,-339 # dead <_entry-0x7fff2153>
    800000a8:	00000517          	auipc	a0,0x0
    800000ac:	5b050513          	addi	a0,a0,1456 # 80000658 <start+0xd8>
    800000b0:	00000097          	auipc	ra,0x0
    800000b4:	19e080e7          	jalr	414(ra) # 8000024e <printf>
        printf("%%p: %p\n", (void *)0x80000000UL);
    800000b8:	4585                	li	a1,1
    800000ba:	05fe                	slli	a1,a1,0x1f
    800000bc:	00000517          	auipc	a0,0x0
    800000c0:	5ac50513          	addi	a0,a0,1452 # 80000668 <start+0xe8>
    800000c4:	00000097          	auipc	ra,0x0
    800000c8:	18a080e7          	jalr	394(ra) # 8000024e <printf>
        printf("%%s: %s\n", "hello");
    800000cc:	00000597          	auipc	a1,0x0
    800000d0:	5ac58593          	addi	a1,a1,1452 # 80000678 <start+0xf8>
    800000d4:	00000517          	auipc	a0,0x0
    800000d8:	5ac50513          	addi	a0,a0,1452 # 80000680 <start+0x100>
    800000dc:	00000097          	auipc	ra,0x0
    800000e0:	172080e7          	jalr	370(ra) # 8000024e <printf>
        printf("%%c: %c\n", 'X');
    800000e4:	05800593          	li	a1,88
    800000e8:	00000517          	auipc	a0,0x0
    800000ec:	5a850513          	addi	a0,a0,1448 # 80000690 <start+0x110>
    800000f0:	00000097          	auipc	ra,0x0
    800000f4:	15e080e7          	jalr	350(ra) # 8000024e <printf>
        printf("%%%%: 100%%\n");
    800000f8:	00000517          	auipc	a0,0x0
    800000fc:	5a850513          	addi	a0,a0,1448 # 800006a0 <start+0x120>
    80000100:	00000097          	auipc	ra,0x0
    80000104:	14e080e7          	jalr	334(ra) # 8000024e <printf>
        printf("=== done ===\n");
    80000108:	00000517          	auipc	a0,0x0
    8000010c:	5a850513          	addi	a0,a0,1448 # 800006b0 <start+0x130>
    80000110:	00000097          	auipc	ra,0x0
    80000114:	13e080e7          	jalr	318(ra) # 8000024e <printf>
    return x;
}

// 停机等待中断
static inline void wfi(void) {
    asm volatile("wfi");
    80000118:	10500073          	wfi
    8000011c:	10500073          	wfi
    } else {
        printf("Hello, OS!\n");
    }

    for (;;) {
    80000120:	bfe5                	j	80000118 <main+0xfa>
        printf("Hello, OS!\n");
    80000122:	00000517          	auipc	a0,0x0
    80000126:	59e50513          	addi	a0,a0,1438 # 800006c0 <start+0x140>
    8000012a:	00000097          	auipc	ra,0x0
    8000012e:	124080e7          	jalr	292(ra) # 8000024e <printf>
    80000132:	10500073          	wfi
    for (;;) {
    80000136:	b7dd                	j	8000011c <main+0xfe>

0000000080000138 <my_put>:
#define IER_TX_ENABLE   0x01
#define LSR_TX_IDLE     0x20

static volatile uint8 *const uart = (volatile uint8 *)UART0;

void my_put(int c) {
    80000138:	1141                	addi	sp,sp,-16
    8000013a:	e422                	sd	s0,8(sp)
    while ((uart[LSR] & LSR_TX_IDLE) == 0) {}
    8000013c:	10000737          	lui	a4,0x10000
void my_put(int c) {
    80000140:	0800                	addi	s0,sp,16
    while ((uart[LSR] & LSR_TX_IDLE) == 0) {}
    80000142:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000144:	00074783          	lbu	a5,0(a4)
    80000148:	0207f793          	andi	a5,a5,32
    8000014c:	dfe5                	beqz	a5,80000144 <my_put+0xc>
    uart[THR] = (uint8)c;
    8000014e:	0ff57513          	zext.b	a0,a0
    80000152:	100007b7          	lui	a5,0x10000
    80000156:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    8000015a:	6422                	ld	s0,8(sp)
    8000015c:	0141                	addi	sp,sp,16
    8000015e:	8082                	ret

0000000080000160 <uartinit>:

void uartinit() {
    80000160:	1141                	addi	sp,sp,-16
    80000162:	e422                	sd	s0,8(sp)
    80000164:	0800                	addi	s0,sp,16
    uart[IER] = 0x00;
    80000166:	100007b7          	lui	a5,0x10000
    8000016a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

    uart[LCR] = LCR_BAUD_LATCH;
    8000016e:	10000737          	lui	a4,0x10000
    80000172:	f8000693          	li	a3,-128
    80000176:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>
    uart[0] = 0x03;
    8000017a:	460d                	li	a2,3
    uart[IER] = 0x00;
    8000017c:	100006b7          	lui	a3,0x10000
    uart[0] = 0x03;
    80000180:	00c68023          	sb	a2,0(a3) # 10000000 <_entry-0x70000000>
    uart[1] = 0x00;
    80000184:	000780a3          	sb	zero,1(a5)

    uart[LCR] = LCR_EIGHT_BITS;
    80000188:	00c701a3          	sb	a2,3(a4)

    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;
    8000018c:	471d                	li	a4,7
    8000018e:	00e68123          	sb	a4,2(a3)

    uart[IER] = IER_TX_ENABLE;
    80000192:	4705                	li	a4,1
    80000194:	00e780a3          	sb	a4,1(a5)
}
    80000198:	6422                	ld	s0,8(sp)
    8000019a:	0141                	addi	sp,sp,16
    8000019c:	8082                	ret

000000008000019e <printint>:
        my_put('\r');
    }
    my_put(c);
}

static void printint(int64 xx, int base, int sign) {
    8000019e:	715d                	addi	sp,sp,-80
    800001a0:	e0a2                	sd	s0,64(sp)
    800001a2:	e486                	sd	ra,72(sp)
    800001a4:	fc26                	sd	s1,56(sp)
    800001a6:	f84a                	sd	s2,48(sp)
    800001a8:	f44e                	sd	s3,40(sp)
    800001aa:	f052                	sd	s4,32(sp)
    800001ac:	0880                	addi	s0,sp,80
    char buf[32];
    uint64 x;

    if (sign && xx < 0) {
    800001ae:	c609                	beqz	a2,800001b8 <printint+0x1a>
        x = (uint64)(-xx);
    800001b0:	40a007b3          	neg	a5,a0
    if (sign && xx < 0) {
    800001b4:	00054363          	bltz	a0,800001ba <printint+0x1c>
    } else {
        x = (uint64)xx;
    800001b8:	87aa                	mv	a5,a0
    }

    int i = 0;
    do {
        buf[i++] = digits[x % base];
    800001ba:	fb040693          	addi	a3,s0,-80
    800001be:	4801                	li	a6,0
    800001c0:	00000317          	auipc	t1,0x0
    800001c4:	57830313          	addi	t1,t1,1400 # 80000738 <digits>
    800001c8:	02b7f733          	remu	a4,a5,a1
        x /= base;
    } while (x != 0);
    800001cc:	0685                	addi	a3,a3,1
    800001ce:	88be                	mv	a7,a5
    800001d0:	84c2                	mv	s1,a6
        buf[i++] = digits[x % base];
    800001d2:	2805                	addiw	a6,a6,1
    800001d4:	971a                	add	a4,a4,t1
    800001d6:	00074703          	lbu	a4,0(a4)
        x /= base;
    800001da:	02b7d7b3          	divu	a5,a5,a1
        buf[i++] = digits[x % base];
    800001de:	fee68fa3          	sb	a4,-1(a3)
    } while (x != 0);
    800001e2:	feb8f3e3          	bgeu	a7,a1,800001c8 <printint+0x2a>

    if (sign && xx < 0) {
    800001e6:	c219                	beqz	a2,800001ec <printint+0x4e>
    800001e8:	04054a63          	bltz	a0,8000023c <printint+0x9e>
    800001ec:	fb040793          	addi	a5,s0,-80
    800001f0:	94be                	add	s1,s1,a5
    800001f2:	fff78993          	addi	s3,a5,-1
    if (c == '\n') {
    800001f6:	4a29                	li	s4,10
    800001f8:	a809                	j	8000020a <printint+0x6c>
    my_put(c);
    800001fa:	854a                	mv	a0,s2
        buf[i++] = '-';
    }

    while (--i >= 0) {
    800001fc:	14fd                	addi	s1,s1,-1
    my_put(c);
    800001fe:	00000097          	auipc	ra,0x0
    80000202:	f3a080e7          	jalr	-198(ra) # 80000138 <my_put>
    while (--i >= 0) {
    80000206:	03348363          	beq	s1,s3,8000022c <printint+0x8e>
        putc(buf[i]);
    8000020a:	0004c903          	lbu	s2,0(s1)
    if (c == '\n') {
    8000020e:	ff4916e3          	bne	s2,s4,800001fa <printint+0x5c>
        my_put('\r');
    80000212:	4535                	li	a0,13
    80000214:	00000097          	auipc	ra,0x0
    80000218:	f24080e7          	jalr	-220(ra) # 80000138 <my_put>
    my_put(c);
    8000021c:	854a                	mv	a0,s2
    while (--i >= 0) {
    8000021e:	14fd                	addi	s1,s1,-1
    my_put(c);
    80000220:	00000097          	auipc	ra,0x0
    80000224:	f18080e7          	jalr	-232(ra) # 80000138 <my_put>
    while (--i >= 0) {
    80000228:	ff3491e3          	bne	s1,s3,8000020a <printint+0x6c>
    }
}
    8000022c:	60a6                	ld	ra,72(sp)
    8000022e:	6406                	ld	s0,64(sp)
    80000230:	74e2                	ld	s1,56(sp)
    80000232:	7942                	ld	s2,48(sp)
    80000234:	79a2                	ld	s3,40(sp)
    80000236:	7a02                	ld	s4,32(sp)
    80000238:	6161                	addi	sp,sp,80
    8000023a:	8082                	ret
        buf[i++] = '-';
    8000023c:	fd080793          	addi	a5,a6,-48
    80000240:	97a2                	add	a5,a5,s0
    80000242:	02d00713          	li	a4,45
    80000246:	fee78023          	sb	a4,-32(a5)
    while (--i >= 0) {
    8000024a:	84c2                	mv	s1,a6
    8000024c:	b745                	j	800001ec <printint+0x4e>

000000008000024e <printf>:
}

static struct spinlock pr_lock;
static int pr_lock_inited;

void printf(const char *fmt, ...) {
    8000024e:	7131                	addi	sp,sp,-192
    80000250:	f8a2                	sd	s0,112(sp)
    80000252:	f4a6                	sd	s1,104(sp)
    80000254:	0100                	addi	s0,sp,128
    80000256:	f0ca                	sd	s2,96(sp)
    80000258:	fc86                	sd	ra,120(sp)
    8000025a:	ecce                	sd	s3,88(sp)
    int c;
    const char *s;
    va_list ap;

    if (!pr_lock_inited) {
    8000025c:	0000a917          	auipc	s2,0xa
    80000260:	da490913          	addi	s2,s2,-604 # 8000a000 <pr_lock_inited>
    80000264:	00092303          	lw	t1,0(s2)
void printf(const char *fmt, ...) {
    80000268:	e40c                	sd	a1,8(s0)
    8000026a:	e810                	sd	a2,16(s0)
    8000026c:	ec14                	sd	a3,24(s0)
    8000026e:	f018                	sd	a4,32(s0)
    80000270:	f41c                	sd	a5,40(s0)
    80000272:	03043823          	sd	a6,48(s0)
    80000276:	03143c23          	sd	a7,56(s0)
    8000027a:	84aa                	mv	s1,a0
    if (!pr_lock_inited) {
    8000027c:	20030b63          	beqz	t1,80000492 <printf+0x244>
        initlock(&pr_lock, "printf");
        pr_lock_inited = 1;
    }

    acquire(&pr_lock);
    80000280:	00001517          	auipc	a0,0x1
    80000284:	d8050513          	addi	a0,a0,-640 # 80001000 <pr_lock>
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	2b8080e7          	jalr	696(ra) # 80000540 <acquire>
    va_start(ap, fmt);
    for (; (c = *fmt) != 0; fmt++) {
    80000290:	0004c983          	lbu	s3,0(s1)
    va_start(ap, fmt);
    80000294:	00840793          	addi	a5,s0,8
    80000298:	f8f43423          	sd	a5,-120(s0)
    for (; (c = *fmt) != 0; fmt++) {
    8000029c:	06098c63          	beqz	s3,80000314 <printf+0xc6>
    800002a0:	fc5e                	sd	s7,56(sp)
    800002a2:	f862                	sd	s8,48(sp)
    800002a4:	f466                	sd	s9,40(sp)
    800002a6:	e8d2                	sd	s4,80(sp)
    800002a8:	e4d6                	sd	s5,72(sp)
        if (c != '%') {
    800002aa:	02500913          	li	s2,37
        fmt++;
        if (*fmt == 0) {
            break;
        }

        switch (*fmt) {
    800002ae:	4c55                	li	s8,21
    800002b0:	00000b97          	auipc	s7,0x0
    800002b4:	430b8b93          	addi	s7,s7,1072 # 800006e0 <start+0x160>
    if (c == '\n') {
    800002b8:	4ca9                	li	s9,10
        if (c != '%') {
    800002ba:	1b299763          	bne	s3,s2,80000468 <printf+0x21a>
        if (*fmt == 0) {
    800002be:	0014c783          	lbu	a5,1(s1)
    800002c2:	c7a1                	beqz	a5,8000030a <printf+0xbc>
        switch (*fmt) {
    800002c4:	1b278a63          	beq	a5,s2,80000478 <printf+0x22a>
    800002c8:	f9d7879b          	addiw	a5,a5,-99
    800002cc:	0ff7f793          	zext.b	a5,a5
    800002d0:	00fc6763          	bltu	s8,a5,800002de <printf+0x90>
    800002d4:	078a                	slli	a5,a5,0x2
    800002d6:	97de                	add	a5,a5,s7
    800002d8:	439c                	lw	a5,0(a5)
    800002da:	97de                	add	a5,a5,s7
    800002dc:	8782                	jr	a5
    my_put(c);
    800002de:	02500513          	li	a0,37
    800002e2:	00000097          	auipc	ra,0x0
    800002e6:	e56080e7          	jalr	-426(ra) # 80000138 <my_put>
        case '%':
            putc('%');
            break;
        default:
            putc('%');
            putc(*fmt);
    800002ea:	0014c983          	lbu	s3,1(s1)
    if (c == '\n') {
    800002ee:	47a9                	li	a5,10
    800002f0:	16f98663          	beq	s3,a5,8000045c <printf+0x20e>
    my_put(c);
    800002f4:	854e                	mv	a0,s3
    800002f6:	00000097          	auipc	ra,0x0
    800002fa:	e42080e7          	jalr	-446(ra) # 80000138 <my_put>
        fmt++;
    800002fe:	0485                	addi	s1,s1,1
    for (; (c = *fmt) != 0; fmt++) {
    80000300:	0014c983          	lbu	s3,1(s1)
    80000304:	0485                	addi	s1,s1,1
    80000306:	fa099ae3          	bnez	s3,800002ba <printf+0x6c>
    8000030a:	6a46                	ld	s4,80(sp)
    8000030c:	6aa6                	ld	s5,72(sp)
    8000030e:	7be2                	ld	s7,56(sp)
    80000310:	7c42                	ld	s8,48(sp)
    80000312:	7ca2                	ld	s9,40(sp)
            break;
        }
    }
    va_end(ap);
    release(&pr_lock);
    80000314:	00001517          	auipc	a0,0x1
    80000318:	cec50513          	addi	a0,a0,-788 # 80001000 <pr_lock>
    8000031c:	00000097          	auipc	ra,0x0
    80000320:	246080e7          	jalr	582(ra) # 80000562 <release>
}
    80000324:	70e6                	ld	ra,120(sp)
    80000326:	7446                	ld	s0,112(sp)
    80000328:	74a6                	ld	s1,104(sp)
    8000032a:	7906                	ld	s2,96(sp)
    8000032c:	69e6                	ld	s3,88(sp)
    8000032e:	6129                	addi	sp,sp,192
    80000330:	8082                	ret
            printint(va_arg(ap, unsigned int), 16, 0);
    80000332:	f8843783          	ld	a5,-120(s0)
    80000336:	4601                	li	a2,0
    80000338:	45c1                	li	a1,16
    8000033a:	0007e503          	lwu	a0,0(a5)
    8000033e:	07a1                	addi	a5,a5,8
    80000340:	f8f43423          	sd	a5,-120(s0)
    80000344:	00000097          	auipc	ra,0x0
    80000348:	e5a080e7          	jalr	-422(ra) # 8000019e <printint>
            break;
    8000034c:	bf4d                	j	800002fe <printf+0xb0>
            printint(va_arg(ap, unsigned int), 10, 0);
    8000034e:	f8843783          	ld	a5,-120(s0)
    80000352:	4601                	li	a2,0
    80000354:	45a9                	li	a1,10
    80000356:	0007e503          	lwu	a0,0(a5)
    8000035a:	07a1                	addi	a5,a5,8
    8000035c:	f8f43423          	sd	a5,-120(s0)
    80000360:	00000097          	auipc	ra,0x0
    80000364:	e3e080e7          	jalr	-450(ra) # 8000019e <printint>
            break;
    80000368:	bf59                	j	800002fe <printf+0xb0>
            s = va_arg(ap, const char *);
    8000036a:	f8843783          	ld	a5,-120(s0)
    8000036e:	0007b983          	ld	s3,0(a5)
    80000372:	07a1                	addi	a5,a5,8
    80000374:	f8f43423          	sd	a5,-120(s0)
            if (s == 0) {
    80000378:	12098d63          	beqz	s3,800004b2 <printf+0x264>
            while (*s) {
    8000037c:	0009c783          	lbu	a5,0(s3)
    80000380:	dfbd                	beqz	a5,800002fe <printf+0xb0>
    if (c == '\n') {
    80000382:	4aa9                	li	s5,10
    80000384:	a809                	j	80000396 <printf+0x148>
    my_put(c);
    80000386:	8552                	mv	a0,s4
    80000388:	00000097          	auipc	ra,0x0
    8000038c:	db0080e7          	jalr	-592(ra) # 80000138 <my_put>
            while (*s) {
    80000390:	0009c783          	lbu	a5,0(s3)
    80000394:	d7ad                	beqz	a5,800002fe <printf+0xb0>
                putc(*s++);
    80000396:	0985                	addi	s3,s3,1
    80000398:	00078a1b          	sext.w	s4,a5
    if (c == '\n') {
    8000039c:	ff5795e3          	bne	a5,s5,80000386 <printf+0x138>
        my_put('\r');
    800003a0:	4535                	li	a0,13
    800003a2:	00000097          	auipc	ra,0x0
    800003a6:	d96080e7          	jalr	-618(ra) # 80000138 <my_put>
    800003aa:	bff1                	j	80000386 <printf+0x138>
            printptr((uint64)va_arg(ap, void *));
    800003ac:	f8843783          	ld	a5,-120(s0)
    my_put(c);
    800003b0:	03000513          	li	a0,48
    800003b4:	e0da                	sd	s6,64(sp)
            printptr((uint64)va_arg(ap, void *));
    800003b6:	00878713          	addi	a4,a5,8
    800003ba:	0007bb03          	ld	s6,0(a5)
    800003be:	f06a                	sd	s10,32(sp)
    800003c0:	f8e43423          	sd	a4,-120(s0)
    800003c4:	ec6e                	sd	s11,24(sp)
    my_put(c);
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	d72080e7          	jalr	-654(ra) # 80000138 <my_put>
    800003ce:	07800513          	li	a0,120
    800003d2:	00000097          	auipc	ra,0x0
    800003d6:	d66080e7          	jalr	-666(ra) # 80000138 <my_put>
    800003da:	03c00d13          	li	s10,60
    800003de:	00000a97          	auipc	s5,0x0
    800003e2:	35aa8a93          	addi	s5,s5,858 # 80000738 <digits>
    if (c == '\n') {
    800003e6:	4a29                	li	s4,10
    for (int i = 0; i < 16; i++) {
    800003e8:	59f1                	li	s3,-4
    800003ea:	a809                	j	800003fc <printf+0x1ae>
    my_put(c);
    800003ec:	856e                	mv	a0,s11
    for (int i = 0; i < 16; i++) {
    800003ee:	3d71                	addiw	s10,s10,-4
    my_put(c);
    800003f0:	00000097          	auipc	ra,0x0
    800003f4:	d48080e7          	jalr	-696(ra) # 80000138 <my_put>
    for (int i = 0; i < 16; i++) {
    800003f8:	033d0763          	beq	s10,s3,80000426 <printf+0x1d8>
        putc(digits[(x >> shift) & 0xf]);
    800003fc:	01ab57b3          	srl	a5,s6,s10
    80000400:	8bbd                	andi	a5,a5,15
    80000402:	97d6                	add	a5,a5,s5
    80000404:	0007cd83          	lbu	s11,0(a5)
    if (c == '\n') {
    80000408:	ff4d92e3          	bne	s11,s4,800003ec <printf+0x19e>
        my_put('\r');
    8000040c:	4535                	li	a0,13
    8000040e:	00000097          	auipc	ra,0x0
    80000412:	d2a080e7          	jalr	-726(ra) # 80000138 <my_put>
    my_put(c);
    80000416:	856e                	mv	a0,s11
    for (int i = 0; i < 16; i++) {
    80000418:	3d71                	addiw	s10,s10,-4
    my_put(c);
    8000041a:	00000097          	auipc	ra,0x0
    8000041e:	d1e080e7          	jalr	-738(ra) # 80000138 <my_put>
    for (int i = 0; i < 16; i++) {
    80000422:	fd3d1de3          	bne	s10,s3,800003fc <printf+0x1ae>
    80000426:	6b06                	ld	s6,64(sp)
    80000428:	7d02                	ld	s10,32(sp)
    8000042a:	6de2                	ld	s11,24(sp)
    8000042c:	bdc9                	j	800002fe <printf+0xb0>
            printint(va_arg(ap, int), 10, 1);
    8000042e:	f8843783          	ld	a5,-120(s0)
    80000432:	4605                	li	a2,1
    80000434:	45a9                	li	a1,10
    80000436:	4388                	lw	a0,0(a5)
    80000438:	07a1                	addi	a5,a5,8
    8000043a:	f8f43423          	sd	a5,-120(s0)
    8000043e:	00000097          	auipc	ra,0x0
    80000442:	d60080e7          	jalr	-672(ra) # 8000019e <printint>
            break;
    80000446:	bd65                	j	800002fe <printf+0xb0>
            putc(va_arg(ap, int));
    80000448:	f8843783          	ld	a5,-120(s0)
    if (c == '\n') {
    8000044c:	4729                	li	a4,10
            putc(va_arg(ap, int));
    8000044e:	0007a983          	lw	s3,0(a5)
    80000452:	07a1                	addi	a5,a5,8
    80000454:	f8f43423          	sd	a5,-120(s0)
    if (c == '\n') {
    80000458:	e8e99ee3          	bne	s3,a4,800002f4 <printf+0xa6>
        my_put('\r');
    8000045c:	4535                	li	a0,13
    8000045e:	00000097          	auipc	ra,0x0
    80000462:	cda080e7          	jalr	-806(ra) # 80000138 <my_put>
    80000466:	b579                	j	800002f4 <printf+0xa6>
    if (c == '\n') {
    80000468:	01998f63          	beq	s3,s9,80000486 <printf+0x238>
    my_put(c);
    8000046c:	854e                	mv	a0,s3
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	cca080e7          	jalr	-822(ra) # 80000138 <my_put>
            continue;
    80000476:	b569                	j	80000300 <printf+0xb2>
    my_put(c);
    80000478:	02500513          	li	a0,37
    8000047c:	00000097          	auipc	ra,0x0
    80000480:	cbc080e7          	jalr	-836(ra) # 80000138 <my_put>
}
    80000484:	bdad                	j	800002fe <printf+0xb0>
        my_put('\r');
    80000486:	4535                	li	a0,13
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	cb0080e7          	jalr	-848(ra) # 80000138 <my_put>
    80000490:	bff1                	j	8000046c <printf+0x21e>
        initlock(&pr_lock, "printf");
    80000492:	00000597          	auipc	a1,0x0
    80000496:	24658593          	addi	a1,a1,582 # 800006d8 <start+0x158>
    8000049a:	00001517          	auipc	a0,0x1
    8000049e:	b6650513          	addi	a0,a0,-1178 # 80001000 <pr_lock>
    800004a2:	00000097          	auipc	ra,0x0
    800004a6:	08c080e7          	jalr	140(ra) # 8000052e <initlock>
        pr_lock_inited = 1;
    800004aa:	4785                	li	a5,1
    800004ac:	00f92023          	sw	a5,0(s2)
    800004b0:	bbc1                	j	80000280 <printf+0x32>
    800004b2:	02800793          	li	a5,40
                s = "(null)";
    800004b6:	00000997          	auipc	s3,0x0
    800004ba:	21a98993          	addi	s3,s3,538 # 800006d0 <start+0x150>
    800004be:	b5d1                	j	80000382 <printf+0x134>

00000000800004c0 <r_mstatus>:
#include "arch/type.h"

uint64 r_mstatus() {
    800004c0:	1141                	addi	sp,sp,-16
    800004c2:	e422                	sd	s0,8(sp)
    800004c4:	0800                	addi	s0,sp,16
    uint64 x;
    asm volatile("csrr %0, mstatus" : "=r"(x));
    800004c6:	30002573          	csrr	a0,mstatus
    return x;
}
    800004ca:	6422                	ld	s0,8(sp)
    800004cc:	0141                	addi	sp,sp,16
    800004ce:	8082                	ret

00000000800004d0 <w_mstatus>:

void w_mstatus(uint64 x) {
    800004d0:	1141                	addi	sp,sp,-16
    800004d2:	e422                	sd	s0,8(sp)
    800004d4:	0800                	addi	s0,sp,16
    asm volatile("csrw mstatus, %0" : : "r"(x));
    800004d6:	30051073          	csrw	mstatus,a0
}
    800004da:	6422                	ld	s0,8(sp)
    800004dc:	0141                	addi	sp,sp,16
    800004de:	8082                	ret

00000000800004e0 <w_mepc>:

void w_mepc(uint64 x) {
    800004e0:	1141                	addi	sp,sp,-16
    800004e2:	e422                	sd	s0,8(sp)
    800004e4:	0800                	addi	s0,sp,16
    asm volatile("csrw mepc, %0" : : "r"(x));
    800004e6:	34151073          	csrw	mepc,a0
}
    800004ea:	6422                	ld	s0,8(sp)
    800004ec:	0141                	addi	sp,sp,16
    800004ee:	8082                	ret

00000000800004f0 <w_pmpaddr0>:

void w_pmpaddr0(uint64 x) {
    800004f0:	1141                	addi	sp,sp,-16
    800004f2:	e422                	sd	s0,8(sp)
    800004f4:	0800                	addi	s0,sp,16
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800004f6:	3b051073          	csrw	pmpaddr0,a0
}
    800004fa:	6422                	ld	s0,8(sp)
    800004fc:	0141                	addi	sp,sp,16
    800004fe:	8082                	ret

0000000080000500 <w_pmpcfg0>:

void w_pmpcfg0(uint64 x) {
    80000500:	1141                	addi	sp,sp,-16
    80000502:	e422                	sd	s0,8(sp)
    80000504:	0800                	addi	s0,sp,16
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    80000506:	3a051073          	csrw	pmpcfg0,a0
}
    8000050a:	6422                	ld	s0,8(sp)
    8000050c:	0141                	addi	sp,sp,16
    8000050e:	8082                	ret

0000000080000510 <r_mhartid>:

uint64 r_mhartid() {
    80000510:	1141                	addi	sp,sp,-16
    80000512:	e422                	sd	s0,8(sp)
    80000514:	0800                	addi	s0,sp,16
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    80000516:	f1402573          	csrr	a0,mhartid
    return x;
}
    8000051a:	6422                	ld	s0,8(sp)
    8000051c:	0141                	addi	sp,sp,16
    8000051e:	8082                	ret

0000000080000520 <w_tp>:

void w_tp(uint64 x) {
    80000520:	1141                	addi	sp,sp,-16
    80000522:	e422                	sd	s0,8(sp)
    80000524:	0800                	addi	s0,sp,16
    asm volatile("mv tp, %0" : : "r"(x));
    80000526:	822a                	mv	tp,a0
}
    80000528:	6422                	ld	s0,8(sp)
    8000052a:	0141                	addi	sp,sp,16
    8000052c:	8082                	ret

000000008000052e <initlock>:
#include "lock/mod.h"
#include "arch/method.h"

void initlock(struct spinlock *lk, const char *name) {
    8000052e:	1141                	addi	sp,sp,-16
    80000530:	e422                	sd	s0,8(sp)
    80000532:	0800                	addi	s0,sp,16
    lk->locked = 0;
    lk->name = name;
}
    80000534:	6422                	ld	s0,8(sp)
    lk->locked = 0;
    80000536:	00052023          	sw	zero,0(a0)
    lk->name = name;
    8000053a:	e50c                	sd	a1,8(a0)
}
    8000053c:	0141                	addi	sp,sp,16
    8000053e:	8082                	ret

0000000080000540 <acquire>:
/*
acquire — 拿锁
先关中断，然后原子地抢锁
抢不到就在原地自旋，直到拿到为止
*/
void acquire(struct spinlock *lk) {
    80000540:	1141                	addi	sp,sp,-16
    80000542:	e422                	sd	s0,8(sp)
    80000544:	0800                	addi	s0,sp,16
}

// 关 S-mode 中断
static inline void intr_off(void) {
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
    80000546:	4789                	li	a5,2
    80000548:	1007b073          	csrc	sstatus,a5
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0) {}
    8000054c:	4705                	li	a4,1
    8000054e:	87ba                	mv	a5,a4
    80000550:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    80000554:	2781                	sext.w	a5,a5
    80000556:	ffe5                	bnez	a5,8000054e <acquire+0xe>
    __sync_synchronize();
    80000558:	0330000f          	fence	rw,rw
}
    8000055c:	6422                	ld	s0,8(sp)
    8000055e:	0141                	addi	sp,sp,16
    80000560:	8082                	ret

0000000080000562 <release>:

/*
release — 放锁
先保证之前的所有内存操作对别的核可见，然后原子放锁，最后开中断
*/
void release(struct spinlock *lk) {
    80000562:	1141                	addi	sp,sp,-16
    80000564:	e422                	sd	s0,8(sp)
    80000566:	0800                	addi	s0,sp,16
    __sync_synchronize();
    80000568:	0330000f          	fence	rw,rw
    __sync_lock_release(&lk->locked);
    8000056c:	0310000f          	fence	rw,w
    80000570:	00052023          	sw	zero,0(a0)
}

// 开 S-mode 中断
static inline void intr_on(void) {
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
    80000574:	4789                	li	a5,2
    80000576:	1007a073          	csrs	sstatus,a5
    intr_on();
}
    8000057a:	6422                	ld	s0,8(sp)
    8000057c:	0141                	addi	sp,sp,16
    8000057e:	8082                	ret

0000000080000580 <start>:
void   w_pmpcfg0(uint64 x);
uint64 r_mhartid();
void   w_tp(uint64 x);


void start() {
    80000580:	1141                	addi	sp,sp,-16
    80000582:	e406                	sd	ra,8(sp)
    80000584:	e022                	sd	s0,0(sp)
    80000586:	0800                	addi	s0,sp,16
    w_tp(r_mhartid());
    80000588:	00000097          	auipc	ra,0x0
    8000058c:	f88080e7          	jalr	-120(ra) # 80000510 <r_mhartid>
    80000590:	00000097          	auipc	ra,0x0
    80000594:	f90080e7          	jalr	-112(ra) # 80000520 <w_tp>

    uint64 x = r_mstatus();
    80000598:	00000097          	auipc	ra,0x0
    8000059c:	f28080e7          	jalr	-216(ra) # 800004c0 <r_mstatus>
    // 3（二进制 11）	M-mode
    // 1（二进制 01）	S-mode
    // 0（二进制 00）	U-mode

    // x 现在是 M-mode，将其变为 S-mode
    x &= ~(2UL << 11);
    800005a0:	777d                	lui	a4,0xfffff
    800005a2:	177d                	addi	a4,a4,-1 # ffffffffffffefff <pr_lock_inited+0xffffffff7fff4fff>
    x |=  (1UL << 11);
    800005a4:	6785                	lui	a5,0x1
    x &= ~(2UL << 11);
    800005a6:	8d79                	and	a0,a0,a4
    x |=  (1UL << 11);
    800005a8:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    w_mstatus(x);
    800005ac:	8d5d                	or	a0,a0,a5
    800005ae:	00000097          	auipc	ra,0x0
    800005b2:	f22080e7          	jalr	-222(ra) # 800004d0 <w_mstatus>

    w_mepc((uint64)main);
    800005b6:	00000517          	auipc	a0,0x0
    800005ba:	a6850513          	addi	a0,a0,-1432 # 8000001e <main>
    800005be:	00000097          	auipc	ra,0x0
    800005c2:	f22080e7          	jalr	-222(ra) # 800004e0 <w_mepc>

    w_pmpaddr0(0x3fffffffffffffull);
    800005c6:	557d                	li	a0,-1
    800005c8:	8129                	srli	a0,a0,0xa
    800005ca:	00000097          	auipc	ra,0x0
    800005ce:	f26080e7          	jalr	-218(ra) # 800004f0 <w_pmpaddr0>
    w_pmpcfg0(0xf);
    800005d2:	453d                	li	a0,15
    800005d4:	00000097          	auipc	ra,0x0
    800005d8:	f2c080e7          	jalr	-212(ra) # 80000500 <w_pmpcfg0>

    asm volatile("mret");
    800005dc:	30200073          	mret

    while (1) {}
    800005e0:	a001                	j	800005e0 <start+0x60>
