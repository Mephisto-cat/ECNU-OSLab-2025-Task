
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
    8000002c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <kernel_pgdir+0xffffffff7fff57c7>
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
#include "riscv.h"
#include "uart.h"
#include "vm.h"

void main(void)
{
    80000070:	7179                	addi	sp,sp,-48
    80000072:	f022                	sd	s0,32(sp)
    80000074:	f406                	sd	ra,40(sp)
    80000076:	ec26                	sd	s1,24(sp)
    80000078:	e84a                	sd	s2,16(sp)
    8000007a:	e44e                	sd	s3,8(sp)
    8000007c:	1800                	addi	s0,sp,48
    uint64 hartid;
    void *p1, *p2, *p3;

    uartinit();
    8000007e:	00000097          	auipc	ra,0x0
    80000082:	15e080e7          	jalr	350(ra) # 800001dc <uartinit>
    asm volatile("mv %0, tp" : "=r"(x));
    80000086:	8912                	mv	s2,tp
    hartid = r_tp();

    printf("\n");
    80000088:	00001517          	auipc	a0,0x1
    8000008c:	86050513          	addi	a0,a0,-1952 # 800008e8 <kvminithart+0xe6>
    80000090:	00000097          	auipc	ra,0x0
    80000094:	234080e7          	jalr	564(ra) # 800002c4 <printf>
    printf("Lab2 kernel entered main() on hart %d\n", (int)hartid);
    80000098:	0009049b          	sext.w	s1,s2
    8000009c:	85a6                	mv	a1,s1
    8000009e:	00000517          	auipc	a0,0x0
    800000a2:	79250513          	addi	a0,a0,1938 # 80000830 <kvminithart+0x2e>
    800000a6:	00000097          	auipc	ra,0x0
    800000aa:	21e080e7          	jalr	542(ra) # 800002c4 <printf>

    /* hart 0 does physical memory init and kernel page table */
    if (hartid == 0) {
    800000ae:	0c090363          	beqz	s2,80000174 <main+0x104>
    800000b2:	00009717          	auipc	a4,0x9
    800000b6:	f7e70713          	addi	a4,a4,-130 # 80009030 <kvminit_done>
        printf("[hart %d] kvminit: kernel page table at %p\n",
               (int)hartid, kernel_pgdir);
    }

    /* other harts spin until hart 0 finishes kvminit */
    while (!kvminit_done)
    800000ba:	431c                	lw	a5,0(a4)
    800000bc:	dffd                	beqz	a5,800000ba <main+0x4a>
        ;

    /* each hart enables the kernel page table */
    kvminithart();
    800000be:	00000097          	auipc	ra,0x0
    800000c2:	744080e7          	jalr	1860(ra) # 80000802 <kvminithart>
}

static inline uint64 r_satp(void)
{
    uint64 x;
    asm volatile("csrr %0, satp" : "=r"(x));
    800000c6:	18002673          	csrr	a2,satp
    printf("[hart %d] kvminithart: satp = %p, paging enabled\n",
    800000ca:	00000517          	auipc	a0,0x0
    800000ce:	7ee50513          	addi	a0,a0,2030 # 800008b8 <kvminithart+0xb6>
    800000d2:	85a6                	mv	a1,s1
    800000d4:	00000097          	auipc	ra,0x0
    800000d8:	1f0080e7          	jalr	496(ra) # 800002c4 <printf>
           (int)hartid, (void *)r_satp());

    /* test physical page allocation and deallocation */
    p1 = kalloc();
    800000dc:	00000097          	auipc	ra,0x0
    800000e0:	52e080e7          	jalr	1326(ra) # 8000060a <kalloc>
    800000e4:	892a                	mv	s2,a0
    p2 = kalloc();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	524080e7          	jalr	1316(ra) # 8000060a <kalloc>
    printf("[hart %d] allocated  p1=%p p2=%p\n", (int)hartid, p1, p2);
    800000ee:	86aa                	mv	a3,a0
    800000f0:	864a                	mv	a2,s2
    800000f2:	85a6                	mv	a1,s1
    p2 = kalloc();
    800000f4:	89aa                	mv	s3,a0
    printf("[hart %d] allocated  p1=%p p2=%p\n", (int)hartid, p1, p2);
    800000f6:	00000517          	auipc	a0,0x0
    800000fa:	7fa50513          	addi	a0,a0,2042 # 800008f0 <kvminithart+0xee>
    800000fe:	00000097          	auipc	ra,0x0
    80000102:	1c6080e7          	jalr	454(ra) # 800002c4 <printf>

    kfree(p1);
    80000106:	854a                	mv	a0,s2
    80000108:	00000097          	auipc	ra,0x0
    8000010c:	56c080e7          	jalr	1388(ra) # 80000674 <kfree>
    kfree(p2);
    80000110:	854e                	mv	a0,s3
    80000112:	00000097          	auipc	ra,0x0
    80000116:	562080e7          	jalr	1378(ra) # 80000674 <kfree>
    printf("[hart %d] freed      p1=%p p2=%p\n", (int)hartid, p1, p2);
    8000011a:	86ce                	mv	a3,s3
    8000011c:	864a                	mv	a2,s2
    8000011e:	85a6                	mv	a1,s1
    80000120:	00000517          	auipc	a0,0x0
    80000124:	7f850513          	addi	a0,a0,2040 # 80000918 <kvminithart+0x116>
    80000128:	00000097          	auipc	ra,0x0
    8000012c:	19c080e7          	jalr	412(ra) # 800002c4 <printf>

    p3 = kalloc();
    80000130:	00000097          	auipc	ra,0x0
    80000134:	4da080e7          	jalr	1242(ra) # 8000060a <kalloc>
    printf("[hart %d] re-alloc'd p3=%p\n", (int)hartid, p3);
    80000138:	862a                	mv	a2,a0
    8000013a:	85a6                	mv	a1,s1
    p3 = kalloc();
    8000013c:	892a                	mv	s2,a0
    printf("[hart %d] re-alloc'd p3=%p\n", (int)hartid, p3);
    8000013e:	00001517          	auipc	a0,0x1
    80000142:	80250513          	addi	a0,a0,-2046 # 80000940 <kvminithart+0x13e>
    80000146:	00000097          	auipc	ra,0x0
    8000014a:	17e080e7          	jalr	382(ra) # 800002c4 <printf>
    kfree(p3);
    8000014e:	854a                	mv	a0,s2
    80000150:	00000097          	auipc	ra,0x0
    80000154:	524080e7          	jalr	1316(ra) # 80000674 <kfree>

    printf("[hart %d] Lab2 memory management tests done\n", (int)hartid);
    80000158:	85a6                	mv	a1,s1
    8000015a:	00001517          	auipc	a0,0x1
    8000015e:	80650513          	addi	a0,a0,-2042 # 80000960 <kvminithart+0x15e>
    80000162:	00000097          	auipc	ra,0x0
    80000166:	162080e7          	jalr	354(ra) # 800002c4 <printf>
    asm volatile("wfi");
    8000016a:	10500073          	wfi
    8000016e:	10500073          	wfi
    80000172:	bfe5                	j	8000016a <main+0xfa>
        kinit();
    80000174:	00000097          	auipc	ra,0x0
    80000178:	3f6080e7          	jalr	1014(ra) # 8000056a <kinit>
        printf("[hart %d] kinit: free list built from %p to %p\n",
    8000017c:	4605                	li	a2,1
    8000017e:	46c5                	li	a3,17
    80000180:	067e                	slli	a2,a2,0x1f
    80000182:	4581                	li	a1,0
    80000184:	00000517          	auipc	a0,0x0
    80000188:	6d450513          	addi	a0,a0,1748 # 80000858 <kvminithart+0x56>
    8000018c:	06ee                	slli	a3,a3,0x1b
    8000018e:	00000097          	auipc	ra,0x0
    80000192:	136080e7          	jalr	310(ra) # 800002c4 <printf>
        kvminit();
    80000196:	00000097          	auipc	ra,0x0
    8000019a:	60c080e7          	jalr	1548(ra) # 800007a2 <kvminit>
        printf("[hart %d] kvminit: kernel page table at %p\n",
    8000019e:	00009617          	auipc	a2,0x9
    800001a2:	e9a63603          	ld	a2,-358(a2) # 80009038 <kernel_pgdir>
    800001a6:	4581                	li	a1,0
    800001a8:	00000517          	auipc	a0,0x0
    800001ac:	6e050513          	addi	a0,a0,1760 # 80000888 <kvminithart+0x86>
    800001b0:	00000097          	auipc	ra,0x0
    800001b4:	114080e7          	jalr	276(ra) # 800002c4 <printf>
    800001b8:	bded                	j	800000b2 <main+0x42>

00000000800001ba <uartputc_sync>:

// volatile — 硬件可能随时改，每次必须真读
static volatile uint8 *const uart = (volatile uint8 *)UART0;

void uartputc_sync(int c)
{
    800001ba:	1141                	addi	sp,sp,-16
    800001bc:	e422                	sd	s0,8(sp)
    800001be:	0800                	addi	s0,sp,16
    while ((uart[LSR] & LSR_TX_IDLE) == 0)
    800001c0:	10000737          	lui	a4,0x10000
    800001c4:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800001c8:	0207f793          	andi	a5,a5,32
    800001cc:	dfe5                	beqz	a5,800001c4 <uartputc_sync+0xa>
        ;
    uart[THR] = (uint8)c;
    800001ce:	0ff57513          	zext.b	a0,a0
    800001d2:	00a70023          	sb	a0,0(a4)
}
    800001d6:	6422                	ld	s0,8(sp)
    800001d8:	0141                	addi	sp,sp,16
    800001da:	8082                	ret

00000000800001dc <uartinit>:

void uartinit(void)
{
    800001dc:	1141                	addi	sp,sp,-16
    800001de:	e422                	sd	s0,8(sp)
    800001e0:	0800                	addi	s0,sp,16
    // 关中断，初始化期间寄存器不稳定
    uart[IER] = 0x00;
    800001e2:	100007b7          	lui	a5,0x10000
    800001e6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

    // 设波特率：开 DLAB，写分频器，关 DLAB
    uart[LCR] = LCR_BAUD_LATCH;
    800001ea:	f8000713          	li	a4,-128
    800001ee:	00e781a3          	sb	a4,3(a5)
    uart[0]   = 0x03;
    800001f2:	470d                	li	a4,3
    800001f4:	00e78023          	sb	a4,0(a5)
    uart[1]   = 0x00;
    800001f8:	000780a3          	sb	zero,1(a5)

    // 8 数据位，无校验，1 停止位
    uart[LCR] = LCR_EIGHT_BITS;
    800001fc:	00e781a3          	sb	a4,3(a5)

    // 开 FIFO 并清空
    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;
    80000200:	469d                	li	a3,7
    80000202:	00d78123          	sb	a3,2(a5)

    // 开收发
    uart[IER] = IER_TX_ENABLE | IER_RX_ENABLE;
    80000206:	00e780a3          	sb	a4,1(a5)
}
    8000020a:	6422                	ld	s0,8(sp)
    8000020c:	0141                	addi	sp,sp,16
    8000020e:	8082                	ret

0000000080000210 <printint>:
        uartputc_sync('\r');    // 串口需要 \r\n
    uartputc_sync(c);
}

static void printint(int64 xx, int base, int sign)
{
    80000210:	715d                	addi	sp,sp,-80
    80000212:	e0a2                	sd	s0,64(sp)
    80000214:	e486                	sd	ra,72(sp)
    80000216:	fc26                	sd	s1,56(sp)
    80000218:	f84a                	sd	s2,48(sp)
    8000021a:	f44e                	sd	s3,40(sp)
    8000021c:	f052                	sd	s4,32(sp)
    8000021e:	0880                	addi	s0,sp,80
    char buf[32];
    int i;
    uint64 x;

    if (sign && xx < 0)
    80000220:	c609                	beqz	a2,8000022a <printint+0x1a>
        x = (uint64)(-xx);
    80000222:	40a00733          	neg	a4,a0
    if (sign && xx < 0)
    80000226:	00054363          	bltz	a0,8000022c <printint+0x1c>
    else
        x = (uint64)xx;
    8000022a:	872a                	mv	a4,a0

    i = 0;
    do {
        buf[i++] = digits[x % base];
    8000022c:	fb040693          	addi	a3,s0,-80
    80000230:	4801                	li	a6,0
    80000232:	00000317          	auipc	t1,0x0
    80000236:	7c630313          	addi	t1,t1,1990 # 800009f8 <digits>
    8000023a:	02b777b3          	remu	a5,a4,a1
        x /= base;
    } while (x != 0);
    8000023e:	0685                	addi	a3,a3,1
    80000240:	88ba                	mv	a7,a4
    80000242:	84c2                	mv	s1,a6
        buf[i++] = digits[x % base];
    80000244:	2805                	addiw	a6,a6,1
    80000246:	979a                	add	a5,a5,t1
    80000248:	0007c783          	lbu	a5,0(a5)
        x /= base;
    8000024c:	02b75733          	divu	a4,a4,a1
        buf[i++] = digits[x % base];
    80000250:	fef68fa3          	sb	a5,-1(a3)
    } while (x != 0);
    80000254:	feb8f3e3          	bgeu	a7,a1,8000023a <printint+0x2a>

    if (sign && xx < 0)
    80000258:	c219                	beqz	a2,8000025e <printint+0x4e>
    8000025a:	04054a63          	bltz	a0,800002ae <printint+0x9e>
        buf[i++] = '-';

    while (--i >= 0)
    8000025e:	fb040713          	addi	a4,s0,-80
    80000262:	94ba                	add	s1,s1,a4
    80000264:	89ba                	mv	s3,a4
    if (c == '\n')
    80000266:	4a29                	li	s4,10
    80000268:	a819                	j	8000027e <printint+0x6e>
    uartputc_sync(c);
    8000026a:	854a                	mv	a0,s2
    8000026c:	00000097          	auipc	ra,0x0
    80000270:	f4e080e7          	jalr	-178(ra) # 800001ba <uartputc_sync>
    while (--i >= 0)
    80000274:	02998563          	beq	s3,s1,8000029e <printint+0x8e>
        putc(buf[i]);
    80000278:	fff4c783          	lbu	a5,-1(s1)
    8000027c:	14fd                	addi	s1,s1,-1
    8000027e:	0007891b          	sext.w	s2,a5
    if (c == '\n')
    80000282:	ff4794e3          	bne	a5,s4,8000026a <printint+0x5a>
        uartputc_sync('\r');    // 串口需要 \r\n
    80000286:	4535                	li	a0,13
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	f32080e7          	jalr	-206(ra) # 800001ba <uartputc_sync>
    uartputc_sync(c);
    80000290:	854a                	mv	a0,s2
    80000292:	00000097          	auipc	ra,0x0
    80000296:	f28080e7          	jalr	-216(ra) # 800001ba <uartputc_sync>
    while (--i >= 0)
    8000029a:	fc999fe3          	bne	s3,s1,80000278 <printint+0x68>
}
    8000029e:	60a6                	ld	ra,72(sp)
    800002a0:	6406                	ld	s0,64(sp)
    800002a2:	74e2                	ld	s1,56(sp)
    800002a4:	7942                	ld	s2,48(sp)
    800002a6:	79a2                	ld	s3,40(sp)
    800002a8:	7a02                	ld	s4,32(sp)
    800002aa:	6161                	addi	sp,sp,80
    800002ac:	8082                	ret
        buf[i++] = '-';
    800002ae:	fd080793          	addi	a5,a6,-48
    800002b2:	97a2                	add	a5,a5,s0
    800002b4:	02d00713          	li	a4,45
    800002b8:	fee78023          	sb	a4,-32(a5)
        buf[i++] = digits[x % base];
    800002bc:	84c2                	mv	s1,a6
        buf[i++] = '-';
    800002be:	02d00793          	li	a5,45
    800002c2:	bf71                	j	8000025e <printint+0x4e>

00000000800002c4 <printf>:
    }
}

// 支持 %d %u %x %p %s %c %%
void printf(const char *fmt, ...)
{
    800002c4:	7171                	addi	sp,sp,-176
    800002c6:	f0a2                	sd	s0,96(sp)
    800002c8:	eca6                	sd	s1,88(sp)
    800002ca:	1880                	addi	s0,sp,112
    800002cc:	ec66                	sd	s9,24(sp)
    800002ce:	f486                	sd	ra,104(sp)
    800002d0:	e8ca                	sd	s2,80(sp)
    800002d2:	e4ce                	sd	s3,72(sp)
    800002d4:	e0d2                	sd	s4,64(sp)
    800002d6:	fc56                	sd	s5,56(sp)
    800002d8:	f85a                	sd	s6,48(sp)
    800002da:	f45e                	sd	s7,40(sp)
    800002dc:	f062                	sd	s8,32(sp)
    800002de:	e86a                	sd	s10,16(sp)
    int c;
    const char *s;
    va_list ap;

    if (!pr_lock_inited) {
    800002e0:	00009497          	auipc	s1,0x9
    800002e4:	d4848493          	addi	s1,s1,-696 # 80009028 <pr_lock_inited>
    800002e8:	0004a303          	lw	t1,0(s1)
{
    800002ec:	e40c                	sd	a1,8(s0)
    800002ee:	e810                	sd	a2,16(s0)
    800002f0:	ec14                	sd	a3,24(s0)
    800002f2:	f018                	sd	a4,32(s0)
    800002f4:	f41c                	sd	a5,40(s0)
    800002f6:	03043823          	sd	a6,48(s0)
    800002fa:	03143c23          	sd	a7,56(s0)
    800002fe:	8caa                	mv	s9,a0
    if (!pr_lock_inited) {
    80000300:	1e030663          	beqz	t1,800004ec <printf+0x228>
        initlock(&pr_lock, "printf");
        pr_lock_inited = 1;
    }

    acquire(&pr_lock);
    80000304:	00009517          	auipc	a0,0x9
    80000308:	cfc50513          	addi	a0,a0,-772 # 80009000 <pr_lock>
    8000030c:	00000097          	auipc	ra,0x0
    80000310:	21e080e7          	jalr	542(ra) # 8000052a <acquire>

    va_start(ap, fmt);
    for (; (c = *fmt) != 0; fmt++) {
    80000314:	000ccc03          	lbu	s8,0(s9)
    va_start(ap, fmt);
    80000318:	00840793          	addi	a5,s0,8
    8000031c:	f8f43c23          	sd	a5,-104(s0)
    for (; (c = *fmt) != 0; fmt++) {
    80000320:	060c0863          	beqz	s8,80000390 <printf+0xcc>
        if (c != '%') {
    80000324:	02500993          	li	s3,37

        fmt++;
        if (*fmt == 0)
            break;

        switch (*fmt) {
    80000328:	4bd5                	li	s7,21
    if (c == '\n')
    8000032a:	4929                	li	s2,10
        switch (*fmt) {
    8000032c:	00000b17          	auipc	s6,0x0
    80000330:	674b0b13          	addi	s6,s6,1652 # 800009a0 <kvminithart+0x19e>
    80000334:	00000a97          	auipc	s5,0x0
    80000338:	6c4a8a93          	addi	s5,s5,1732 # 800009f8 <digits>
    for (i = 0; i < 16; i++) {
    8000033c:	5a71                	li	s4,-4
        fmt++;
    8000033e:	001c8493          	addi	s1,s9,1
        if (c != '%') {
    80000342:	173c1f63          	bne	s8,s3,800004c0 <printf+0x1fc>
        if (*fmt == 0)
    80000346:	001cc783          	lbu	a5,1(s9)
    8000034a:	c3b9                	beqz	a5,80000390 <printf+0xcc>
        switch (*fmt) {
    8000034c:	19378363          	beq	a5,s3,800004d2 <printf+0x20e>
    80000350:	f9d7879b          	addiw	a5,a5,-99
    80000354:	0ff7f793          	zext.b	a5,a5
    80000358:	00fbe763          	bltu	s7,a5,80000366 <printf+0xa2>
    8000035c:	078a                	slli	a5,a5,0x2
    8000035e:	97da                	add	a5,a5,s6
    80000360:	439c                	lw	a5,0(a5)
    80000362:	97da                	add	a5,a5,s6
    80000364:	8782                	jr	a5
    uartputc_sync(c);
    80000366:	02500513          	li	a0,37
    8000036a:	00000097          	auipc	ra,0x0
    8000036e:	e50080e7          	jalr	-432(ra) # 800001ba <uartputc_sync>
        case '%':
            putc('%');
            break;
        default:
            putc('%');
            putc(*fmt);
    80000372:	001ccc03          	lbu	s8,1(s9)
    if (c == '\n')
    80000376:	132c0f63          	beq	s8,s2,800004b4 <printf+0x1f0>
    uartputc_sync(c);
    8000037a:	8562                	mv	a0,s8
    8000037c:	00000097          	auipc	ra,0x0
    80000380:	e3e080e7          	jalr	-450(ra) # 800001ba <uartputc_sync>
    for (; (c = *fmt) != 0; fmt++) {
    80000384:	0014cc03          	lbu	s8,1(s1)
    80000388:	00148c93          	addi	s9,s1,1
    8000038c:	fa0c19e3          	bnez	s8,8000033e <printf+0x7a>
            break;
        }
    }
    va_end(ap);

    release(&pr_lock);
    80000390:	00009517          	auipc	a0,0x9
    80000394:	c7050513          	addi	a0,a0,-912 # 80009000 <pr_lock>
    80000398:	00000097          	auipc	ra,0x0
    8000039c:	1b4080e7          	jalr	436(ra) # 8000054c <release>
}
    800003a0:	70a6                	ld	ra,104(sp)
    800003a2:	7406                	ld	s0,96(sp)
    800003a4:	64e6                	ld	s1,88(sp)
    800003a6:	6946                	ld	s2,80(sp)
    800003a8:	69a6                	ld	s3,72(sp)
    800003aa:	6a06                	ld	s4,64(sp)
    800003ac:	7ae2                	ld	s5,56(sp)
    800003ae:	7b42                	ld	s6,48(sp)
    800003b0:	7ba2                	ld	s7,40(sp)
    800003b2:	7c02                	ld	s8,32(sp)
    800003b4:	6ce2                	ld	s9,24(sp)
    800003b6:	6d42                	ld	s10,16(sp)
    800003b8:	614d                	addi	sp,sp,176
    800003ba:	8082                	ret
            printint(va_arg(ap, unsigned int), 16, 0);
    800003bc:	f9843783          	ld	a5,-104(s0)
    800003c0:	4601                	li	a2,0
    800003c2:	45c1                	li	a1,16
    800003c4:	0007e503          	lwu	a0,0(a5)
    800003c8:	07a1                	addi	a5,a5,8
    800003ca:	f8f43c23          	sd	a5,-104(s0)
    800003ce:	00000097          	auipc	ra,0x0
    800003d2:	e42080e7          	jalr	-446(ra) # 80000210 <printint>
            break;
    800003d6:	b77d                	j	80000384 <printf+0xc0>
            printint(va_arg(ap, unsigned int), 10, 0);
    800003d8:	f9843783          	ld	a5,-104(s0)
    800003dc:	4601                	li	a2,0
    800003de:	45a9                	li	a1,10
    800003e0:	0007e503          	lwu	a0,0(a5)
    800003e4:	07a1                	addi	a5,a5,8
    800003e6:	f8f43c23          	sd	a5,-104(s0)
    800003ea:	00000097          	auipc	ra,0x0
    800003ee:	e26080e7          	jalr	-474(ra) # 80000210 <printint>
            break;
    800003f2:	bf49                	j	80000384 <printf+0xc0>
            s = va_arg(ap, const char *);
    800003f4:	f9843783          	ld	a5,-104(s0)
    800003f8:	0007bc03          	ld	s8,0(a5)
    800003fc:	07a1                	addi	a5,a5,8
    800003fe:	f8f43c23          	sd	a5,-104(s0)
            if (s == 0)
    80000402:	000c1863          	bnez	s8,80000412 <printf+0x14e>
    80000406:	a211                	j	8000050a <printf+0x246>
    uartputc_sync(c);
    80000408:	8566                	mv	a0,s9
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	db0080e7          	jalr	-592(ra) # 800001ba <uartputc_sync>
            while (*s)
    80000412:	000c4783          	lbu	a5,0(s8)
    80000416:	d7bd                	beqz	a5,80000384 <printf+0xc0>
                putc(*s++);
    80000418:	0c05                	addi	s8,s8,1
    8000041a:	00078c9b          	sext.w	s9,a5
    if (c == '\n')
    8000041e:	ff2795e3          	bne	a5,s2,80000408 <printf+0x144>
        uartputc_sync('\r');    // 串口需要 \r\n
    80000422:	4535                	li	a0,13
    80000424:	00000097          	auipc	ra,0x0
    80000428:	d96080e7          	jalr	-618(ra) # 800001ba <uartputc_sync>
    8000042c:	bff1                	j	80000408 <printf+0x144>
            printptr((uint64)va_arg(ap, void *));
    8000042e:	f9843783          	ld	a5,-104(s0)
    uartputc_sync(c);
    80000432:	03000513          	li	a0,48
    80000436:	03c00c93          	li	s9,60
            printptr((uint64)va_arg(ap, void *));
    8000043a:	00878713          	addi	a4,a5,8
    8000043e:	0007bc03          	ld	s8,0(a5)
    80000442:	f8e43c23          	sd	a4,-104(s0)
    uartputc_sync(c);
    80000446:	00000097          	auipc	ra,0x0
    8000044a:	d74080e7          	jalr	-652(ra) # 800001ba <uartputc_sync>
    8000044e:	07800513          	li	a0,120
    80000452:	00000097          	auipc	ra,0x0
    80000456:	d68080e7          	jalr	-664(ra) # 800001ba <uartputc_sync>
    for (i = 0; i < 16; i++) {
    8000045a:	a809                	j	8000046c <printf+0x1a8>
    8000045c:	3cf1                	addiw	s9,s9,-4
    uartputc_sync(c);
    8000045e:	856a                	mv	a0,s10
    80000460:	00000097          	auipc	ra,0x0
    80000464:	d5a080e7          	jalr	-678(ra) # 800001ba <uartputc_sync>
    for (i = 0; i < 16; i++) {
    80000468:	f14c8ee3          	beq	s9,s4,80000384 <printf+0xc0>
        putc(digits[(x >> shift) & 0xf]);
    8000046c:	019c57b3          	srl	a5,s8,s9
    80000470:	8bbd                	andi	a5,a5,15
    80000472:	97d6                	add	a5,a5,s5
    80000474:	0007cd03          	lbu	s10,0(a5)
    if (c == '\n')
    80000478:	ff2d12e3          	bne	s10,s2,8000045c <printf+0x198>
        uartputc_sync('\r');    // 串口需要 \r\n
    8000047c:	4535                	li	a0,13
    8000047e:	00000097          	auipc	ra,0x0
    80000482:	d3c080e7          	jalr	-708(ra) # 800001ba <uartputc_sync>
    80000486:	bfd9                	j	8000045c <printf+0x198>
            printint(va_arg(ap, int), 10, 1);
    80000488:	f9843783          	ld	a5,-104(s0)
    8000048c:	4605                	li	a2,1
    8000048e:	45a9                	li	a1,10
    80000490:	4388                	lw	a0,0(a5)
    80000492:	07a1                	addi	a5,a5,8
    80000494:	f8f43c23          	sd	a5,-104(s0)
    80000498:	00000097          	auipc	ra,0x0
    8000049c:	d78080e7          	jalr	-648(ra) # 80000210 <printint>
            break;
    800004a0:	b5d5                	j	80000384 <printf+0xc0>
            putc(va_arg(ap, int));
    800004a2:	f9843783          	ld	a5,-104(s0)
    800004a6:	0007ac03          	lw	s8,0(a5)
    800004aa:	07a1                	addi	a5,a5,8
    800004ac:	f8f43c23          	sd	a5,-104(s0)
    if (c == '\n')
    800004b0:	ed2c15e3          	bne	s8,s2,8000037a <printf+0xb6>
        uartputc_sync('\r');    // 串口需要 \r\n
    800004b4:	4535                	li	a0,13
    800004b6:	00000097          	auipc	ra,0x0
    800004ba:	d04080e7          	jalr	-764(ra) # 800001ba <uartputc_sync>
    800004be:	bd75                	j	8000037a <printf+0xb6>
    if (c == '\n')
    800004c0:	032c0063          	beq	s8,s2,800004e0 <printf+0x21c>
    uartputc_sync(c);
    800004c4:	8562                	mv	a0,s8
    800004c6:	00000097          	auipc	ra,0x0
    800004ca:	cf4080e7          	jalr	-780(ra) # 800001ba <uartputc_sync>
            continue;
    800004ce:	84e6                	mv	s1,s9
    800004d0:	bd55                	j	80000384 <printf+0xc0>
    uartputc_sync(c);
    800004d2:	02500513          	li	a0,37
    800004d6:	00000097          	auipc	ra,0x0
    800004da:	ce4080e7          	jalr	-796(ra) # 800001ba <uartputc_sync>
}
    800004de:	b55d                	j	80000384 <printf+0xc0>
        uartputc_sync('\r');    // 串口需要 \r\n
    800004e0:	4535                	li	a0,13
    800004e2:	00000097          	auipc	ra,0x0
    800004e6:	cd8080e7          	jalr	-808(ra) # 800001ba <uartputc_sync>
    800004ea:	bfe9                	j	800004c4 <printf+0x200>
        initlock(&pr_lock, "printf");
    800004ec:	00000597          	auipc	a1,0x0
    800004f0:	4ac58593          	addi	a1,a1,1196 # 80000998 <kvminithart+0x196>
    800004f4:	00009517          	auipc	a0,0x9
    800004f8:	b0c50513          	addi	a0,a0,-1268 # 80009000 <pr_lock>
    800004fc:	00000097          	auipc	ra,0x0
    80000500:	01c080e7          	jalr	28(ra) # 80000518 <initlock>
        pr_lock_inited = 1;
    80000504:	4785                	li	a5,1
    80000506:	c09c                	sw	a5,0(s1)
    80000508:	bbf5                	j	80000304 <printf+0x40>
                s = "(null)";
    8000050a:	00000c17          	auipc	s8,0x0
    8000050e:	486c0c13          	addi	s8,s8,1158 # 80000990 <kvminithart+0x18e>
            while (*s)
    80000512:	02800793          	li	a5,40
    80000516:	b709                	j	80000418 <printf+0x154>

0000000080000518 <initlock>:
#include "riscv.h"
#include "spinlock.h"

void initlock(struct spinlock *lk, const char *name)
{
    80000518:	1141                	addi	sp,sp,-16
    8000051a:	e422                	sd	s0,8(sp)
    8000051c:	0800                	addi	s0,sp,16
    lk->locked = 0;
    lk->name = name;
}
    8000051e:	6422                	ld	s0,8(sp)
    lk->locked = 0;
    80000520:	00052023          	sw	zero,0(a0)
    lk->name = name;
    80000524:	e50c                	sd	a1,8(a0)
}
    80000526:	0141                	addi	sp,sp,16
    80000528:	8082                	ret

000000008000052a <acquire>:

// 关中断后原子抢锁，抢不到就自旋
void acquire(struct spinlock *lk)
{
    8000052a:	1141                	addi	sp,sp,-16
    8000052c:	e422                	sd	s0,8(sp)
    8000052e:	0800                	addi	s0,sp,16
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
    80000530:	4789                	li	a5,2
    80000532:	1007b073          	csrc	sstatus,a5
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000536:	4705                	li	a4,1
    80000538:	87ba                	mv	a5,a4
    8000053a:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    8000053e:	2781                	sext.w	a5,a5
    80000540:	ffe5                	bnez	a5,80000538 <acquire+0xe>
        ;
    __sync_synchronize();
    80000542:	0ff0000f          	fence
}
    80000546:	6422                	ld	s0,8(sp)
    80000548:	0141                	addi	sp,sp,16
    8000054a:	8082                	ret

000000008000054c <release>:

// 放锁，然后开中断
void release(struct spinlock *lk)
{
    8000054c:	1141                	addi	sp,sp,-16
    8000054e:	e422                	sd	s0,8(sp)
    80000550:	0800                	addi	s0,sp,16
    __sync_synchronize();
    80000552:	0ff0000f          	fence
    __sync_lock_release(&lk->locked);
    80000556:	0f50000f          	fence	iorw,ow
    8000055a:	0805202f          	amoswap.w	zero,zero,(a0)
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
    8000055e:	4789                	li	a5,2
    80000560:	1007a073          	csrs	sstatus,a5
    intr_on();
}
    80000564:	6422                	ld	s0,8(sp)
    80000566:	0141                	addi	sp,sp,16
    80000568:	8082                	ret

000000008000056a <kinit>:
} kmem;

extern char end;  /* kernel.ld 定义，内核 BSS 之后的首地址 */

void kinit(void)
{
    8000056a:	7139                	addi	sp,sp,-64
    8000056c:	f822                	sd	s0,48(sp)
    8000056e:	f426                	sd	s1,40(sp)
    80000570:	ec4e                	sd	s3,24(sp)
    80000572:	fc06                	sd	ra,56(sp)
    80000574:	f04a                	sd	s2,32(sp)
    80000576:	e852                	sd	s4,16(sp)
    80000578:	e456                	sd	s5,8(sp)
    8000057a:	0080                	addi	s0,sp,64
    char *p;
    initlock(&kmem.lock, "kmem");
    8000057c:	00000597          	auipc	a1,0x0
    80000580:	49458593          	addi	a1,a1,1172 # 80000a10 <digits+0x18>
    80000584:	00009517          	auipc	a0,0x9
    80000588:	a8c50513          	addi	a0,a0,-1396 # 80009010 <kmem>
    8000058c:	00000097          	auipc	ra,0x0
    80000590:	f8c080e7          	jalr	-116(ra) # 80000518 <initlock>

    p = (char *)PGROUNDUP((uint64)&end);
    80000594:	77fd                	lui	a5,0xfffff
    80000596:	0000a497          	auipc	s1,0xa
    8000059a:	a9148493          	addi	s1,s1,-1391 # 8000a027 <kernel_pgdir+0xfef>
    8000059e:	8cfd                	and	s1,s1,a5
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE)
    800005a0:	49c5                	li	s3,17
    800005a2:	6785                	lui	a5,0x1
    800005a4:	97a6                	add	a5,a5,s1
    800005a6:	09ee                	slli	s3,s3,0x1b
    800005a8:	04f9e863          	bltu	s3,a5,800005f8 <kinit+0x8e>
    800005ac:	00088937          	lui	s2,0x88
    800005b0:	197d                	addi	s2,s2,-1 # 87fff <_entry-0x7ff78001>
    800005b2:	0932                	slli	s2,s2,0xc
    800005b4:	40990933          	sub	s2,s2,s1
    800005b8:	993e                	add	s2,s2,a5
        || (char *)pa < (char *)PGROUNDUP((uint64)&end)
        || (uint64)pa >= PHYSTOP)
        return;

    r = (struct run *)pa;
    acquire(&kmem.lock);
    800005ba:	00009a97          	auipc	s5,0x9
    800005be:	a56a8a93          	addi	s5,s5,-1450 # 80009010 <kmem>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE)
    800005c2:	6a05                	lui	s4,0x1
    acquire(&kmem.lock);
    800005c4:	00009517          	auipc	a0,0x9
    800005c8:	a4c50513          	addi	a0,a0,-1460 # 80009010 <kmem>
        || (uint64)pa >= PHYSTOP)
    800005cc:	0334f363          	bgeu	s1,s3,800005f2 <kinit+0x88>
    acquire(&kmem.lock);
    800005d0:	00000097          	auipc	ra,0x0
    800005d4:	f5a080e7          	jalr	-166(ra) # 8000052a <acquire>
    r->next = kmem.freelist;
    800005d8:	010ab783          	ld	a5,16(s5)
    kmem.freelist = r;
    release(&kmem.lock);
    800005dc:	00009517          	auipc	a0,0x9
    800005e0:	a3450513          	addi	a0,a0,-1484 # 80009010 <kmem>
    r->next = kmem.freelist;
    800005e4:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    800005e6:	009ab823          	sd	s1,16(s5)
    release(&kmem.lock);
    800005ea:	00000097          	auipc	ra,0x0
    800005ee:	f62080e7          	jalr	-158(ra) # 8000054c <release>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE)
    800005f2:	94d2                	add	s1,s1,s4
    800005f4:	fd2498e3          	bne	s1,s2,800005c4 <kinit+0x5a>
}
    800005f8:	70e2                	ld	ra,56(sp)
    800005fa:	7442                	ld	s0,48(sp)
    800005fc:	74a2                	ld	s1,40(sp)
    800005fe:	7902                	ld	s2,32(sp)
    80000600:	69e2                	ld	s3,24(sp)
    80000602:	6a42                	ld	s4,16(sp)
    80000604:	6aa2                	ld	s5,8(sp)
    80000606:	6121                	addi	sp,sp,64
    80000608:	8082                	ret

000000008000060a <kalloc>:
{
    8000060a:	1101                	addi	sp,sp,-32
    8000060c:	e822                	sd	s0,16(sp)
    8000060e:	e426                	sd	s1,8(sp)
    80000610:	e04a                	sd	s2,0(sp)
    80000612:	ec06                	sd	ra,24(sp)
    80000614:	1000                	addi	s0,sp,32
    acquire(&kmem.lock);
    80000616:	00009917          	auipc	s2,0x9
    8000061a:	9fa90913          	addi	s2,s2,-1542 # 80009010 <kmem>
    8000061e:	854a                	mv	a0,s2
    80000620:	00000097          	auipc	ra,0x0
    80000624:	f0a080e7          	jalr	-246(ra) # 8000052a <acquire>
    r = kmem.freelist;
    80000628:	01093483          	ld	s1,16(s2)
    if (r)
    8000062c:	c885                	beqz	s1,8000065c <kalloc+0x52>
        kmem.freelist = r->next;
    8000062e:	609c                	ld	a5,0(s1)
    release(&kmem.lock);
    80000630:	854a                	mv	a0,s2
        kmem.freelist = r->next;
    80000632:	00f93823          	sd	a5,16(s2)
    release(&kmem.lock);
    80000636:	00000097          	auipc	ra,0x0
    8000063a:	f16080e7          	jalr	-234(ra) # 8000054c <release>
        for (i = 0; i < PGSIZE; i++)
    8000063e:	6705                	lui	a4,0x1
    80000640:	87a6                	mv	a5,s1
    80000642:	9726                	add	a4,a4,s1
            v[i] = 0;
    80000644:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
        for (i = 0; i < PGSIZE; i++)
    80000648:	0785                	addi	a5,a5,1
    8000064a:	fef71de3          	bne	a4,a5,80000644 <kalloc+0x3a>
}
    8000064e:	60e2                	ld	ra,24(sp)
    80000650:	6442                	ld	s0,16(sp)
    80000652:	6902                	ld	s2,0(sp)
    80000654:	8526                	mv	a0,s1
    80000656:	64a2                	ld	s1,8(sp)
    80000658:	6105                	addi	sp,sp,32
    8000065a:	8082                	ret
    release(&kmem.lock);
    8000065c:	854a                	mv	a0,s2
    8000065e:	00000097          	auipc	ra,0x0
    80000662:	eee080e7          	jalr	-274(ra) # 8000054c <release>
}
    80000666:	60e2                	ld	ra,24(sp)
    80000668:	6442                	ld	s0,16(sp)
    8000066a:	6902                	ld	s2,0(sp)
    8000066c:	8526                	mv	a0,s1
    8000066e:	64a2                	ld	s1,8(sp)
    80000670:	6105                	addi	sp,sp,32
    80000672:	8082                	ret

0000000080000674 <kfree>:
    if (((uint64)pa % PGSIZE) != 0
    80000674:	03451793          	slli	a5,a0,0x34
    80000678:	e3b5                	bnez	a5,800006dc <kfree+0x68>
{
    8000067a:	1101                	addi	sp,sp,-32
    8000067c:	e822                	sd	s0,16(sp)
    8000067e:	e426                	sd	s1,8(sp)
    80000680:	ec06                	sd	ra,24(sp)
    80000682:	e04a                	sd	s2,0(sp)
    80000684:	1000                	addi	s0,sp,32
        || (char *)pa < (char *)PGROUNDUP((uint64)&end)
    80000686:	0000a797          	auipc	a5,0xa
    8000068a:	9a178793          	addi	a5,a5,-1631 # 8000a027 <kernel_pgdir+0xfef>
    8000068e:	777d                	lui	a4,0xfffff
    80000690:	8ff9                	and	a5,a5,a4
    80000692:	84aa                	mv	s1,a0
    80000694:	02f56e63          	bltu	a0,a5,800006d0 <kfree+0x5c>
        || (uint64)pa >= PHYSTOP)
    80000698:	47c5                	li	a5,17
    8000069a:	07ee                	slli	a5,a5,0x1b
    8000069c:	02f57a63          	bgeu	a0,a5,800006d0 <kfree+0x5c>
    acquire(&kmem.lock);
    800006a0:	00009917          	auipc	s2,0x9
    800006a4:	97090913          	addi	s2,s2,-1680 # 80009010 <kmem>
    800006a8:	854a                	mv	a0,s2
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	e80080e7          	jalr	-384(ra) # 8000052a <acquire>
    r->next = kmem.freelist;
    800006b2:	01093783          	ld	a5,16(s2)
}
    800006b6:	6442                	ld	s0,16(sp)
    800006b8:	60e2                	ld	ra,24(sp)
    r->next = kmem.freelist;
    800006ba:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    800006bc:	00993823          	sd	s1,16(s2)
    release(&kmem.lock);
    800006c0:	854a                	mv	a0,s2
}
    800006c2:	64a2                	ld	s1,8(sp)
    800006c4:	6902                	ld	s2,0(sp)
    800006c6:	6105                	addi	sp,sp,32
    release(&kmem.lock);
    800006c8:	00000317          	auipc	t1,0x0
    800006cc:	e8430067          	jr	-380(t1) # 8000054c <release>
}
    800006d0:	60e2                	ld	ra,24(sp)
    800006d2:	6442                	ld	s0,16(sp)
    800006d4:	64a2                	ld	s1,8(sp)
    800006d6:	6902                	ld	s2,0(sp)
    800006d8:	6105                	addi	sp,sp,32
    800006da:	8082                	ret
    800006dc:	8082                	ret

00000000800006de <kvmmap>:
    return &pgdir[PX(va, 0)];
}

/* Map va→pa in pgdir for sz bytes (identity mapping for kernel) */
void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm)
{
    800006de:	711d                	addi	sp,sp,-96
    800006e0:	e8a2                	sd	s0,80(sp)
    800006e2:	e0ca                	sd	s2,64(sp)
    800006e4:	e862                	sd	s8,16(sp)
    800006e6:	ec86                	sd	ra,88(sp)
    800006e8:	e4a6                	sd	s1,72(sp)
    800006ea:	fc4e                	sd	s3,56(sp)
    800006ec:	f852                	sd	s4,48(sp)
    800006ee:	f456                	sd	s5,40(sp)
    800006f0:	f05a                	sd	s6,32(sp)
    800006f2:	ec5e                	sd	s7,24(sp)
    800006f4:	e466                	sd	s9,8(sp)
    800006f6:	e06a                	sd	s10,0(sp)
    800006f8:	1080                	addi	s0,sp,96
    uint64 a, *pte;

    for (a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    800006fa:	7c7d                	lui	s8,0xfffff
    800006fc:	0185fc33          	and	s8,a1,s8
    80000700:	00d58933          	add	s2,a1,a3
    80000704:	092c7163          	bgeu	s8,s2,80000786 <kvmmap+0xa8>
    80000708:	8a2a                	mv	s4,a0
    8000070a:	8aba                	mv	s5,a4
    8000070c:	418609b3          	sub	s3,a2,s8
    for (level = 2; level >= 1; level--) {
    80000710:	4c85                	li	s9,1
    for (a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    80000712:	6b05                	lui	s6,0x1
    80000714:	a025                	j	8000073c <kvmmap+0x5e>
    return &pgdir[PX(va, 0)];
    80000716:	00cc5793          	srli	a5,s8,0xc
    8000071a:	1ff7f793          	andi	a5,a5,511
    8000071e:	078e                	slli	a5,a5,0x3
    80000720:	953e                	add	a0,a0,a5
        pte = walk(pgdir, a, 1);
        if (pte == 0)
    80000722:	c135                	beqz	a0,80000786 <kvmmap+0xa8>
            return;
        *pte = PA2PTE(pa) | perm | PTE_V;
    80000724:	00cbdb93          	srli	s7,s7,0xc
    80000728:	0baa                	slli	s7,s7,0xa
    8000072a:	015bebb3          	or	s7,s7,s5
    8000072e:	001beb93          	ori	s7,s7,1
    80000732:	01753023          	sd	s7,0(a0)
    for (a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    80000736:	9c5a                	add	s8,s8,s6
    80000738:	052c7763          	bgeu	s8,s2,80000786 <kvmmap+0xa8>
    8000073c:	01898bb3          	add	s7,s3,s8
    80000740:	8552                	mv	a0,s4
    80000742:	4d09                	li	s10,2
    for (level = 2; level >= 1; level--) {
    80000744:	4789                	li	a5,2
        pte = &pgdir[PX(va, level)];
    80000746:	0037949b          	slliw	s1,a5,0x3
    8000074a:	9cbd                	addw	s1,s1,a5
    8000074c:	24b1                	addiw	s1,s1,12
    8000074e:	009c54b3          	srl	s1,s8,s1
    80000752:	1ff4f493          	andi	s1,s1,511
    80000756:	048e                	slli	s1,s1,0x3
    80000758:	94aa                	add	s1,s1,a0
        if (*pte & PTE_V) {
    8000075a:	6088                	ld	a0,0(s1)
    8000075c:	00157793          	andi	a5,a0,1
            pgdir = (uint64 *)PTE2PA(*pte);
    80000760:	8129                	srli	a0,a0,0xa
    80000762:	0532                	slli	a0,a0,0xc
        if (*pte & PTE_V) {
    80000764:	ef81                	bnez	a5,8000077c <kvmmap+0x9e>
            pgdir = (uint64 *)kalloc();
    80000766:	00000097          	auipc	ra,0x0
    8000076a:	ea4080e7          	jalr	-348(ra) # 8000060a <kalloc>
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
    8000076e:	00c55793          	srli	a5,a0,0xc
    80000772:	07aa                	slli	a5,a5,0xa
    80000774:	0017e793          	ori	a5,a5,1
            if (pgdir == 0)
    80000778:	c519                	beqz	a0,80000786 <kvmmap+0xa8>
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
    8000077a:	e09c                	sd	a5,0(s1)
    for (level = 2; level >= 1; level--) {
    8000077c:	4785                	li	a5,1
    8000077e:	f99d0ce3          	beq	s10,s9,80000716 <kvmmap+0x38>
    80000782:	4d05                	li	s10,1
    80000784:	b7c9                	j	80000746 <kvmmap+0x68>
    }
}
    80000786:	60e6                	ld	ra,88(sp)
    80000788:	6446                	ld	s0,80(sp)
    8000078a:	64a6                	ld	s1,72(sp)
    8000078c:	6906                	ld	s2,64(sp)
    8000078e:	79e2                	ld	s3,56(sp)
    80000790:	7a42                	ld	s4,48(sp)
    80000792:	7aa2                	ld	s5,40(sp)
    80000794:	7b02                	ld	s6,32(sp)
    80000796:	6be2                	ld	s7,24(sp)
    80000798:	6c42                	ld	s8,16(sp)
    8000079a:	6ca2                	ld	s9,8(sp)
    8000079c:	6d02                	ld	s10,0(sp)
    8000079e:	6125                	addi	sp,sp,96
    800007a0:	8082                	ret

00000000800007a2 <kvminit>:
 * Create kernel page table with identity mapping covering:
 *   - UART MMIO: 0x10000000
 *   - RAM: 0x80000000 .. 0x88000000
 */
void kvminit(void)
{
    800007a2:	1101                	addi	sp,sp,-32
    800007a4:	e822                	sd	s0,16(sp)
    800007a6:	e426                	sd	s1,8(sp)
    800007a8:	ec06                	sd	ra,24(sp)
    800007aa:	e04a                	sd	s2,0(sp)
    800007ac:	1000                	addi	s0,sp,32
    kernel_pgdir = (uint64 *)kalloc();
    800007ae:	00000097          	auipc	ra,0x0
    800007b2:	e5c080e7          	jalr	-420(ra) # 8000060a <kalloc>
    800007b6:	00009497          	auipc	s1,0x9
    800007ba:	88248493          	addi	s1,s1,-1918 # 80009038 <kernel_pgdir>
    800007be:	e088                	sd	a0,0(s1)
    if (kernel_pgdir == 0)
    800007c0:	c91d                	beqz	a0,800007f6 <kvminit+0x54>
        return;

    kvmmap(kernel_pgdir, UART0, UART0, PGSIZE, PTE_KERN_RW);
    800007c2:	4719                	li	a4,6
    800007c4:	6685                	lui	a3,0x1
    800007c6:	10000637          	lui	a2,0x10000
    800007ca:	100005b7          	lui	a1,0x10000
    800007ce:	00000097          	auipc	ra,0x0
    800007d2:	f10080e7          	jalr	-240(ra) # 800006de <kvmmap>
    kvmmap(kernel_pgdir, KERNBASE, KERNBASE, PHYSTOP - KERNBASE,
    800007d6:	4905                	li	s2,1
    800007d8:	6088                	ld	a0,0(s1)
    800007da:	01f91613          	slli	a2,s2,0x1f
    800007de:	4739                	li	a4,14
    800007e0:	080006b7          	lui	a3,0x8000
    800007e4:	85b2                	mv	a1,a2
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	ef8080e7          	jalr	-264(ra) # 800006de <kvmmap>
           PTE_KERN_RWX);

    kvminit_done = 1;
    800007ee:	00009797          	auipc	a5,0x9
    800007f2:	8527a123          	sw	s2,-1982(a5) # 80009030 <kvminit_done>
}
    800007f6:	60e2                	ld	ra,24(sp)
    800007f8:	6442                	ld	s0,16(sp)
    800007fa:	64a2                	ld	s1,8(sp)
    800007fc:	6902                	ld	s2,0(sp)
    800007fe:	6105                	addi	sp,sp,32
    80000800:	8082                	ret

0000000080000802 <kvminithart>:

/* Enable kernel page table on this hart */
void kvminithart(void)
{
    80000802:	1141                	addi	sp,sp,-16
    80000804:	e422                	sd	s0,8(sp)
    80000806:	0800                	addi	s0,sp,16
    w_satp(MAKE_SATP(kernel_pgdir));
    80000808:	00009797          	auipc	a5,0x9
    8000080c:	8307b783          	ld	a5,-2000(a5) # 80009038 <kernel_pgdir>
    80000810:	577d                	li	a4,-1
    80000812:	177e                	slli	a4,a4,0x3f
    80000814:	83b1                	srli	a5,a5,0xc
    80000816:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    80000818:	18079073          	csrw	satp,a5
    asm volatile("sfence.vma" : : : "memory");
    8000081c:	12000073          	sfence.vma
}
    80000820:	6422                	ld	s0,8(sp)
    80000822:	0141                	addi	sp,sp,16
    80000824:	8082                	ret
