
build/kernel-qemu.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
.section .text
.global _entry

_entry:
    csrr a0, mhartid
    80000000:	f1402573          	csrr	a0,mhartid
    la sp, stacks
    80000004:	00003117          	auipc	sp,0x3
    80000008:	ffc10113          	addi	sp,sp,-4 # 80003000 <stacks>
    li t0, 4096
    8000000c:	6285                	lui	t0,0x1
    addi a0, a0, 1
    8000000e:	0505                	addi	a0,a0,1
    mul a0, a0, t0
    80000010:	02550533          	mul	a0,a0,t0
    add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
    call start
    80000016:	00001097          	auipc	ra,0x1
    8000001a:	8d6080e7          	jalr	-1834(ra) # 800008ec <start>

000000008000001e <main>:
#include "mem/mod.h"
#include "mem/type.h"
#include "lib/mod.h"
#include "arch/method.h"

void main() {
    8000001e:	715d                	addi	sp,sp,-80
    80000020:	e0a2                	sd	s0,64(sp)
    80000022:	e486                	sd	ra,72(sp)
    80000024:	f44e                	sd	s3,40(sp)
    80000026:	0880                	addi	s0,sp,80

#include "arch/type.h"

static inline uint64 r_cpuid(void) {
    uint64 x;
    asm volatile("mv %0, tp" : "=r"(x));
    80000028:	8992                	mv	s3,tp
    int cpuid = r_cpuid();

    uartinit();
    8000002a:	00000097          	auipc	ra,0x0
    8000002e:	4a2080e7          	jalr	1186(ra) # 800004cc <uartinit>
    printf("\n");
    80000032:	00001517          	auipc	a0,0x1
    80000036:	bbe50513          	addi	a0,a0,-1090 # 80000bf0 <kfree+0x68>
    int cpuid = r_cpuid();
    8000003a:	2981                	sext.w	s3,s3
    printf("\n");
    8000003c:	00000097          	auipc	ra,0x0
    80000040:	57e080e7          	jalr	1406(ra) # 800005ba <printf>
    printf("cpu %d is booting\n", cpuid);
    80000044:	85ce                	mv	a1,s3
    80000046:	00001517          	auipc	a0,0x1
    8000004a:	bb250513          	addi	a0,a0,-1102 # 80000bf8 <kfree+0x70>
    8000004e:	00000097          	auipc	ra,0x0
    80000052:	56c080e7          	jalr	1388(ra) # 800005ba <printf>

    if (cpuid == 0) {
    80000056:	3e098463          	beqz	s3,8000043e <main+0x420>
    8000005a:	0000b717          	auipc	a4,0xb
    8000005e:	fae70713          	addi	a4,a4,-82 # 8000b008 <kvminit_done>
        kvminit();
        printf("[cpu %d] kvminit: kernel page table at %p\n",
               cpuid, kernel_pgdir);
    }

    while (!kvminit_done) {}
    80000062:	431c                	lw	a5,0(a4)
    80000064:	dffd                	beqz	a5,80000062 <main+0x44>

    kvminithart();
    80000066:	00001097          	auipc	ra,0x1
    8000006a:	a10080e7          	jalr	-1520(ra) # 80000a76 <kvminithart>
    asm volatile("csrw satp, %0" : : "r"(x));
}

static inline uint64 r_satp() {
    uint64 x;
    asm volatile("csrr %0, satp" : "=r"(x));
    8000006e:	18002673          	csrr	a2,satp
    printf("[cpu %d] kvminithart: satp = %p, paging enabled\n",
    80000072:	00001517          	auipc	a0,0x1
    80000076:	bfe50513          	addi	a0,a0,-1026 # 80000c70 <kfree+0xe8>
    8000007a:	85ce                	mv	a1,s3
    8000007c:	00000097          	auipc	ra,0x0
    80000080:	53e080e7          	jalr	1342(ra) # 800005ba <printf>
           cpuid, (void *)r_satp());

    if (cpuid == 0) {
    80000084:	00098763          	beqz	s3,80000092 <main+0x74>
    asm volatile("wfi");
    80000088:	10500073          	wfi
    8000008c:	10500073          	wfi
        printf("[cpu %d] printf after paging ON proves identity map works\n", cpuid);

        printf("[cpu %d] === ALL TESTS PASSED ===\n", cpuid);
    }

    for (;;) {
    80000090:	bfe5                	j	80000088 <main+0x6a>
        printf("[cpu %d] --- test1: basic alloc/free ---\n", cpuid);
    80000092:	4581                	li	a1,0
    80000094:	00001517          	auipc	a0,0x1
    80000098:	c1450513          	addi	a0,a0,-1004 # 80000ca8 <kfree+0x120>
    8000009c:	fc26                	sd	s1,56(sp)
    8000009e:	f84a                	sd	s2,48(sp)
    800000a0:	f052                	sd	s4,32(sp)
    800000a2:	00000097          	auipc	ra,0x0
    800000a6:	518080e7          	jalr	1304(ra) # 800005ba <printf>
        void *p1 = kalloc();
    800000aa:	00001097          	auipc	ra,0x1
    800000ae:	a96080e7          	jalr	-1386(ra) # 80000b40 <kalloc>
    800000b2:	84aa                	mv	s1,a0
        void *p2 = kalloc();
    800000b4:	00001097          	auipc	ra,0x1
    800000b8:	a8c080e7          	jalr	-1396(ra) # 80000b40 <kalloc>
        printf("[cpu %d] alloc  p1=%p p2=%p\n", cpuid, p1, p2);
    800000bc:	86aa                	mv	a3,a0
    800000be:	8626                	mv	a2,s1
        void *p2 = kalloc();
    800000c0:	892a                	mv	s2,a0
        printf("[cpu %d] alloc  p1=%p p2=%p\n", cpuid, p1, p2);
    800000c2:	4581                	li	a1,0
    800000c4:	00001517          	auipc	a0,0x1
    800000c8:	c1450513          	addi	a0,a0,-1004 # 80000cd8 <kfree+0x150>
    800000cc:	00000097          	auipc	ra,0x0
    800000d0:	4ee080e7          	jalr	1262(ra) # 800005ba <printf>
        printf("[cpu %d] expect: p1!=0, p2!=0, p1!=p2\n", cpuid);
    800000d4:	4581                	li	a1,0
    800000d6:	00001517          	auipc	a0,0x1
    800000da:	c2250513          	addi	a0,a0,-990 # 80000cf8 <kfree+0x170>
    800000de:	00000097          	auipc	ra,0x0
    800000e2:	4dc080e7          	jalr	1244(ra) # 800005ba <printf>
        kfree(p1);
    800000e6:	8526                	mv	a0,s1
    800000e8:	00001097          	auipc	ra,0x1
    800000ec:	aa0080e7          	jalr	-1376(ra) # 80000b88 <kfree>
        kfree(p2);
    800000f0:	854a                	mv	a0,s2
    800000f2:	00001097          	auipc	ra,0x1
    800000f6:	a96080e7          	jalr	-1386(ra) # 80000b88 <kfree>
        printf("[cpu %d] free   p1=%p p2=%p\n", cpuid, p1, p2);
    800000fa:	86ca                	mv	a3,s2
    800000fc:	8626                	mv	a2,s1
    800000fe:	4581                	li	a1,0
    80000100:	00001517          	auipc	a0,0x1
    80000104:	c2050513          	addi	a0,a0,-992 # 80000d20 <kfree+0x198>
    80000108:	00000097          	auipc	ra,0x0
    8000010c:	4b2080e7          	jalr	1202(ra) # 800005ba <printf>
        printf("[cpu %d] --- test2: reuse after free ---\n", cpuid);
    80000110:	4581                	li	a1,0
    80000112:	00001517          	auipc	a0,0x1
    80000116:	c2e50513          	addi	a0,a0,-978 # 80000d40 <kfree+0x1b8>
    8000011a:	00000097          	auipc	ra,0x0
    8000011e:	4a0080e7          	jalr	1184(ra) # 800005ba <printf>
        void *p3 = kalloc();
    80000122:	00001097          	auipc	ra,0x1
    80000126:	a1e080e7          	jalr	-1506(ra) # 80000b40 <kalloc>
        printf("[cpu %d] re-alloc after free: p3=%p\n", cpuid, p3);
    8000012a:	862a                	mv	a2,a0
        void *p3 = kalloc();
    8000012c:	84aa                	mv	s1,a0
        printf("[cpu %d] re-alloc after free: p3=%p\n", cpuid, p3);
    8000012e:	4581                	li	a1,0
    80000130:	00001517          	auipc	a0,0x1
    80000134:	c4050513          	addi	a0,a0,-960 # 80000d70 <kfree+0x1e8>
    80000138:	00000097          	auipc	ra,0x0
    8000013c:	482080e7          	jalr	1154(ra) # 800005ba <printf>
        printf("[cpu %d] expect: p3==p2 (LIFO, last freed first)\n", cpuid);
    80000140:	4581                	li	a1,0
    80000142:	00001517          	auipc	a0,0x1
    80000146:	c5650513          	addi	a0,a0,-938 # 80000d98 <kfree+0x210>
    8000014a:	00000097          	auipc	ra,0x0
    8000014e:	470080e7          	jalr	1136(ra) # 800005ba <printf>
        kfree(p3);
    80000152:	8526                	mv	a0,s1
    80000154:	00001097          	auipc	ra,0x1
    80000158:	a34080e7          	jalr	-1484(ra) # 80000b88 <kfree>
        printf("[cpu %d] --- test3: zero-fill ---\n", cpuid);
    8000015c:	4581                	li	a1,0
    8000015e:	00001517          	auipc	a0,0x1
    80000162:	c7250513          	addi	a0,a0,-910 # 80000dd0 <kfree+0x248>
    80000166:	00000097          	auipc	ra,0x0
    8000016a:	454080e7          	jalr	1108(ra) # 800005ba <printf>
        char *zp = (char *)kalloc();
    8000016e:	00001097          	auipc	ra,0x1
    80000172:	9d2080e7          	jalr	-1582(ra) # 80000b40 <kalloc>
    80000176:	6905                	lui	s2,0x1
    80000178:	8a2a                	mv	s4,a0
        for (int i = 0; i < PGSIZE; i++) {
    8000017a:	84aa                	mv	s1,a0
    8000017c:	992a                	add	s2,s2,a0
        char *zp = (char *)kalloc();
    8000017e:	87aa                	mv	a5,a0
        int nonzero = 0;
    80000180:	4601                	li	a2,0
            if (zp[i] != 0) nonzero++;
    80000182:	0007c703          	lbu	a4,0(a5)
        for (int i = 0; i < PGSIZE; i++) {
    80000186:	0785                	addi	a5,a5,1
            if (zp[i] != 0) nonzero++;
    80000188:	c311                	beqz	a4,8000018c <main+0x16e>
    8000018a:	2605                	addiw	a2,a2,1
        for (int i = 0; i < PGSIZE; i++) {
    8000018c:	fef91be3          	bne	s2,a5,80000182 <main+0x164>
        printf("[cpu %d] zero-fill check: %d/%d bytes non-zero\n",
    80000190:	6685                	lui	a3,0x1
    80000192:	4581                	li	a1,0
    80000194:	00001517          	auipc	a0,0x1
    80000198:	c6450513          	addi	a0,a0,-924 # 80000df8 <kfree+0x270>
    8000019c:	00000097          	auipc	ra,0x0
    800001a0:	41e080e7          	jalr	1054(ra) # 800005ba <printf>
        printf("[cpu %d] expect: 0\n", cpuid);
    800001a4:	4581                	li	a1,0
    800001a6:	00001517          	auipc	a0,0x1
    800001aa:	c8250513          	addi	a0,a0,-894 # 80000e28 <kfree+0x2a0>
    800001ae:	00000097          	auipc	ra,0x0
    800001b2:	40c080e7          	jalr	1036(ra) # 800005ba <printf>
            zp[i] = 0xFF;
    800001b6:	57fd                	li	a5,-1
    800001b8:	00f48023          	sb	a5,0(s1)
        for (int i = 0; i < PGSIZE; i++) {
    800001bc:	0485                	addi	s1,s1,1
    800001be:	fe991de3          	bne	s2,s1,800001b8 <main+0x19a>
        kfree(zp);
    800001c2:	8552                	mv	a0,s4
    800001c4:	00001097          	auipc	ra,0x1
    800001c8:	9c4080e7          	jalr	-1596(ra) # 80000b88 <kfree>
        zp = (char *)kalloc();
    800001cc:	00001097          	auipc	ra,0x1
    800001d0:	974080e7          	jalr	-1676(ra) # 80000b40 <kalloc>
    800001d4:	6685                	lui	a3,0x1
    800001d6:	84aa                	mv	s1,a0
        for (int i = 0; i < PGSIZE; i++) {
    800001d8:	87aa                	mv	a5,a0
    800001da:	96aa                	add	a3,a3,a0
        nonzero = 0;
    800001dc:	4601                	li	a2,0
            if (zp[i] != 0) nonzero++;
    800001de:	0007c703          	lbu	a4,0(a5)
        for (int i = 0; i < PGSIZE; i++) {
    800001e2:	0785                	addi	a5,a5,1
            if (zp[i] != 0) nonzero++;
    800001e4:	c311                	beqz	a4,800001e8 <main+0x1ca>
    800001e6:	2605                	addiw	a2,a2,1
        for (int i = 0; i < PGSIZE; i++) {
    800001e8:	fef69be3          	bne	a3,a5,800001de <main+0x1c0>
        printf("[cpu %d] dirty-then-realloc zero check: %d/%d bytes non-zero\n",
    800001ec:	6685                	lui	a3,0x1
    800001ee:	4581                	li	a1,0
    800001f0:	00001517          	auipc	a0,0x1
    800001f4:	c5050513          	addi	a0,a0,-944 # 80000e40 <kfree+0x2b8>
    800001f8:	00000097          	auipc	ra,0x0
    800001fc:	3c2080e7          	jalr	962(ra) # 800005ba <printf>
        printf("[cpu %d] expect: 0\n", cpuid);
    80000200:	4581                	li	a1,0
    80000202:	00001517          	auipc	a0,0x1
    80000206:	c2650513          	addi	a0,a0,-986 # 80000e28 <kfree+0x2a0>
    8000020a:	00000097          	auipc	ra,0x0
    8000020e:	3b0080e7          	jalr	944(ra) # 800005ba <printf>
        kfree(zp);
    80000212:	8526                	mv	a0,s1
    80000214:	00001097          	auipc	ra,0x1
    80000218:	974080e7          	jalr	-1676(ra) # 80000b88 <kfree>
        printf("[cpu %d] --- test4: kfree rejects bad addresses ---\n", cpuid);
    8000021c:	4581                	li	a1,0
    8000021e:	00001517          	auipc	a0,0x1
    80000222:	c6250513          	addi	a0,a0,-926 # 80000e80 <kfree+0x2f8>
    80000226:	00000097          	auipc	ra,0x0
    8000022a:	394080e7          	jalr	916(ra) # 800005ba <printf>
        kfree((void *)0x80001001);
    8000022e:	00080537          	lui	a0,0x80
    80000232:	0505                	addi	a0,a0,1 # 80001 <_entry-0x7ff7ffff>
    80000234:	0532                	slli	a0,a0,0xc
    80000236:	0505                	addi	a0,a0,1
    80000238:	00001097          	auipc	ra,0x1
    8000023c:	950080e7          	jalr	-1712(ra) # 80000b88 <kfree>
        kfree((void *)0x80000000);
    80000240:	4505                	li	a0,1
    80000242:	057e                	slli	a0,a0,0x1f
    80000244:	00001097          	auipc	ra,0x1
    80000248:	944080e7          	jalr	-1724(ra) # 80000b88 <kfree>
        kfree((void *)0x88000000);
    8000024c:	4545                	li	a0,17
    8000024e:	056e                	slli	a0,a0,0x1b
    80000250:	00001097          	auipc	ra,0x1
    80000254:	938080e7          	jalr	-1736(ra) # 80000b88 <kfree>
        void *p4 = kalloc();
    80000258:	00001097          	auipc	ra,0x1
    8000025c:	8e8080e7          	jalr	-1816(ra) # 80000b40 <kalloc>
        printf("[cpu %d] alloc after bad frees: p4=%p\n", cpuid, p4);
    80000260:	862a                	mv	a2,a0
        void *p4 = kalloc();
    80000262:	84aa                	mv	s1,a0
        printf("[cpu %d] alloc after bad frees: p4=%p\n", cpuid, p4);
    80000264:	4581                	li	a1,0
    80000266:	00001517          	auipc	a0,0x1
    8000026a:	c5250513          	addi	a0,a0,-942 # 80000eb8 <kfree+0x330>
    8000026e:	00000097          	auipc	ra,0x0
    80000272:	34c080e7          	jalr	844(ra) # 800005ba <printf>
        printf("[cpu %d] expect: p4!=0 (bad frees silently ignored)\n", cpuid);
    80000276:	4581                	li	a1,0
    80000278:	00001517          	auipc	a0,0x1
    8000027c:	c6850513          	addi	a0,a0,-920 # 80000ee0 <kfree+0x358>
    80000280:	00000097          	auipc	ra,0x0
    80000284:	33a080e7          	jalr	826(ra) # 800005ba <printf>
        kfree(p4);
    80000288:	8526                	mv	a0,s1
    8000028a:	00001097          	auipc	ra,0x1
    8000028e:	8fe080e7          	jalr	-1794(ra) # 80000b88 <kfree>
        printf("[cpu %d] --- test5: exhaustion ---\n", cpuid);
    80000292:	4581                	li	a1,0
    80000294:	00001517          	auipc	a0,0x1
    80000298:	c8450513          	addi	a0,a0,-892 # 80000f18 <kfree+0x390>
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	31e080e7          	jalr	798(ra) # 800005ba <printf>
            void *q = kalloc();
    800002a4:	00001097          	auipc	ra,0x1
    800002a8:	89c080e7          	jalr	-1892(ra) # 80000b40 <kalloc>
            if (count < 3) saved[count] = q;
    800002ac:	6905                	lui	s2,0x1
    800002ae:	fb840493          	addi	s1,s0,-72
    800002b2:	4a09                	li	s4,2
    800002b4:	3889091b          	addiw	s2,s2,904 # 1388 <_entry-0x7fffec78>
            count++;
    800002b8:	0019879b          	addiw	a5,s3,1
            if (count < 3) saved[count] = q;
    800002bc:	0009871b          	sext.w	a4,s3
            if (q == 0) break;
    800002c0:	c105                	beqz	a0,800002e0 <main+0x2c2>
            count++;
    800002c2:	0007899b          	sext.w	s3,a5
            if (count < 3) saved[count] = q;
    800002c6:	1aea6f63          	bltu	s4,a4,80000484 <main+0x466>
    800002ca:	e088                	sd	a0,0(s1)
            if (count % 5000 == 0) printf("[cpu %d] ...%d\n", cpuid, count);
    800002cc:	04a1                	addi	s1,s1,8
            void *q = kalloc();
    800002ce:	00001097          	auipc	ra,0x1
    800002d2:	872080e7          	jalr	-1934(ra) # 80000b40 <kalloc>
            count++;
    800002d6:	0019879b          	addiw	a5,s3,1
            if (count < 3) saved[count] = q;
    800002da:	0009871b          	sext.w	a4,s3
            if (q == 0) break;
    800002de:	f175                	bnez	a0,800002c2 <main+0x2a4>
        printf("[cpu %d] allocated %d pages before NULL\n", cpuid, count);
    800002e0:	864e                	mv	a2,s3
    800002e2:	4581                	li	a1,0
    800002e4:	00001517          	auipc	a0,0x1
    800002e8:	c6c50513          	addi	a0,a0,-916 # 80000f50 <kfree+0x3c8>
    800002ec:	00000097          	auipc	ra,0x0
    800002f0:	2ce080e7          	jalr	718(ra) # 800005ba <printf>
        printf("[cpu %d] expect: >1000\n", cpuid);
    800002f4:	4581                	li	a1,0
    800002f6:	00001517          	auipc	a0,0x1
    800002fa:	c8a50513          	addi	a0,a0,-886 # 80000f80 <kfree+0x3f8>
    800002fe:	00000097          	auipc	ra,0x0
    80000302:	2bc080e7          	jalr	700(ra) # 800005ba <printf>
        printf("[cpu %d] --- test6: free-then-reuse after exhaustion ---\n", cpuid);
    80000306:	4581                	li	a1,0
    80000308:	00001517          	auipc	a0,0x1
    8000030c:	c9050513          	addi	a0,a0,-880 # 80000f98 <kfree+0x410>
    80000310:	00000097          	auipc	ra,0x0
    80000314:	2aa080e7          	jalr	682(ra) # 800005ba <printf>
        void *check = kalloc();
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	828080e7          	jalr	-2008(ra) # 80000b40 <kalloc>
    80000320:	84aa                	mv	s1,a0
        printf("[cpu %d] kalloc after exhaustion: %p\n", cpuid, check);
    80000322:	862a                	mv	a2,a0
    80000324:	4581                	li	a1,0
    80000326:	00001517          	auipc	a0,0x1
    8000032a:	cb250513          	addi	a0,a0,-846 # 80000fd8 <kfree+0x450>
    8000032e:	00000097          	auipc	ra,0x0
    80000332:	28c080e7          	jalr	652(ra) # 800005ba <printf>
        printf("[cpu %d] expect: 0x0 (really out of memory)\n", cpuid);
    80000336:	4581                	li	a1,0
    80000338:	00001517          	auipc	a0,0x1
    8000033c:	cc850513          	addi	a0,a0,-824 # 80001000 <kfree+0x478>
    80000340:	00000097          	auipc	ra,0x0
    80000344:	27a080e7          	jalr	634(ra) # 800005ba <printf>
        if (check != 0) kfree(check);
    80000348:	c491                	beqz	s1,80000354 <main+0x336>
    8000034a:	8526                	mv	a0,s1
    8000034c:	00001097          	auipc	ra,0x1
    80000350:	83c080e7          	jalr	-1988(ra) # 80000b88 <kfree>
        kfree(saved[2]);
    80000354:	fc843a03          	ld	s4,-56(s0)
    80000358:	8552                	mv	a0,s4
    8000035a:	00001097          	auipc	ra,0x1
    8000035e:	82e080e7          	jalr	-2002(ra) # 80000b88 <kfree>
        kfree(saved[1]);
    80000362:	fc043983          	ld	s3,-64(s0)
    80000366:	854e                	mv	a0,s3
    80000368:	00001097          	auipc	ra,0x1
    8000036c:	820080e7          	jalr	-2016(ra) # 80000b88 <kfree>
        void *r1 = kalloc();
    80000370:	00000097          	auipc	ra,0x0
    80000374:	7d0080e7          	jalr	2000(ra) # 80000b40 <kalloc>
    80000378:	84aa                	mv	s1,a0
        void *r2 = kalloc();
    8000037a:	00000097          	auipc	ra,0x0
    8000037e:	7c6080e7          	jalr	1990(ra) # 80000b40 <kalloc>
    80000382:	892a                	mv	s2,a0
        printf("[cpu %d] freed 2 pages, re-alloc'd r1=%p r2=%p\n", cpuid, r1, r2);
    80000384:	86aa                	mv	a3,a0
    80000386:	8626                	mv	a2,s1
    80000388:	4581                	li	a1,0
    8000038a:	00001517          	auipc	a0,0x1
    8000038e:	ca650513          	addi	a0,a0,-858 # 80001030 <kfree+0x4a8>
    80000392:	00000097          	auipc	ra,0x0
    80000396:	228080e7          	jalr	552(ra) # 800005ba <printf>
        printf("[cpu %d] expect: r1==%p r2==%p (LIFO)\n", cpuid, saved[1], saved[2]);
    8000039a:	86d2                	mv	a3,s4
    8000039c:	864e                	mv	a2,s3
    8000039e:	4581                	li	a1,0
    800003a0:	00001517          	auipc	a0,0x1
    800003a4:	cc050513          	addi	a0,a0,-832 # 80001060 <kfree+0x4d8>
    800003a8:	00000097          	auipc	ra,0x0
    800003ac:	212080e7          	jalr	530(ra) # 800005ba <printf>
        kfree(r2);
    800003b0:	854a                	mv	a0,s2
    800003b2:	00000097          	auipc	ra,0x0
    800003b6:	7d6080e7          	jalr	2006(ra) # 80000b88 <kfree>
        kfree(r1);
    800003ba:	8526                	mv	a0,s1
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	7cc080e7          	jalr	1996(ra) # 80000b88 <kfree>
        kfree(saved[0]);
    800003c4:	fb843503          	ld	a0,-72(s0)
    800003c8:	00000097          	auipc	ra,0x0
    800003cc:	7c0080e7          	jalr	1984(ra) # 80000b88 <kfree>
        printf("[cpu %d] --- test7: identity mapping ---\n", cpuid);
    800003d0:	4581                	li	a1,0
    800003d2:	00001517          	auipc	a0,0x1
    800003d6:	cb650513          	addi	a0,a0,-842 # 80001088 <kfree+0x500>
    800003da:	00000097          	auipc	ra,0x0
    800003de:	1e0080e7          	jalr	480(ra) # 800005ba <printf>
    asm volatile("csrr %0, satp" : "=r"(x));
    800003e2:	18002673          	csrr	a2,satp
        printf("[cpu %d] satp=%p, mode=%d (8=Sv39)\n",
    800003e6:	4581                	li	a1,0
    800003e8:	03c65693          	srli	a3,a2,0x3c
    800003ec:	00001517          	auipc	a0,0x1
    800003f0:	ccc50513          	addi	a0,a0,-820 # 800010b8 <kfree+0x530>
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	1c6080e7          	jalr	454(ra) # 800005ba <printf>
        printf("[cpu %d] expect: mode=8\n", cpuid);
    800003fc:	4581                	li	a1,0
    800003fe:	00001517          	auipc	a0,0x1
    80000402:	ce250513          	addi	a0,a0,-798 # 800010e0 <kfree+0x558>
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	1b4080e7          	jalr	436(ra) # 800005ba <printf>
        printf("[cpu %d] printf after paging ON proves identity map works\n", cpuid);
    8000040e:	4581                	li	a1,0
    80000410:	00001517          	auipc	a0,0x1
    80000414:	cf050513          	addi	a0,a0,-784 # 80001100 <kfree+0x578>
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	1a2080e7          	jalr	418(ra) # 800005ba <printf>
        printf("[cpu %d] === ALL TESTS PASSED ===\n", cpuid);
    80000420:	4581                	li	a1,0
    80000422:	00001517          	auipc	a0,0x1
    80000426:	d1e50513          	addi	a0,a0,-738 # 80001140 <kfree+0x5b8>
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	190080e7          	jalr	400(ra) # 800005ba <printf>
    80000432:	74e2                	ld	s1,56(sp)
    80000434:	7942                	ld	s2,48(sp)
    80000436:	7a02                	ld	s4,32(sp)
    asm volatile("wfi");
    80000438:	10500073          	wfi
    for (;;) {
    8000043c:	b981                	j	8000008c <main+0x6e>
        kinit();
    8000043e:	00000097          	auipc	ra,0x0
    80000442:	65c080e7          	jalr	1628(ra) # 80000a9a <kinit>
        printf("[cpu %d] kinit: free list built from %p to %p\n",
    80000446:	46c5                	li	a3,17
    80000448:	4605                	li	a2,1
    8000044a:	06ee                	slli	a3,a3,0x1b
    8000044c:	067e                	slli	a2,a2,0x1f
    8000044e:	4581                	li	a1,0
    80000450:	00000517          	auipc	a0,0x0
    80000454:	7c050513          	addi	a0,a0,1984 # 80000c10 <kfree+0x88>
    80000458:	00000097          	auipc	ra,0x0
    8000045c:	162080e7          	jalr	354(ra) # 800005ba <printf>
        kvminit();
    80000460:	00000097          	auipc	ra,0x0
    80000464:	5ba080e7          	jalr	1466(ra) # 80000a1a <kvminit>
        printf("[cpu %d] kvminit: kernel page table at %p\n",
    80000468:	0000b617          	auipc	a2,0xb
    8000046c:	ba863603          	ld	a2,-1112(a2) # 8000b010 <kernel_pgdir>
    80000470:	4581                	li	a1,0
    80000472:	00000517          	auipc	a0,0x0
    80000476:	7ce50513          	addi	a0,a0,1998 # 80000c40 <kfree+0xb8>
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	140080e7          	jalr	320(ra) # 800005ba <printf>
    80000482:	bee1                	j	8000005a <main+0x3c>
            if (count % 5000 == 0) printf("[cpu %d] ...%d\n", cpuid, count);
    80000484:	0327e7bb          	remw	a5,a5,s2
    80000488:	864e                	mv	a2,s3
    8000048a:	4581                	li	a1,0
    8000048c:	00001517          	auipc	a0,0x1
    80000490:	ab450513          	addi	a0,a0,-1356 # 80000f40 <kfree+0x3b8>
    80000494:	e2079ce3          	bnez	a5,800002cc <main+0x2ae>
    80000498:	00000097          	auipc	ra,0x0
    8000049c:	122080e7          	jalr	290(ra) # 800005ba <printf>
    800004a0:	04a1                	addi	s1,s1,8
    800004a2:	b535                	j	800002ce <main+0x2b0>

00000000800004a4 <my_put>:
#define IER_TX_ENABLE   0x01
#define LSR_TX_IDLE     0x20

static volatile uint8 *const uart = (volatile uint8 *)UART0;

void my_put(int c) {
    800004a4:	1141                	addi	sp,sp,-16
    800004a6:	e422                	sd	s0,8(sp)
    while ((uart[LSR] & LSR_TX_IDLE) == 0) {}
    800004a8:	10000737          	lui	a4,0x10000
void my_put(int c) {
    800004ac:	0800                	addi	s0,sp,16
    while ((uart[LSR] & LSR_TX_IDLE) == 0) {}
    800004ae:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800004b0:	00074783          	lbu	a5,0(a4)
    800004b4:	0207f793          	andi	a5,a5,32
    800004b8:	dfe5                	beqz	a5,800004b0 <my_put+0xc>
    uart[THR] = (uint8)c;
    800004ba:	0ff57513          	zext.b	a0,a0
    800004be:	100007b7          	lui	a5,0x10000
    800004c2:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    800004c6:	6422                	ld	s0,8(sp)
    800004c8:	0141                	addi	sp,sp,16
    800004ca:	8082                	ret

00000000800004cc <uartinit>:

void uartinit() {
    800004cc:	1141                	addi	sp,sp,-16
    800004ce:	e422                	sd	s0,8(sp)
    800004d0:	0800                	addi	s0,sp,16
    uart[IER] = 0x00;
    800004d2:	100007b7          	lui	a5,0x10000
    800004d6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    uart[LCR] = LCR_BAUD_LATCH;
    800004da:	10000737          	lui	a4,0x10000
    800004de:	f8000693          	li	a3,-128
    800004e2:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>
    uart[0] = 0x03;
    800004e6:	460d                	li	a2,3
    uart[IER] = 0x00;
    800004e8:	100006b7          	lui	a3,0x10000
    uart[0] = 0x03;
    800004ec:	00c68023          	sb	a2,0(a3) # 10000000 <_entry-0x70000000>
    uart[1] = 0x00;
    800004f0:	000780a3          	sb	zero,1(a5)
    uart[LCR] = LCR_EIGHT_BITS;
    800004f4:	00c701a3          	sb	a2,3(a4)
    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;
    800004f8:	471d                	li	a4,7
    800004fa:	00e68123          	sb	a4,2(a3)
    uart[IER] = IER_TX_ENABLE;
    800004fe:	4705                	li	a4,1
    80000500:	00e780a3          	sb	a4,1(a5)
}
    80000504:	6422                	ld	s0,8(sp)
    80000506:	0141                	addi	sp,sp,16
    80000508:	8082                	ret

000000008000050a <printint>:
        my_put('\r');
    }
    my_put(c);
}

static void printint(int64 xx, int base, int sign) {
    8000050a:	715d                	addi	sp,sp,-80
    8000050c:	e0a2                	sd	s0,64(sp)
    8000050e:	e486                	sd	ra,72(sp)
    80000510:	fc26                	sd	s1,56(sp)
    80000512:	f84a                	sd	s2,48(sp)
    80000514:	f44e                	sd	s3,40(sp)
    80000516:	f052                	sd	s4,32(sp)
    80000518:	0880                	addi	s0,sp,80
    char buf[32];
    uint64 x;
    if (sign && xx < 0) {
    8000051a:	c609                	beqz	a2,80000524 <printint+0x1a>
        x = (uint64)(-xx);
    8000051c:	40a007b3          	neg	a5,a0
    if (sign && xx < 0) {
    80000520:	00054363          	bltz	a0,80000526 <printint+0x1c>
    } else {
        x = (uint64)xx;
    80000524:	87aa                	mv	a5,a0
    }
    int i = 0;
    do {
        buf[i++] = digits[x % base];
    80000526:	fb040693          	addi	a3,s0,-80
    8000052a:	4801                	li	a6,0
    8000052c:	00001317          	auipc	t1,0x1
    80000530:	cac30313          	addi	t1,t1,-852 # 800011d8 <digits>
    80000534:	02b7f733          	remu	a4,a5,a1
        x /= base;
    } while (x != 0);
    80000538:	0685                	addi	a3,a3,1
    8000053a:	88be                	mv	a7,a5
    8000053c:	84c2                	mv	s1,a6
        buf[i++] = digits[x % base];
    8000053e:	2805                	addiw	a6,a6,1
    80000540:	971a                	add	a4,a4,t1
    80000542:	00074703          	lbu	a4,0(a4)
        x /= base;
    80000546:	02b7d7b3          	divu	a5,a5,a1
        buf[i++] = digits[x % base];
    8000054a:	fee68fa3          	sb	a4,-1(a3)
    } while (x != 0);
    8000054e:	feb8f3e3          	bgeu	a7,a1,80000534 <printint+0x2a>
    if (sign && xx < 0) {
    80000552:	c219                	beqz	a2,80000558 <printint+0x4e>
    80000554:	04054a63          	bltz	a0,800005a8 <printint+0x9e>
    80000558:	fb040793          	addi	a5,s0,-80
    8000055c:	94be                	add	s1,s1,a5
    8000055e:	fff78993          	addi	s3,a5,-1
    if (c == '\n') {
    80000562:	4a29                	li	s4,10
    80000564:	a809                	j	80000576 <printint+0x6c>
    my_put(c);
    80000566:	854a                	mv	a0,s2
        buf[i++] = '-';
    }
    while (--i >= 0) {
    80000568:	14fd                	addi	s1,s1,-1
    my_put(c);
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	f3a080e7          	jalr	-198(ra) # 800004a4 <my_put>
    while (--i >= 0) {
    80000572:	03348363          	beq	s1,s3,80000598 <printint+0x8e>
        putc(buf[i]);
    80000576:	0004c903          	lbu	s2,0(s1)
    if (c == '\n') {
    8000057a:	ff4916e3          	bne	s2,s4,80000566 <printint+0x5c>
        my_put('\r');
    8000057e:	4535                	li	a0,13
    80000580:	00000097          	auipc	ra,0x0
    80000584:	f24080e7          	jalr	-220(ra) # 800004a4 <my_put>
    my_put(c);
    80000588:	854a                	mv	a0,s2
    while (--i >= 0) {
    8000058a:	14fd                	addi	s1,s1,-1
    my_put(c);
    8000058c:	00000097          	auipc	ra,0x0
    80000590:	f18080e7          	jalr	-232(ra) # 800004a4 <my_put>
    while (--i >= 0) {
    80000594:	ff3491e3          	bne	s1,s3,80000576 <printint+0x6c>
    }
}
    80000598:	60a6                	ld	ra,72(sp)
    8000059a:	6406                	ld	s0,64(sp)
    8000059c:	74e2                	ld	s1,56(sp)
    8000059e:	7942                	ld	s2,48(sp)
    800005a0:	79a2                	ld	s3,40(sp)
    800005a2:	7a02                	ld	s4,32(sp)
    800005a4:	6161                	addi	sp,sp,80
    800005a6:	8082                	ret
        buf[i++] = '-';
    800005a8:	fd080793          	addi	a5,a6,-48
    800005ac:	97a2                	add	a5,a5,s0
    800005ae:	02d00713          	li	a4,45
    800005b2:	fee78023          	sb	a4,-32(a5)
    while (--i >= 0) {
    800005b6:	84c2                	mv	s1,a6
    800005b8:	b745                	j	80000558 <printint+0x4e>

00000000800005ba <printf>:
}

static struct spinlock pr_lock;
static int pr_lock_inited;

void printf(const char *fmt, ...) {
    800005ba:	7131                	addi	sp,sp,-192
    800005bc:	f8a2                	sd	s0,112(sp)
    800005be:	f4a6                	sd	s1,104(sp)
    800005c0:	0100                	addi	s0,sp,128
    800005c2:	f0ca                	sd	s2,96(sp)
    800005c4:	fc86                	sd	ra,120(sp)
    800005c6:	ecce                	sd	s3,88(sp)
    int c;
    const char *s;
    va_list ap;
    if (!pr_lock_inited) {
    800005c8:	0000b917          	auipc	s2,0xb
    800005cc:	a3890913          	addi	s2,s2,-1480 # 8000b000 <pr_lock_inited>
    800005d0:	00092303          	lw	t1,0(s2)
void printf(const char *fmt, ...) {
    800005d4:	e40c                	sd	a1,8(s0)
    800005d6:	e810                	sd	a2,16(s0)
    800005d8:	ec14                	sd	a3,24(s0)
    800005da:	f018                	sd	a4,32(s0)
    800005dc:	f41c                	sd	a5,40(s0)
    800005de:	03043823          	sd	a6,48(s0)
    800005e2:	03143c23          	sd	a7,56(s0)
    800005e6:	84aa                	mv	s1,a0
    if (!pr_lock_inited) {
    800005e8:	20030b63          	beqz	t1,800007fe <printf+0x244>
        initlock(&pr_lock, "printf");
        pr_lock_inited = 1;
    }
    acquire(&pr_lock);
    800005ec:	00002517          	auipc	a0,0x2
    800005f0:	a1450513          	addi	a0,a0,-1516 # 80002000 <pr_lock>
    800005f4:	00000097          	auipc	ra,0x0
    800005f8:	2b8080e7          	jalr	696(ra) # 800008ac <acquire>
    va_start(ap, fmt);
    for (; (c = *fmt) != 0; fmt++) {
    800005fc:	0004c983          	lbu	s3,0(s1)
    va_start(ap, fmt);
    80000600:	00840793          	addi	a5,s0,8
    80000604:	f8f43423          	sd	a5,-120(s0)
    for (; (c = *fmt) != 0; fmt++) {
    80000608:	06098c63          	beqz	s3,80000680 <printf+0xc6>
    8000060c:	fc5e                	sd	s7,56(sp)
    8000060e:	f862                	sd	s8,48(sp)
    80000610:	f466                	sd	s9,40(sp)
    80000612:	e8d2                	sd	s4,80(sp)
    80000614:	e4d6                	sd	s5,72(sp)
        if (c != '%') { putc(c); continue; }
    80000616:	02500913          	li	s2,37
        fmt++;
        if (*fmt == 0) break;
        switch (*fmt) {
    8000061a:	4c55                	li	s8,21
    8000061c:	00001b97          	auipc	s7,0x1
    80000620:	b64b8b93          	addi	s7,s7,-1180 # 80001180 <kfree+0x5f8>
    if (c == '\n') {
    80000624:	4ca9                	li	s9,10
        if (c != '%') { putc(c); continue; }
    80000626:	1b299763          	bne	s3,s2,800007d4 <printf+0x21a>
        if (*fmt == 0) break;
    8000062a:	0014c783          	lbu	a5,1(s1)
    8000062e:	c7a1                	beqz	a5,80000676 <printf+0xbc>
        switch (*fmt) {
    80000630:	1b278a63          	beq	a5,s2,800007e4 <printf+0x22a>
    80000634:	f9d7879b          	addiw	a5,a5,-99
    80000638:	0ff7f793          	zext.b	a5,a5
    8000063c:	00fc6763          	bltu	s8,a5,8000064a <printf+0x90>
    80000640:	078a                	slli	a5,a5,0x2
    80000642:	97de                	add	a5,a5,s7
    80000644:	439c                	lw	a5,0(a5)
    80000646:	97de                	add	a5,a5,s7
    80000648:	8782                	jr	a5
    my_put(c);
    8000064a:	02500513          	li	a0,37
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	e56080e7          	jalr	-426(ra) # 800004a4 <my_put>
            if (s == 0) s = "(null)";
            while (*s) putc(*s++);
            break;
        case 'c': putc(va_arg(ap, int)); break;
        case '%': putc('%'); break;
        default:  putc('%'); putc(*fmt); break;
    80000656:	0014c983          	lbu	s3,1(s1)
    if (c == '\n') {
    8000065a:	47a9                	li	a5,10
    8000065c:	16f98663          	beq	s3,a5,800007c8 <printf+0x20e>
    my_put(c);
    80000660:	854e                	mv	a0,s3
    80000662:	00000097          	auipc	ra,0x0
    80000666:	e42080e7          	jalr	-446(ra) # 800004a4 <my_put>
        fmt++;
    8000066a:	0485                	addi	s1,s1,1
    for (; (c = *fmt) != 0; fmt++) {
    8000066c:	0014c983          	lbu	s3,1(s1)
    80000670:	0485                	addi	s1,s1,1
    80000672:	fa099ae3          	bnez	s3,80000626 <printf+0x6c>
    80000676:	6a46                	ld	s4,80(sp)
    80000678:	6aa6                	ld	s5,72(sp)
    8000067a:	7be2                	ld	s7,56(sp)
    8000067c:	7c42                	ld	s8,48(sp)
    8000067e:	7ca2                	ld	s9,40(sp)
        }
    }
    va_end(ap);
    release(&pr_lock);
    80000680:	00002517          	auipc	a0,0x2
    80000684:	98050513          	addi	a0,a0,-1664 # 80002000 <pr_lock>
    80000688:	00000097          	auipc	ra,0x0
    8000068c:	246080e7          	jalr	582(ra) # 800008ce <release>
}
    80000690:	70e6                	ld	ra,120(sp)
    80000692:	7446                	ld	s0,112(sp)
    80000694:	74a6                	ld	s1,104(sp)
    80000696:	7906                	ld	s2,96(sp)
    80000698:	69e6                	ld	s3,88(sp)
    8000069a:	6129                	addi	sp,sp,192
    8000069c:	8082                	ret
        case 'x': printint(va_arg(ap, unsigned int), 16, 0); break;
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45c1                	li	a1,16
    800006a6:	0007e503          	lwu	a0,0(a5)
    800006aa:	07a1                	addi	a5,a5,8
    800006ac:	f8f43423          	sd	a5,-120(s0)
    800006b0:	00000097          	auipc	ra,0x0
    800006b4:	e5a080e7          	jalr	-422(ra) # 8000050a <printint>
    800006b8:	bf4d                	j	8000066a <printf+0xb0>
        case 'u': printint(va_arg(ap, unsigned int), 10, 0); break;
    800006ba:	f8843783          	ld	a5,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	0007e503          	lwu	a0,0(a5)
    800006c6:	07a1                	addi	a5,a5,8
    800006c8:	f8f43423          	sd	a5,-120(s0)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	e3e080e7          	jalr	-450(ra) # 8000050a <printint>
    800006d4:	bf59                	j	8000066a <printf+0xb0>
            s = va_arg(ap, const char *);
    800006d6:	f8843783          	ld	a5,-120(s0)
    800006da:	0007b983          	ld	s3,0(a5)
    800006de:	07a1                	addi	a5,a5,8
    800006e0:	f8f43423          	sd	a5,-120(s0)
            if (s == 0) s = "(null)";
    800006e4:	12098d63          	beqz	s3,8000081e <printf+0x264>
            while (*s) putc(*s++);
    800006e8:	0009c783          	lbu	a5,0(s3)
    800006ec:	dfbd                	beqz	a5,8000066a <printf+0xb0>
    if (c == '\n') {
    800006ee:	4aa9                	li	s5,10
    800006f0:	a809                	j	80000702 <printf+0x148>
    my_put(c);
    800006f2:	8552                	mv	a0,s4
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	db0080e7          	jalr	-592(ra) # 800004a4 <my_put>
            while (*s) putc(*s++);
    800006fc:	0009c783          	lbu	a5,0(s3)
    80000700:	d7ad                	beqz	a5,8000066a <printf+0xb0>
    80000702:	0985                	addi	s3,s3,1
    80000704:	00078a1b          	sext.w	s4,a5
    if (c == '\n') {
    80000708:	ff5795e3          	bne	a5,s5,800006f2 <printf+0x138>
        my_put('\r');
    8000070c:	4535                	li	a0,13
    8000070e:	00000097          	auipc	ra,0x0
    80000712:	d96080e7          	jalr	-618(ra) # 800004a4 <my_put>
    80000716:	bff1                	j	800006f2 <printf+0x138>
        case 'p': printptr((uint64)va_arg(ap, void *)); break;
    80000718:	f8843783          	ld	a5,-120(s0)
    my_put(c);
    8000071c:	03000513          	li	a0,48
    80000720:	e0da                	sd	s6,64(sp)
        case 'p': printptr((uint64)va_arg(ap, void *)); break;
    80000722:	00878713          	addi	a4,a5,8
    80000726:	0007bb03          	ld	s6,0(a5)
    8000072a:	f06a                	sd	s10,32(sp)
    8000072c:	f8e43423          	sd	a4,-120(s0)
    80000730:	ec6e                	sd	s11,24(sp)
    my_put(c);
    80000732:	00000097          	auipc	ra,0x0
    80000736:	d72080e7          	jalr	-654(ra) # 800004a4 <my_put>
    8000073a:	07800513          	li	a0,120
    8000073e:	00000097          	auipc	ra,0x0
    80000742:	d66080e7          	jalr	-666(ra) # 800004a4 <my_put>
    80000746:	03c00d13          	li	s10,60
    8000074a:	00001a97          	auipc	s5,0x1
    8000074e:	a8ea8a93          	addi	s5,s5,-1394 # 800011d8 <digits>
    if (c == '\n') {
    80000752:	4a29                	li	s4,10
    for (int i = 0; i < 16; i++) {
    80000754:	59f1                	li	s3,-4
    80000756:	a809                	j	80000768 <printf+0x1ae>
    my_put(c);
    80000758:	856e                	mv	a0,s11
    for (int i = 0; i < 16; i++) {
    8000075a:	3d71                	addiw	s10,s10,-4
    my_put(c);
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	d48080e7          	jalr	-696(ra) # 800004a4 <my_put>
    for (int i = 0; i < 16; i++) {
    80000764:	033d0763          	beq	s10,s3,80000792 <printf+0x1d8>
        putc(digits[(x >> ((15 - i) * 4)) & 0xf]);
    80000768:	01ab57b3          	srl	a5,s6,s10
    8000076c:	8bbd                	andi	a5,a5,15
    8000076e:	97d6                	add	a5,a5,s5
    80000770:	0007cd83          	lbu	s11,0(a5)
    if (c == '\n') {
    80000774:	ff4d92e3          	bne	s11,s4,80000758 <printf+0x19e>
        my_put('\r');
    80000778:	4535                	li	a0,13
    8000077a:	00000097          	auipc	ra,0x0
    8000077e:	d2a080e7          	jalr	-726(ra) # 800004a4 <my_put>
    my_put(c);
    80000782:	856e                	mv	a0,s11
    for (int i = 0; i < 16; i++) {
    80000784:	3d71                	addiw	s10,s10,-4
    my_put(c);
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	d1e080e7          	jalr	-738(ra) # 800004a4 <my_put>
    for (int i = 0; i < 16; i++) {
    8000078e:	fd3d1de3          	bne	s10,s3,80000768 <printf+0x1ae>
    80000792:	6b06                	ld	s6,64(sp)
    80000794:	7d02                	ld	s10,32(sp)
    80000796:	6de2                	ld	s11,24(sp)
    80000798:	bdc9                	j	8000066a <printf+0xb0>
        case 'd': printint(va_arg(ap, int), 10, 1); break;
    8000079a:	f8843783          	ld	a5,-120(s0)
    8000079e:	4605                	li	a2,1
    800007a0:	45a9                	li	a1,10
    800007a2:	4388                	lw	a0,0(a5)
    800007a4:	07a1                	addi	a5,a5,8
    800007a6:	f8f43423          	sd	a5,-120(s0)
    800007aa:	00000097          	auipc	ra,0x0
    800007ae:	d60080e7          	jalr	-672(ra) # 8000050a <printint>
    800007b2:	bd65                	j	8000066a <printf+0xb0>
        case 'c': putc(va_arg(ap, int)); break;
    800007b4:	f8843783          	ld	a5,-120(s0)
    if (c == '\n') {
    800007b8:	4729                	li	a4,10
        case 'c': putc(va_arg(ap, int)); break;
    800007ba:	0007a983          	lw	s3,0(a5)
    800007be:	07a1                	addi	a5,a5,8
    800007c0:	f8f43423          	sd	a5,-120(s0)
    if (c == '\n') {
    800007c4:	e8e99ee3          	bne	s3,a4,80000660 <printf+0xa6>
        my_put('\r');
    800007c8:	4535                	li	a0,13
    800007ca:	00000097          	auipc	ra,0x0
    800007ce:	cda080e7          	jalr	-806(ra) # 800004a4 <my_put>
    800007d2:	b579                	j	80000660 <printf+0xa6>
    if (c == '\n') {
    800007d4:	01998f63          	beq	s3,s9,800007f2 <printf+0x238>
    my_put(c);
    800007d8:	854e                	mv	a0,s3
    800007da:	00000097          	auipc	ra,0x0
    800007de:	cca080e7          	jalr	-822(ra) # 800004a4 <my_put>
        if (c != '%') { putc(c); continue; }
    800007e2:	b569                	j	8000066c <printf+0xb2>
    my_put(c);
    800007e4:	02500513          	li	a0,37
    800007e8:	00000097          	auipc	ra,0x0
    800007ec:	cbc080e7          	jalr	-836(ra) # 800004a4 <my_put>
}
    800007f0:	bdad                	j	8000066a <printf+0xb0>
        my_put('\r');
    800007f2:	4535                	li	a0,13
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	cb0080e7          	jalr	-848(ra) # 800004a4 <my_put>
    800007fc:	bff1                	j	800007d8 <printf+0x21e>
        initlock(&pr_lock, "printf");
    800007fe:	00001597          	auipc	a1,0x1
    80000802:	97258593          	addi	a1,a1,-1678 # 80001170 <kfree+0x5e8>
    80000806:	00001517          	auipc	a0,0x1
    8000080a:	7fa50513          	addi	a0,a0,2042 # 80002000 <pr_lock>
    8000080e:	00000097          	auipc	ra,0x0
    80000812:	08c080e7          	jalr	140(ra) # 8000089a <initlock>
        pr_lock_inited = 1;
    80000816:	4785                	li	a5,1
    80000818:	00f92023          	sw	a5,0(s2)
    8000081c:	bbc1                	j	800005ec <printf+0x32>
    8000081e:	02800793          	li	a5,40
            if (s == 0) s = "(null)";
    80000822:	00001997          	auipc	s3,0x1
    80000826:	94698993          	addi	s3,s3,-1722 # 80001168 <kfree+0x5e0>
    8000082a:	b5d1                	j	800006ee <printf+0x134>

000000008000082c <r_mstatus>:
#include "arch/type.h"

uint64 r_mstatus() {
    8000082c:	1141                	addi	sp,sp,-16
    8000082e:	e422                	sd	s0,8(sp)
    80000830:	0800                	addi	s0,sp,16
    uint64 x;
    asm volatile("csrr %0, mstatus" : "=r"(x));
    80000832:	30002573          	csrr	a0,mstatus
    return x;
}
    80000836:	6422                	ld	s0,8(sp)
    80000838:	0141                	addi	sp,sp,16
    8000083a:	8082                	ret

000000008000083c <w_mstatus>:

void w_mstatus(uint64 x) {
    8000083c:	1141                	addi	sp,sp,-16
    8000083e:	e422                	sd	s0,8(sp)
    80000840:	0800                	addi	s0,sp,16
    asm volatile("csrw mstatus, %0" : : "r"(x));
    80000842:	30051073          	csrw	mstatus,a0
}
    80000846:	6422                	ld	s0,8(sp)
    80000848:	0141                	addi	sp,sp,16
    8000084a:	8082                	ret

000000008000084c <w_mepc>:

void w_mepc(uint64 x) {
    8000084c:	1141                	addi	sp,sp,-16
    8000084e:	e422                	sd	s0,8(sp)
    80000850:	0800                	addi	s0,sp,16
    asm volatile("csrw mepc, %0" : : "r"(x));
    80000852:	34151073          	csrw	mepc,a0
}
    80000856:	6422                	ld	s0,8(sp)
    80000858:	0141                	addi	sp,sp,16
    8000085a:	8082                	ret

000000008000085c <w_pmpaddr0>:

void w_pmpaddr0(uint64 x) {
    8000085c:	1141                	addi	sp,sp,-16
    8000085e:	e422                	sd	s0,8(sp)
    80000860:	0800                	addi	s0,sp,16
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    80000862:	3b051073          	csrw	pmpaddr0,a0
}
    80000866:	6422                	ld	s0,8(sp)
    80000868:	0141                	addi	sp,sp,16
    8000086a:	8082                	ret

000000008000086c <w_pmpcfg0>:

void w_pmpcfg0(uint64 x) {
    8000086c:	1141                	addi	sp,sp,-16
    8000086e:	e422                	sd	s0,8(sp)
    80000870:	0800                	addi	s0,sp,16
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    80000872:	3a051073          	csrw	pmpcfg0,a0
}
    80000876:	6422                	ld	s0,8(sp)
    80000878:	0141                	addi	sp,sp,16
    8000087a:	8082                	ret

000000008000087c <r_mhartid>:

uint64 r_mhartid() {
    8000087c:	1141                	addi	sp,sp,-16
    8000087e:	e422                	sd	s0,8(sp)
    80000880:	0800                	addi	s0,sp,16
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    80000882:	f1402573          	csrr	a0,mhartid
    return x;
}
    80000886:	6422                	ld	s0,8(sp)
    80000888:	0141                	addi	sp,sp,16
    8000088a:	8082                	ret

000000008000088c <w_tp>:

void w_tp(uint64 x) {
    8000088c:	1141                	addi	sp,sp,-16
    8000088e:	e422                	sd	s0,8(sp)
    80000890:	0800                	addi	s0,sp,16
    asm volatile("mv tp, %0" : : "r"(x));
    80000892:	822a                	mv	tp,a0
}
    80000894:	6422                	ld	s0,8(sp)
    80000896:	0141                	addi	sp,sp,16
    80000898:	8082                	ret

000000008000089a <initlock>:
#include "arch/method.h"
#include "lock/mod.h"

void initlock(struct spinlock *lk, const char *name) {
    8000089a:	1141                	addi	sp,sp,-16
    8000089c:	e422                	sd	s0,8(sp)
    8000089e:	0800                	addi	s0,sp,16
    lk->locked = 0;
    lk->name = name;
}
    800008a0:	6422                	ld	s0,8(sp)
    lk->locked = 0;
    800008a2:	00052023          	sw	zero,0(a0)
    lk->name = name;
    800008a6:	e50c                	sd	a1,8(a0)
}
    800008a8:	0141                	addi	sp,sp,16
    800008aa:	8082                	ret

00000000800008ac <acquire>:

void acquire(struct spinlock *lk) {
    800008ac:	1141                	addi	sp,sp,-16
    800008ae:	e422                	sd	s0,8(sp)
    800008b0:	0800                	addi	s0,sp,16
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
    800008b2:	4789                	li	a5,2
    800008b4:	1007b073          	csrc	sstatus,a5
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0) {}
    800008b8:	4705                	li	a4,1
    800008ba:	87ba                	mv	a5,a4
    800008bc:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    800008c0:	2781                	sext.w	a5,a5
    800008c2:	ffe5                	bnez	a5,800008ba <acquire+0xe>
    __sync_synchronize();
    800008c4:	0330000f          	fence	rw,rw
}
    800008c8:	6422                	ld	s0,8(sp)
    800008ca:	0141                	addi	sp,sp,16
    800008cc:	8082                	ret

00000000800008ce <release>:

void release(struct spinlock *lk) {
    800008ce:	1141                	addi	sp,sp,-16
    800008d0:	e422                	sd	s0,8(sp)
    800008d2:	0800                	addi	s0,sp,16
    __sync_synchronize();
    800008d4:	0330000f          	fence	rw,rw
    __sync_lock_release(&lk->locked);
    800008d8:	0310000f          	fence	rw,w
    800008dc:	00052023          	sw	zero,0(a0)
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
    800008e0:	4789                	li	a5,2
    800008e2:	1007a073          	csrs	sstatus,a5
    intr_on();
}
    800008e6:	6422                	ld	s0,8(sp)
    800008e8:	0141                	addi	sp,sp,16
    800008ea:	8082                	ret

00000000800008ec <start>:
void   w_pmpcfg0(uint64 x);
uint64 r_mhartid();
void   w_tp(uint64 x);


void start() {
    800008ec:	1141                	addi	sp,sp,-16
    800008ee:	e406                	sd	ra,8(sp)
    800008f0:	e022                	sd	s0,0(sp)
    800008f2:	0800                	addi	s0,sp,16
    w_tp(r_mhartid());
    800008f4:	00000097          	auipc	ra,0x0
    800008f8:	f88080e7          	jalr	-120(ra) # 8000087c <r_mhartid>
    800008fc:	00000097          	auipc	ra,0x0
    80000900:	f90080e7          	jalr	-112(ra) # 8000088c <w_tp>

    uint64 x = r_mstatus();
    80000904:	00000097          	auipc	ra,0x0
    80000908:	f28080e7          	jalr	-216(ra) # 8000082c <r_mstatus>
    x &= ~(2UL << 11);
    8000090c:	777d                	lui	a4,0xfffff
    8000090e:	177d                	addi	a4,a4,-1 # ffffffffffffefff <kernel_pgdir+0xffffffff7fff3fef>
    x |=  (1UL << 11);
    80000910:	6785                	lui	a5,0x1
    x &= ~(2UL << 11);
    80000912:	8d79                	and	a0,a0,a4
    x |=  (1UL << 11);
    80000914:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    w_mstatus(x);
    80000918:	8d5d                	or	a0,a0,a5
    8000091a:	00000097          	auipc	ra,0x0
    8000091e:	f22080e7          	jalr	-222(ra) # 8000083c <w_mstatus>

    w_mepc((uint64)main);
    80000922:	fffff517          	auipc	a0,0xfffff
    80000926:	6fc50513          	addi	a0,a0,1788 # 8000001e <main>
    8000092a:	00000097          	auipc	ra,0x0
    8000092e:	f22080e7          	jalr	-222(ra) # 8000084c <w_mepc>

    asm volatile("csrw satp, %0" : : "r"(0));
    80000932:	4781                	li	a5,0
    80000934:	18079073          	csrw	satp,a5
    asm volatile("csrw medeleg, %0" : : "r"(0));
    80000938:	30279073          	csrw	medeleg,a5
    asm volatile("csrw mideleg, %0" : : "r"(0));
    8000093c:	30379073          	csrw	mideleg,a5
    asm volatile("csrw sie, %0" : : "r"(0));
    80000940:	10479073          	csrw	sie,a5

    w_pmpaddr0(0x3fffffffffffffull);
    80000944:	557d                	li	a0,-1
    80000946:	8129                	srli	a0,a0,0xa
    80000948:	00000097          	auipc	ra,0x0
    8000094c:	f14080e7          	jalr	-236(ra) # 8000085c <w_pmpaddr0>
    w_pmpcfg0(0xf);
    80000950:	453d                	li	a0,15
    80000952:	00000097          	auipc	ra,0x0
    80000956:	f1a080e7          	jalr	-230(ra) # 8000086c <w_pmpcfg0>

    asm volatile("mret");
    8000095a:	30200073          	mret

    while (1) {}
    8000095e:	a001                	j	8000095e <start+0x72>

0000000080000960 <kvmmap>:
        }
    }
    return &pgdir[PX(va, 0)];
}

static void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
    80000960:	711d                	addi	sp,sp,-96
    80000962:	e8a2                	sd	s0,80(sp)
    80000964:	e0ca                	sd	s2,64(sp)
    80000966:	fc4e                	sd	s3,56(sp)
    80000968:	f852                	sd	s4,48(sp)
    8000096a:	f456                	sd	s5,40(sp)
    8000096c:	f05a                	sd	s6,32(sp)
    8000096e:	e862                	sd	s8,16(sp)
    80000970:	e466                	sd	s9,8(sp)
    80000972:	ec86                	sd	ra,88(sp)
    80000974:	e4a6                	sd	s1,72(sp)
    80000976:	ec5e                	sd	s7,24(sp)
    80000978:	e06a                	sd	s10,0(sp)
    8000097a:	1080                	addi	s0,sp,96
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    8000097c:	8c2e                	mv	s8,a1
static void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
    8000097e:	8a2a                	mv	s4,a0
    80000980:	8aba                	mv	s5,a4
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    80000982:	00d58933          	add	s2,a1,a3
    80000986:	40b609b3          	sub	s3,a2,a1
    8000098a:	4c85                	li	s9,1
    8000098c:	6b05                	lui	s6,0x1
    8000098e:	013c0bb3          	add	s7,s8,s3
    for (int level = 2; level >= 1; level--) {
    80000992:	8552                	mv	a0,s4
    80000994:	4d09                	li	s10,2
    80000996:	4789                	li	a5,2
        uint64 *pte = &pgdir[PX(va, level)];
    80000998:	0037949b          	slliw	s1,a5,0x3
    8000099c:	9cbd                	addw	s1,s1,a5
    8000099e:	24b1                	addiw	s1,s1,12
    800009a0:	009c54b3          	srl	s1,s8,s1
    800009a4:	1ff4f493          	andi	s1,s1,511
    800009a8:	048e                	slli	s1,s1,0x3
    800009aa:	94aa                	add	s1,s1,a0
        if (*pte & PTE_V) {
    800009ac:	6088                	ld	a0,0(s1)
    800009ae:	00157793          	andi	a5,a0,1
            pgdir = (uint64 *)PTE2PA(*pte);
    800009b2:	8129                	srli	a0,a0,0xa
    800009b4:	0532                	slli	a0,a0,0xc
        if (*pte & PTE_V) {
    800009b6:	ef81                	bnez	a5,800009ce <kvmmap+0x6e>
            pgdir = (uint64 *)kalloc();
    800009b8:	00000097          	auipc	ra,0x0
    800009bc:	188080e7          	jalr	392(ra) # 80000b40 <kalloc>
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
    800009c0:	00c55793          	srli	a5,a0,0xc
    800009c4:	07aa                	slli	a5,a5,0xa
    800009c6:	0017e793          	ori	a5,a5,1
            if (pgdir == 0) {
    800009ca:	c915                	beqz	a0,800009fe <kvmmap+0x9e>
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
    800009cc:	e09c                	sd	a5,0(s1)
    for (int level = 2; level >= 1; level--) {
    800009ce:	4785                	li	a5,1
    800009d0:	019d0463          	beq	s10,s9,800009d8 <kvmmap+0x78>
    800009d4:	4d05                	li	s10,1
    800009d6:	b7c9                	j	80000998 <kvmmap+0x38>
    return &pgdir[PX(va, 0)];
    800009d8:	00cc5793          	srli	a5,s8,0xc
    800009dc:	1ff7f793          	andi	a5,a5,511
    800009e0:	078e                	slli	a5,a5,0x3
    800009e2:	953e                	add	a0,a0,a5
        uint64 *pte = walk(pgdir, a, 1);
        if (pte == 0) {
    800009e4:	cd09                	beqz	a0,800009fe <kvmmap+0x9e>
            return;
        }
        *pte = PA2PTE(pa) | perm | PTE_V;
    800009e6:	00cbdb93          	srli	s7,s7,0xc
    800009ea:	0baa                	slli	s7,s7,0xa
    800009ec:	015bebb3          	or	s7,s7,s5
    800009f0:	001beb93          	ori	s7,s7,1
    800009f4:	01753023          	sd	s7,0(a0)
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    800009f8:	9c5a                	add	s8,s8,s6
    800009fa:	f92c6ae3          	bltu	s8,s2,8000098e <kvmmap+0x2e>
    }
}
    800009fe:	60e6                	ld	ra,88(sp)
    80000a00:	6446                	ld	s0,80(sp)
    80000a02:	64a6                	ld	s1,72(sp)
    80000a04:	6906                	ld	s2,64(sp)
    80000a06:	79e2                	ld	s3,56(sp)
    80000a08:	7a42                	ld	s4,48(sp)
    80000a0a:	7aa2                	ld	s5,40(sp)
    80000a0c:	7b02                	ld	s6,32(sp)
    80000a0e:	6be2                	ld	s7,24(sp)
    80000a10:	6c42                	ld	s8,16(sp)
    80000a12:	6ca2                	ld	s9,8(sp)
    80000a14:	6d02                	ld	s10,0(sp)
    80000a16:	6125                	addi	sp,sp,96
    80000a18:	8082                	ret

0000000080000a1a <kvminit>:

void kvminit() {
    80000a1a:	1101                	addi	sp,sp,-32
    80000a1c:	e822                	sd	s0,16(sp)
    80000a1e:	e426                	sd	s1,8(sp)
    80000a20:	ec06                	sd	ra,24(sp)
    80000a22:	1000                	addi	s0,sp,32
    kernel_pgdir = (uint64 *)kalloc();
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	11c080e7          	jalr	284(ra) # 80000b40 <kalloc>
    80000a2c:	0000a497          	auipc	s1,0xa
    80000a30:	5e448493          	addi	s1,s1,1508 # 8000b010 <kernel_pgdir>
    80000a34:	e088                	sd	a0,0(s1)
    if (kernel_pgdir == 0) {
    80000a36:	c91d                	beqz	a0,80000a6c <kvminit+0x52>
        return;
    }
    kvmmap(kernel_pgdir, UART0, UART0, PGSIZE, PTE_KERN_RW);
    80000a38:	4719                	li	a4,6
    80000a3a:	6685                	lui	a3,0x1
    80000a3c:	10000637          	lui	a2,0x10000
    80000a40:	100005b7          	lui	a1,0x10000
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	f1c080e7          	jalr	-228(ra) # 80000960 <kvmmap>
    kvmmap(kernel_pgdir, KERNBASE, KERNBASE, PHYSTOP - KERNBASE, PTE_KERN_RWX);
    80000a4c:	6088                	ld	a0,0(s1)
    80000a4e:	4605                	li	a2,1
    80000a50:	067e                	slli	a2,a2,0x1f
    80000a52:	4739                	li	a4,14
    80000a54:	080006b7          	lui	a3,0x8000
    80000a58:	85b2                	mv	a1,a2
    80000a5a:	00000097          	auipc	ra,0x0
    80000a5e:	f06080e7          	jalr	-250(ra) # 80000960 <kvmmap>
    kvminit_done = 1;
    80000a62:	4785                	li	a5,1
    80000a64:	0000a717          	auipc	a4,0xa
    80000a68:	5af72223          	sw	a5,1444(a4) # 8000b008 <kvminit_done>
}
    80000a6c:	60e2                	ld	ra,24(sp)
    80000a6e:	6442                	ld	s0,16(sp)
    80000a70:	64a2                	ld	s1,8(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret

0000000080000a76 <kvminithart>:

void kvminithart() {
    80000a76:	1141                	addi	sp,sp,-16
    80000a78:	e422                	sd	s0,8(sp)
    80000a7a:	0800                	addi	s0,sp,16
    w_satp(MAKE_SATP(kernel_pgdir));
    80000a7c:	0000a797          	auipc	a5,0xa
    80000a80:	5947b783          	ld	a5,1428(a5) # 8000b010 <kernel_pgdir>
    80000a84:	577d                	li	a4,-1
    80000a86:	177e                	slli	a4,a4,0x3f
    80000a88:	83b1                	srli	a5,a5,0xc
    80000a8a:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    80000a8c:	18079073          	csrw	satp,a5
    return x;
}

static inline void sfence_vma() {
    asm volatile("sfence.vma");
    80000a90:	12000073          	sfence.vma
    sfence_vma();
}
    80000a94:	6422                	ld	s0,8(sp)
    80000a96:	0141                	addi	sp,sp,16
    80000a98:	8082                	ret

0000000080000a9a <kinit>:
    struct run *freelist;
} kmem;

extern char end;

void kinit() {
    80000a9a:	7139                	addi	sp,sp,-64
    80000a9c:	f822                	sd	s0,48(sp)
    80000a9e:	f426                	sd	s1,40(sp)
    80000aa0:	f04a                	sd	s2,32(sp)
    80000aa2:	fc06                	sd	ra,56(sp)
    80000aa4:	0080                	addi	s0,sp,64
    initlock(&kmem.lock, "kmem");
    80000aa6:	00000597          	auipc	a1,0x0
    80000aaa:	6d258593          	addi	a1,a1,1746 # 80001178 <kfree+0x5f0>
    80000aae:	00001517          	auipc	a0,0x1
    80000ab2:	56250513          	addi	a0,a0,1378 # 80002010 <kmem>
    80000ab6:	00000097          	auipc	ra,0x0
    80000aba:	de4080e7          	jalr	-540(ra) # 8000089a <initlock>
    char *p = (char *)PGROUNDUP((uint64)&end);
    80000abe:	77fd                	lui	a5,0xfffff
    80000ac0:	0000b497          	auipc	s1,0xb
    80000ac4:	53f48493          	addi	s1,s1,1343 # 8000bfff <kernel_pgdir+0xfef>
    80000ac8:	8cfd                	and	s1,s1,a5
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000aca:	4945                	li	s2,17
    80000acc:	6785                	lui	a5,0x1
    80000ace:	97a6                	add	a5,a5,s1
    80000ad0:	096e                	slli	s2,s2,0x1b
    80000ad2:	02f96c63          	bltu	s2,a5,80000b0a <kinit+0x70>
    80000ad6:	ec4e                	sd	s3,24(sp)
    80000ad8:	e852                	sd	s4,16(sp)
    80000ada:	e456                	sd	s5,8(sp)
    80000adc:	89a6                	mv	s3,s1
    80000ade:	6a05                	lui	s4,0x1
void kfree(void *pa) {
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
        return;
    }
    struct run *r = (struct run *)pa;
    acquire(&kmem.lock);
    80000ae0:	00001a97          	auipc	s5,0x1
    80000ae4:	530a8a93          	addi	s5,s5,1328 # 80002010 <kmem>
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
    80000ae8:	0134eb63          	bltu	s1,s3,80000afe <kinit+0x64>
    acquire(&kmem.lock);
    80000aec:	00001517          	auipc	a0,0x1
    80000af0:	52450513          	addi	a0,a0,1316 # 80002010 <kmem>
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
    80000af4:	0324e163          	bltu	s1,s2,80000b16 <kinit+0x7c>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000af8:	94d2                	add	s1,s1,s4
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
    80000afa:	ff34f9e3          	bgeu	s1,s3,80000aec <kinit+0x52>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000afe:	94d2                	add	s1,s1,s4
    80000b00:	ff2494e3          	bne	s1,s2,80000ae8 <kinit+0x4e>
    80000b04:	69e2                	ld	s3,24(sp)
    80000b06:	6a42                	ld	s4,16(sp)
    80000b08:	6aa2                	ld	s5,8(sp)
}
    80000b0a:	70e2                	ld	ra,56(sp)
    80000b0c:	7442                	ld	s0,48(sp)
    80000b0e:	74a2                	ld	s1,40(sp)
    80000b10:	7902                	ld	s2,32(sp)
    80000b12:	6121                	addi	sp,sp,64
    80000b14:	8082                	ret
    acquire(&kmem.lock);
    80000b16:	00000097          	auipc	ra,0x0
    80000b1a:	d96080e7          	jalr	-618(ra) # 800008ac <acquire>
    r->next = kmem.freelist;
    80000b1e:	010ab783          	ld	a5,16(s5)
    kmem.freelist = r;
    release(&kmem.lock);
    80000b22:	00001517          	auipc	a0,0x1
    80000b26:	4ee50513          	addi	a0,a0,1262 # 80002010 <kmem>
    r->next = kmem.freelist;
    80000b2a:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000b2c:	009ab823          	sd	s1,16(s5)
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000b30:	94d2                	add	s1,s1,s4
    release(&kmem.lock);
    80000b32:	00000097          	auipc	ra,0x0
    80000b36:	d9c080e7          	jalr	-612(ra) # 800008ce <release>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000b3a:	fb2497e3          	bne	s1,s2,80000ae8 <kinit+0x4e>
    80000b3e:	b7d9                	j	80000b04 <kinit+0x6a>

0000000080000b40 <kalloc>:
void *kalloc() {
    80000b40:	1101                	addi	sp,sp,-32
    80000b42:	e822                	sd	s0,16(sp)
    80000b44:	e426                	sd	s1,8(sp)
    80000b46:	e04a                	sd	s2,0(sp)
    80000b48:	ec06                	sd	ra,24(sp)
    80000b4a:	1000                	addi	s0,sp,32
    acquire(&kmem.lock);
    80000b4c:	00001917          	auipc	s2,0x1
    80000b50:	4c490913          	addi	s2,s2,1220 # 80002010 <kmem>
    80000b54:	854a                	mv	a0,s2
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	d56080e7          	jalr	-682(ra) # 800008ac <acquire>
    struct run *r = kmem.freelist;
    80000b5e:	01093483          	ld	s1,16(s2)
    if (r) {
    80000b62:	c481                	beqz	s1,80000b6a <kalloc+0x2a>
        kmem.freelist = r->next;
    80000b64:	609c                	ld	a5,0(s1)
    80000b66:	00f93823          	sd	a5,16(s2)
    release(&kmem.lock);
    80000b6a:	00001517          	auipc	a0,0x1
    80000b6e:	4a650513          	addi	a0,a0,1190 # 80002010 <kmem>
    80000b72:	00000097          	auipc	ra,0x0
    80000b76:	d5c080e7          	jalr	-676(ra) # 800008ce <release>
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	6902                	ld	s2,0(sp)
    80000b80:	8526                	mv	a0,s1
    80000b82:	64a2                	ld	s1,8(sp)
    80000b84:	6105                	addi	sp,sp,32
    80000b86:	8082                	ret

0000000080000b88 <kfree>:
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
    80000b88:	03451793          	slli	a5,a0,0x34
    80000b8c:	e3ad                	bnez	a5,80000bee <kfree+0x66>
void kfree(void *pa) {
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	e822                	sd	s0,16(sp)
    80000b92:	e426                	sd	s1,8(sp)
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	1000                	addi	s0,sp,32
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
    80000b98:	0000b797          	auipc	a5,0xb
    80000b9c:	46778793          	addi	a5,a5,1127 # 8000bfff <kernel_pgdir+0xfef>
    80000ba0:	777d                	lui	a4,0xfffff
    80000ba2:	8ff9                	and	a5,a5,a4
    80000ba4:	84aa                	mv	s1,a0
    80000ba6:	02f56f63          	bltu	a0,a5,80000be4 <kfree+0x5c>
    80000baa:	47c5                	li	a5,17
    80000bac:	07ee                	slli	a5,a5,0x1b
    80000bae:	02f57b63          	bgeu	a0,a5,80000be4 <kfree+0x5c>
    80000bb2:	e04a                	sd	s2,0(sp)
    acquire(&kmem.lock);
    80000bb4:	00001917          	auipc	s2,0x1
    80000bb8:	45c90913          	addi	s2,s2,1116 # 80002010 <kmem>
    80000bbc:	854a                	mv	a0,s2
    80000bbe:	00000097          	auipc	ra,0x0
    80000bc2:	cee080e7          	jalr	-786(ra) # 800008ac <acquire>
    r->next = kmem.freelist;
    80000bc6:	01093783          	ld	a5,16(s2)
}
    80000bca:	6442                	ld	s0,16(sp)
    80000bcc:	60e2                	ld	ra,24(sp)
    r->next = kmem.freelist;
    80000bce:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000bd0:	00993823          	sd	s1,16(s2)
    release(&kmem.lock);
    80000bd4:	854a                	mv	a0,s2
}
    80000bd6:	64a2                	ld	s1,8(sp)
    release(&kmem.lock);
    80000bd8:	6902                	ld	s2,0(sp)
}
    80000bda:	6105                	addi	sp,sp,32
    release(&kmem.lock);
    80000bdc:	00000317          	auipc	t1,0x0
    80000be0:	cf230067          	jr	-782(t1) # 800008ce <release>
}
    80000be4:	60e2                	ld	ra,24(sp)
    80000be6:	6442                	ld	s0,16(sp)
    80000be8:	64a2                	ld	s1,8(sp)
    80000bea:	6105                	addi	sp,sp,32
    80000bec:	8082                	ret
    80000bee:	8082                	ret
