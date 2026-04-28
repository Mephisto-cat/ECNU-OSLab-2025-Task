
kernel-qemu.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
# 每个 hart 分配独立的 4KB 栈，然后 call start
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
    80000016:	004000ef          	jal	ra,8000001a <start>

000000008000001a <start>:

void main(void);

// entry.S 把我们放在 M-mode，切到 S-mode 再进 main
__attribute__((noreturn)) void start(void)
{
    8000001a:	1141                	addi	sp,sp,-16
    8000001c:	e422                	sd	s0,8(sp)
    8000001e:	0800                	addi	s0,sp,16
// RISC-V CSR 读写内联汇编

static inline uint64 r_mhartid(void)
{
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    80000020:	f14027f3          	csrr	a5,mhartid
    return x;
}

static inline void w_tp(uint64 x)
{
    asm volatile("mv tp, %0" : : "r"(x));
    80000024:	823e                	mv	tp,a5
}

static inline uint64 r_mstatus(void)
{
    uint64 x;
    asm volatile("csrr %0, mstatus" : "=r"(x));
    80000026:	300027f3          	csrr	a5,mstatus
    // hartid 只能在 M-mode 读，存到 tp 带下去
    w_tp(r_mhartid());

    // mstatus.MPP 设成 S-mode，mret 之后就会进 Supervisor
    x = r_mstatus();
    x &= ~MSTATUS_MPP_MASK;
    8000002a:	7779                	lui	a4,0xffffe
    8000002c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <pr_lock_inited+0xffffffff7fff57ef>
    80000030:	8ff9                	and	a5,a5,a4
    x |= MSTATUS_MPP_S;
    80000032:	6705                	lui	a4,0x1
    80000034:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000038:	8fd9                	or	a5,a5,a4
    return x;
}

static inline void w_mstatus(uint64 x)
{
    asm volatile("csrw mstatus, %0" : : "r"(x));
    8000003a:	30079073          	csrw	mstatus,a5
}

static inline void w_mepc(uint64 x)
{
    asm volatile("csrw mepc, %0" : : "r"(x));
    8000003e:	00000797          	auipc	a5,0x0
    80000042:	03278793          	addi	a5,a5,50 # 80000070 <main>
    80000046:	34179073          	csrw	mepc,a5
}

static inline void w_satp(uint64 x)
{
    asm volatile("csrw satp, %0" : : "r"(x));
    8000004a:	4781                	li	a5,0
    8000004c:	18079073          	csrw	satp,a5
    asm volatile("csrw sie, %0" : : "r"(x));
}

static inline void w_medeleg(uint64 x)
{
    asm volatile("csrw medeleg, %0" : : "r"(x));
    80000050:	30279073          	csrw	medeleg,a5
}

static inline void w_mideleg(uint64 x)
{
    asm volatile("csrw mideleg, %0" : : "r"(x));
    80000054:	30379073          	csrw	mideleg,a5
    asm volatile("csrw sie, %0" : : "r"(x));
    80000058:	10479073          	csrw	sie,a5
}

static inline void w_pmpaddr0(uint64 x)
{
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    8000005c:	57fd                	li	a5,-1
    8000005e:	83a9                	srli	a5,a5,0xa
    80000060:	3b079073          	csrw	pmpaddr0,a5
}

static inline void w_pmpcfg0(uint64 x)
{
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    80000064:	47bd                	li	a5,15
    80000066:	3a079073          	csrw	pmpcfg0,a5

    // PMP：允许 S-mode 访问全部物理内存
    w_pmpaddr0(0x3fffffffffffffull);
    w_pmpcfg0(0xf);

    asm volatile("mret");
    8000006a:	30200073          	mret

    for (;;)
    8000006e:	a001                	j	8000006e <start+0x54>

0000000080000070 <main>:
#include "printf.h"
#include "riscv.h"
#include "uart.h"

void main(void)
{
    80000070:	1101                	addi	sp,sp,-32
    80000072:	e822                	sd	s0,16(sp)
    80000074:	ec06                	sd	ra,24(sp)
    80000076:	e426                	sd	s1,8(sp)
    80000078:	1000                	addi	s0,sp,32
    uint64 hartid;

    uartinit();
    8000007a:	00000097          	auipc	ra,0x0
    8000007e:	08e080e7          	jalr	142(ra) # 80000108 <uartinit>
    asm volatile("mv %0, tp" : "=r"(x));
    80000082:	8492                	mv	s1,tp
    hartid = r_tp();

    printf("\n");
    80000084:	00000517          	auipc	a0,0x0
    80000088:	41c50513          	addi	a0,a0,1052 # 800004a0 <release+0x28>
    8000008c:	00000097          	auipc	ra,0x0
    80000090:	164080e7          	jalr	356(ra) # 800001f0 <printf>
    printf("Lab1 kernel entered main() on hart %d\n", (int)hartid);
    80000094:	0004859b          	sext.w	a1,s1
    80000098:	00000517          	auipc	a0,0x0
    8000009c:	41050513          	addi	a0,a0,1040 # 800004a8 <release+0x30>
    800000a0:	00000097          	auipc	ra,0x0
    800000a4:	150080e7          	jalr	336(ra) # 800001f0 <printf>
    printf("Hello, world from S-mode!\n");
    800000a8:	00000517          	auipc	a0,0x0
    800000ac:	42850513          	addi	a0,a0,1064 # 800004d0 <release+0x58>
    800000b0:	00000097          	auipc	ra,0x0
    800000b4:	140080e7          	jalr	320(ra) # 800001f0 <printf>
    printf("UART MMIO base = %p\n", (void *)0x10000000UL);
    800000b8:	00000517          	auipc	a0,0x0
    800000bc:	43850513          	addi	a0,a0,1080 # 800004f0 <release+0x78>
    800000c0:	100005b7          	lui	a1,0x10000
    800000c4:	00000097          	auipc	ra,0x0
    800000c8:	12c080e7          	jalr	300(ra) # 800001f0 <printf>
    printf("This printf is protected by a spinlock.\n");
    800000cc:	00000517          	auipc	a0,0x0
    800000d0:	43c50513          	addi	a0,a0,1084 # 80000508 <release+0x90>
    800000d4:	00000097          	auipc	ra,0x0
    800000d8:	11c080e7          	jalr	284(ra) # 800001f0 <printf>
    return (x & 2UL) != 0;
}

static inline void wfi(void)
{
    asm volatile("wfi");
    800000dc:	10500073          	wfi
    800000e0:	10500073          	wfi
    800000e4:	bfe5                	j	800000dc <main+0x6c>

00000000800000e6 <uartputc_sync>:

// volatile — 硬件可能随时改，每次必须真读
static volatile uint8 *const uart = (volatile uint8 *)UART0;

void uartputc_sync(int c)
{
    800000e6:	1141                	addi	sp,sp,-16
    800000e8:	e422                	sd	s0,8(sp)
    800000ea:	0800                	addi	s0,sp,16
    while ((uart[LSR] & LSR_TX_IDLE) == 0)
    800000ec:	10000737          	lui	a4,0x10000
    800000f0:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800000f4:	0207f793          	andi	a5,a5,32
    800000f8:	dfe5                	beqz	a5,800000f0 <uartputc_sync+0xa>
        ;
    uart[THR] = (uint8)c;
    800000fa:	0ff57513          	zext.b	a0,a0
    800000fe:	00a70023          	sb	a0,0(a4)
}
    80000102:	6422                	ld	s0,8(sp)
    80000104:	0141                	addi	sp,sp,16
    80000106:	8082                	ret

0000000080000108 <uartinit>:

void uartinit(void)
{
    80000108:	1141                	addi	sp,sp,-16
    8000010a:	e422                	sd	s0,8(sp)
    8000010c:	0800                	addi	s0,sp,16
    // 关中断，初始化期间寄存器不稳定
    uart[IER] = 0x00;
    8000010e:	100007b7          	lui	a5,0x10000
    80000112:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

    // 设波特率：开 DLAB，写分频器，关 DLAB
    uart[LCR] = LCR_BAUD_LATCH;
    80000116:	f8000713          	li	a4,-128
    8000011a:	00e781a3          	sb	a4,3(a5)
    uart[0]   = 0x03;
    8000011e:	470d                	li	a4,3
    80000120:	00e78023          	sb	a4,0(a5)
    uart[1]   = 0x00;
    80000124:	000780a3          	sb	zero,1(a5)

    // 8 数据位，无校验，1 停止位
    uart[LCR] = LCR_EIGHT_BITS;
    80000128:	00e781a3          	sb	a4,3(a5)

    // 开 FIFO 并清空
    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;
    8000012c:	469d                	li	a3,7
    8000012e:	00d78123          	sb	a3,2(a5)

    // 开收发
    uart[IER] = IER_TX_ENABLE | IER_RX_ENABLE;
    80000132:	00e780a3          	sb	a4,1(a5)
}
    80000136:	6422                	ld	s0,8(sp)
    80000138:	0141                	addi	sp,sp,16
    8000013a:	8082                	ret

000000008000013c <printint>:
        uartputc_sync('\r');    // 串口需要 \r\n
    uartputc_sync(c);
}

static void printint(int64 xx, int base, int sign)
{
    8000013c:	715d                	addi	sp,sp,-80
    8000013e:	e0a2                	sd	s0,64(sp)
    80000140:	e486                	sd	ra,72(sp)
    80000142:	fc26                	sd	s1,56(sp)
    80000144:	f84a                	sd	s2,48(sp)
    80000146:	f44e                	sd	s3,40(sp)
    80000148:	f052                	sd	s4,32(sp)
    8000014a:	0880                	addi	s0,sp,80
    char buf[32];
    int i;
    uint64 x;

    if (sign && xx < 0)
    8000014c:	c609                	beqz	a2,80000156 <printint+0x1a>
        x = (uint64)(-xx);
    8000014e:	40a00733          	neg	a4,a0
    if (sign && xx < 0)
    80000152:	00054363          	bltz	a0,80000158 <printint+0x1c>
    else
        x = (uint64)xx;
    80000156:	872a                	mv	a4,a0

    i = 0;
    do {
        buf[i++] = digits[x % base];
    80000158:	fb040693          	addi	a3,s0,-80
    8000015c:	4801                	li	a6,0
    8000015e:	00000317          	auipc	t1,0x0
    80000162:	44230313          	addi	t1,t1,1090 # 800005a0 <digits>
    80000166:	02b777b3          	remu	a5,a4,a1
        x /= base;
    } while (x != 0);
    8000016a:	0685                	addi	a3,a3,1
    8000016c:	88ba                	mv	a7,a4
    8000016e:	84c2                	mv	s1,a6
        buf[i++] = digits[x % base];
    80000170:	2805                	addiw	a6,a6,1
    80000172:	979a                	add	a5,a5,t1
    80000174:	0007c783          	lbu	a5,0(a5)
        x /= base;
    80000178:	02b75733          	divu	a4,a4,a1
        buf[i++] = digits[x % base];
    8000017c:	fef68fa3          	sb	a5,-1(a3)
    } while (x != 0);
    80000180:	feb8f3e3          	bgeu	a7,a1,80000166 <printint+0x2a>

    if (sign && xx < 0)
    80000184:	c219                	beqz	a2,8000018a <printint+0x4e>
    80000186:	04054a63          	bltz	a0,800001da <printint+0x9e>
        buf[i++] = '-';

    while (--i >= 0)
    8000018a:	fb040713          	addi	a4,s0,-80
    8000018e:	94ba                	add	s1,s1,a4
    80000190:	89ba                	mv	s3,a4
    if (c == '\n')
    80000192:	4a29                	li	s4,10
    80000194:	a819                	j	800001aa <printint+0x6e>
    uartputc_sync(c);
    80000196:	854a                	mv	a0,s2
    80000198:	00000097          	auipc	ra,0x0
    8000019c:	f4e080e7          	jalr	-178(ra) # 800000e6 <uartputc_sync>
    while (--i >= 0)
    800001a0:	02998563          	beq	s3,s1,800001ca <printint+0x8e>
        putc(buf[i]);
    800001a4:	fff4c783          	lbu	a5,-1(s1)
    800001a8:	14fd                	addi	s1,s1,-1
    800001aa:	0007891b          	sext.w	s2,a5
    if (c == '\n')
    800001ae:	ff4794e3          	bne	a5,s4,80000196 <printint+0x5a>
        uartputc_sync('\r');    // 串口需要 \r\n
    800001b2:	4535                	li	a0,13
    800001b4:	00000097          	auipc	ra,0x0
    800001b8:	f32080e7          	jalr	-206(ra) # 800000e6 <uartputc_sync>
    uartputc_sync(c);
    800001bc:	854a                	mv	a0,s2
    800001be:	00000097          	auipc	ra,0x0
    800001c2:	f28080e7          	jalr	-216(ra) # 800000e6 <uartputc_sync>
    while (--i >= 0)
    800001c6:	fc999fe3          	bne	s3,s1,800001a4 <printint+0x68>
}
    800001ca:	60a6                	ld	ra,72(sp)
    800001cc:	6406                	ld	s0,64(sp)
    800001ce:	74e2                	ld	s1,56(sp)
    800001d0:	7942                	ld	s2,48(sp)
    800001d2:	79a2                	ld	s3,40(sp)
    800001d4:	7a02                	ld	s4,32(sp)
    800001d6:	6161                	addi	sp,sp,80
    800001d8:	8082                	ret
        buf[i++] = '-';
    800001da:	fd080793          	addi	a5,a6,-48
    800001de:	97a2                	add	a5,a5,s0
    800001e0:	02d00713          	li	a4,45
    800001e4:	fee78023          	sb	a4,-32(a5)
        buf[i++] = digits[x % base];
    800001e8:	84c2                	mv	s1,a6
        buf[i++] = '-';
    800001ea:	02d00793          	li	a5,45
    800001ee:	bf71                	j	8000018a <printint+0x4e>

00000000800001f0 <printf>:
    }
}

// 支持 %d %u %x %p %s %c %%
void printf(const char *fmt, ...)
{
    800001f0:	7171                	addi	sp,sp,-176
    800001f2:	f0a2                	sd	s0,96(sp)
    800001f4:	eca6                	sd	s1,88(sp)
    800001f6:	1880                	addi	s0,sp,112
    800001f8:	ec66                	sd	s9,24(sp)
    800001fa:	f486                	sd	ra,104(sp)
    800001fc:	e8ca                	sd	s2,80(sp)
    800001fe:	e4ce                	sd	s3,72(sp)
    80000200:	e0d2                	sd	s4,64(sp)
    80000202:	fc56                	sd	s5,56(sp)
    80000204:	f85a                	sd	s6,48(sp)
    80000206:	f45e                	sd	s7,40(sp)
    80000208:	f062                	sd	s8,32(sp)
    8000020a:	e86a                	sd	s10,16(sp)
    int c;
    const char *s;
    va_list ap;

    if (!pr_lock_inited) {
    8000020c:	00009497          	auipc	s1,0x9
    80000210:	e0448493          	addi	s1,s1,-508 # 80009010 <pr_lock_inited>
    80000214:	0004a303          	lw	t1,0(s1)
{
    80000218:	e40c                	sd	a1,8(s0)
    8000021a:	e810                	sd	a2,16(s0)
    8000021c:	ec14                	sd	a3,24(s0)
    8000021e:	f018                	sd	a4,32(s0)
    80000220:	f41c                	sd	a5,40(s0)
    80000222:	03043823          	sd	a6,48(s0)
    80000226:	03143c23          	sd	a7,56(s0)
    8000022a:	8caa                	mv	s9,a0
    if (!pr_lock_inited) {
    8000022c:	1e030663          	beqz	t1,80000418 <printf+0x228>
        initlock(&pr_lock, "printf");
        pr_lock_inited = 1;
    }

    acquire(&pr_lock);
    80000230:	00009517          	auipc	a0,0x9
    80000234:	dd050513          	addi	a0,a0,-560 # 80009000 <pr_lock>
    80000238:	00000097          	auipc	ra,0x0
    8000023c:	21e080e7          	jalr	542(ra) # 80000456 <acquire>

    va_start(ap, fmt);
    for (; (c = *fmt) != 0; fmt++) {
    80000240:	000ccc03          	lbu	s8,0(s9)
    va_start(ap, fmt);
    80000244:	00840793          	addi	a5,s0,8
    80000248:	f8f43c23          	sd	a5,-104(s0)
    for (; (c = *fmt) != 0; fmt++) {
    8000024c:	060c0863          	beqz	s8,800002bc <printf+0xcc>
        if (c != '%') {
    80000250:	02500993          	li	s3,37

        fmt++;
        if (*fmt == 0)
            break;

        switch (*fmt) {
    80000254:	4bd5                	li	s7,21
    if (c == '\n')
    80000256:	4929                	li	s2,10
        switch (*fmt) {
    80000258:	00000b17          	auipc	s6,0x0
    8000025c:	2f0b0b13          	addi	s6,s6,752 # 80000548 <release+0xd0>
    80000260:	00000a97          	auipc	s5,0x0
    80000264:	340a8a93          	addi	s5,s5,832 # 800005a0 <digits>
    for (i = 0; i < 16; i++) {
    80000268:	5a71                	li	s4,-4
        fmt++;
    8000026a:	001c8493          	addi	s1,s9,1
        if (c != '%') {
    8000026e:	173c1f63          	bne	s8,s3,800003ec <printf+0x1fc>
        if (*fmt == 0)
    80000272:	001cc783          	lbu	a5,1(s9)
    80000276:	c3b9                	beqz	a5,800002bc <printf+0xcc>
        switch (*fmt) {
    80000278:	19378363          	beq	a5,s3,800003fe <printf+0x20e>
    8000027c:	f9d7879b          	addiw	a5,a5,-99
    80000280:	0ff7f793          	zext.b	a5,a5
    80000284:	00fbe763          	bltu	s7,a5,80000292 <printf+0xa2>
    80000288:	078a                	slli	a5,a5,0x2
    8000028a:	97da                	add	a5,a5,s6
    8000028c:	439c                	lw	a5,0(a5)
    8000028e:	97da                	add	a5,a5,s6
    80000290:	8782                	jr	a5
    uartputc_sync(c);
    80000292:	02500513          	li	a0,37
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	e50080e7          	jalr	-432(ra) # 800000e6 <uartputc_sync>
        case '%':
            putc('%');
            break;
        default:
            putc('%');
            putc(*fmt);
    8000029e:	001ccc03          	lbu	s8,1(s9)
    if (c == '\n')
    800002a2:	132c0f63          	beq	s8,s2,800003e0 <printf+0x1f0>
    uartputc_sync(c);
    800002a6:	8562                	mv	a0,s8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	e3e080e7          	jalr	-450(ra) # 800000e6 <uartputc_sync>
    for (; (c = *fmt) != 0; fmt++) {
    800002b0:	0014cc03          	lbu	s8,1(s1)
    800002b4:	00148c93          	addi	s9,s1,1
    800002b8:	fa0c19e3          	bnez	s8,8000026a <printf+0x7a>
            break;
        }
    }
    va_end(ap);

    release(&pr_lock);
    800002bc:	00009517          	auipc	a0,0x9
    800002c0:	d4450513          	addi	a0,a0,-700 # 80009000 <pr_lock>
    800002c4:	00000097          	auipc	ra,0x0
    800002c8:	1b4080e7          	jalr	436(ra) # 80000478 <release>
}
    800002cc:	70a6                	ld	ra,104(sp)
    800002ce:	7406                	ld	s0,96(sp)
    800002d0:	64e6                	ld	s1,88(sp)
    800002d2:	6946                	ld	s2,80(sp)
    800002d4:	69a6                	ld	s3,72(sp)
    800002d6:	6a06                	ld	s4,64(sp)
    800002d8:	7ae2                	ld	s5,56(sp)
    800002da:	7b42                	ld	s6,48(sp)
    800002dc:	7ba2                	ld	s7,40(sp)
    800002de:	7c02                	ld	s8,32(sp)
    800002e0:	6ce2                	ld	s9,24(sp)
    800002e2:	6d42                	ld	s10,16(sp)
    800002e4:	614d                	addi	sp,sp,176
    800002e6:	8082                	ret
            printint(va_arg(ap, unsigned int), 16, 0);
    800002e8:	f9843783          	ld	a5,-104(s0)
    800002ec:	4601                	li	a2,0
    800002ee:	45c1                	li	a1,16
    800002f0:	0007e503          	lwu	a0,0(a5)
    800002f4:	07a1                	addi	a5,a5,8
    800002f6:	f8f43c23          	sd	a5,-104(s0)
    800002fa:	00000097          	auipc	ra,0x0
    800002fe:	e42080e7          	jalr	-446(ra) # 8000013c <printint>
            break;
    80000302:	b77d                	j	800002b0 <printf+0xc0>
            printint(va_arg(ap, unsigned int), 10, 0);
    80000304:	f9843783          	ld	a5,-104(s0)
    80000308:	4601                	li	a2,0
    8000030a:	45a9                	li	a1,10
    8000030c:	0007e503          	lwu	a0,0(a5)
    80000310:	07a1                	addi	a5,a5,8
    80000312:	f8f43c23          	sd	a5,-104(s0)
    80000316:	00000097          	auipc	ra,0x0
    8000031a:	e26080e7          	jalr	-474(ra) # 8000013c <printint>
            break;
    8000031e:	bf49                	j	800002b0 <printf+0xc0>
            s = va_arg(ap, const char *);
    80000320:	f9843783          	ld	a5,-104(s0)
    80000324:	0007bc03          	ld	s8,0(a5)
    80000328:	07a1                	addi	a5,a5,8
    8000032a:	f8f43c23          	sd	a5,-104(s0)
            if (s == 0)
    8000032e:	000c1863          	bnez	s8,8000033e <printf+0x14e>
    80000332:	a211                	j	80000436 <printf+0x246>
    uartputc_sync(c);
    80000334:	8566                	mv	a0,s9
    80000336:	00000097          	auipc	ra,0x0
    8000033a:	db0080e7          	jalr	-592(ra) # 800000e6 <uartputc_sync>
            while (*s)
    8000033e:	000c4783          	lbu	a5,0(s8)
    80000342:	d7bd                	beqz	a5,800002b0 <printf+0xc0>
                putc(*s++);
    80000344:	0c05                	addi	s8,s8,1
    80000346:	00078c9b          	sext.w	s9,a5
    if (c == '\n')
    8000034a:	ff2795e3          	bne	a5,s2,80000334 <printf+0x144>
        uartputc_sync('\r');    // 串口需要 \r\n
    8000034e:	4535                	li	a0,13
    80000350:	00000097          	auipc	ra,0x0
    80000354:	d96080e7          	jalr	-618(ra) # 800000e6 <uartputc_sync>
    80000358:	bff1                	j	80000334 <printf+0x144>
            printptr((uint64)va_arg(ap, void *));
    8000035a:	f9843783          	ld	a5,-104(s0)
    uartputc_sync(c);
    8000035e:	03000513          	li	a0,48
    80000362:	03c00c93          	li	s9,60
            printptr((uint64)va_arg(ap, void *));
    80000366:	00878713          	addi	a4,a5,8
    8000036a:	0007bc03          	ld	s8,0(a5)
    8000036e:	f8e43c23          	sd	a4,-104(s0)
    uartputc_sync(c);
    80000372:	00000097          	auipc	ra,0x0
    80000376:	d74080e7          	jalr	-652(ra) # 800000e6 <uartputc_sync>
    8000037a:	07800513          	li	a0,120
    8000037e:	00000097          	auipc	ra,0x0
    80000382:	d68080e7          	jalr	-664(ra) # 800000e6 <uartputc_sync>
    for (i = 0; i < 16; i++) {
    80000386:	a809                	j	80000398 <printf+0x1a8>
    80000388:	3cf1                	addiw	s9,s9,-4
    uartputc_sync(c);
    8000038a:	856a                	mv	a0,s10
    8000038c:	00000097          	auipc	ra,0x0
    80000390:	d5a080e7          	jalr	-678(ra) # 800000e6 <uartputc_sync>
    for (i = 0; i < 16; i++) {
    80000394:	f14c8ee3          	beq	s9,s4,800002b0 <printf+0xc0>
        putc(digits[(x >> shift) & 0xf]);
    80000398:	019c57b3          	srl	a5,s8,s9
    8000039c:	8bbd                	andi	a5,a5,15
    8000039e:	97d6                	add	a5,a5,s5
    800003a0:	0007cd03          	lbu	s10,0(a5)
    if (c == '\n')
    800003a4:	ff2d12e3          	bne	s10,s2,80000388 <printf+0x198>
        uartputc_sync('\r');    // 串口需要 \r\n
    800003a8:	4535                	li	a0,13
    800003aa:	00000097          	auipc	ra,0x0
    800003ae:	d3c080e7          	jalr	-708(ra) # 800000e6 <uartputc_sync>
    800003b2:	bfd9                	j	80000388 <printf+0x198>
            printint(va_arg(ap, int), 10, 1);
    800003b4:	f9843783          	ld	a5,-104(s0)
    800003b8:	4605                	li	a2,1
    800003ba:	45a9                	li	a1,10
    800003bc:	4388                	lw	a0,0(a5)
    800003be:	07a1                	addi	a5,a5,8
    800003c0:	f8f43c23          	sd	a5,-104(s0)
    800003c4:	00000097          	auipc	ra,0x0
    800003c8:	d78080e7          	jalr	-648(ra) # 8000013c <printint>
            break;
    800003cc:	b5d5                	j	800002b0 <printf+0xc0>
            putc(va_arg(ap, int));
    800003ce:	f9843783          	ld	a5,-104(s0)
    800003d2:	0007ac03          	lw	s8,0(a5)
    800003d6:	07a1                	addi	a5,a5,8
    800003d8:	f8f43c23          	sd	a5,-104(s0)
    if (c == '\n')
    800003dc:	ed2c15e3          	bne	s8,s2,800002a6 <printf+0xb6>
        uartputc_sync('\r');    // 串口需要 \r\n
    800003e0:	4535                	li	a0,13
    800003e2:	00000097          	auipc	ra,0x0
    800003e6:	d04080e7          	jalr	-764(ra) # 800000e6 <uartputc_sync>
    800003ea:	bd75                	j	800002a6 <printf+0xb6>
    if (c == '\n')
    800003ec:	032c0063          	beq	s8,s2,8000040c <printf+0x21c>
    uartputc_sync(c);
    800003f0:	8562                	mv	a0,s8
    800003f2:	00000097          	auipc	ra,0x0
    800003f6:	cf4080e7          	jalr	-780(ra) # 800000e6 <uartputc_sync>
            continue;
    800003fa:	84e6                	mv	s1,s9
    800003fc:	bd55                	j	800002b0 <printf+0xc0>
    uartputc_sync(c);
    800003fe:	02500513          	li	a0,37
    80000402:	00000097          	auipc	ra,0x0
    80000406:	ce4080e7          	jalr	-796(ra) # 800000e6 <uartputc_sync>
}
    8000040a:	b55d                	j	800002b0 <printf+0xc0>
        uartputc_sync('\r');    // 串口需要 \r\n
    8000040c:	4535                	li	a0,13
    8000040e:	00000097          	auipc	ra,0x0
    80000412:	cd8080e7          	jalr	-808(ra) # 800000e6 <uartputc_sync>
    80000416:	bfe9                	j	800003f0 <printf+0x200>
        initlock(&pr_lock, "printf");
    80000418:	00000597          	auipc	a1,0x0
    8000041c:	12858593          	addi	a1,a1,296 # 80000540 <release+0xc8>
    80000420:	00009517          	auipc	a0,0x9
    80000424:	be050513          	addi	a0,a0,-1056 # 80009000 <pr_lock>
    80000428:	00000097          	auipc	ra,0x0
    8000042c:	01c080e7          	jalr	28(ra) # 80000444 <initlock>
        pr_lock_inited = 1;
    80000430:	4785                	li	a5,1
    80000432:	c09c                	sw	a5,0(s1)
    80000434:	bbf5                	j	80000230 <printf+0x40>
                s = "(null)";
    80000436:	00000c17          	auipc	s8,0x0
    8000043a:	102c0c13          	addi	s8,s8,258 # 80000538 <release+0xc0>
            while (*s)
    8000043e:	02800793          	li	a5,40
    80000442:	b709                	j	80000344 <printf+0x154>

0000000080000444 <initlock>:
#include "riscv.h"
#include "spinlock.h"

void initlock(struct spinlock *lk, const char *name)
{
    80000444:	1141                	addi	sp,sp,-16
    80000446:	e422                	sd	s0,8(sp)
    80000448:	0800                	addi	s0,sp,16
    lk->locked = 0;
    lk->name = name;
}
    8000044a:	6422                	ld	s0,8(sp)
    lk->locked = 0;
    8000044c:	00052023          	sw	zero,0(a0)
    lk->name = name;
    80000450:	e50c                	sd	a1,8(a0)
}
    80000452:	0141                	addi	sp,sp,16
    80000454:	8082                	ret

0000000080000456 <acquire>:

// 关中断后原子抢锁，抢不到就自旋
void acquire(struct spinlock *lk)
{
    80000456:	1141                	addi	sp,sp,-16
    80000458:	e422                	sd	s0,8(sp)
    8000045a:	0800                	addi	s0,sp,16
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
    8000045c:	4789                	li	a5,2
    8000045e:	1007b073          	csrc	sstatus,a5
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000462:	4705                	li	a4,1
    80000464:	87ba                	mv	a5,a4
    80000466:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    8000046a:	2781                	sext.w	a5,a5
    8000046c:	ffe5                	bnez	a5,80000464 <acquire+0xe>
        ;
    __sync_synchronize();
    8000046e:	0ff0000f          	fence
}
    80000472:	6422                	ld	s0,8(sp)
    80000474:	0141                	addi	sp,sp,16
    80000476:	8082                	ret

0000000080000478 <release>:

// 放锁，然后开中断
void release(struct spinlock *lk)
{
    80000478:	1141                	addi	sp,sp,-16
    8000047a:	e422                	sd	s0,8(sp)
    8000047c:	0800                	addi	s0,sp,16
    __sync_synchronize();
    8000047e:	0ff0000f          	fence
    __sync_lock_release(&lk->locked);
    80000482:	0f50000f          	fence	iorw,ow
    80000486:	0805202f          	amoswap.w	zero,zero,(a0)
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
    8000048a:	4789                	li	a5,2
    8000048c:	1007a073          	csrs	sstatus,a5
    intr_on();
}
    80000490:	6422                	ld	s0,8(sp)
    80000492:	0141                	addi	sp,sp,16
    80000494:	8082                	ret
