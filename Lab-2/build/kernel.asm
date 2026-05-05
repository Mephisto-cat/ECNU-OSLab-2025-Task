
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
    8000001a:	89e080e7          	jalr	-1890(ra) # 800008b4 <start>

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
    8000002e:	46a080e7          	jalr	1130(ra) # 80000494 <uartinit>
    printf("\n");
    80000032:	00001517          	auipc	a0,0x1
    80000036:	bae50513          	addi	a0,a0,-1106 # 80000be0 <kfree+0x6e>
    int cpuid = r_cpuid();
    8000003a:	2981                	sext.w	s3,s3
    printf("\n");
    8000003c:	00000097          	auipc	ra,0x0
    80000040:	546080e7          	jalr	1350(ra) # 80000582 <printf>
    printf("cpu %d is booting\n", cpuid);
    80000044:	85ce                	mv	a1,s3
    80000046:	00001517          	auipc	a0,0x1
    8000004a:	ba250513          	addi	a0,a0,-1118 # 80000be8 <kfree+0x76>
    8000004e:	00000097          	auipc	ra,0x0
    80000052:	534080e7          	jalr	1332(ra) # 80000582 <printf>

    if (cpuid == 0) {
    80000056:	3c098863          	beqz	s3,80000426 <main+0x408>
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
    8000006a:	9d8080e7          	jalr	-1576(ra) # 80000a3e <kvminithart>
    asm volatile("csrw satp, %0" : : "r"(x));
}

static inline uint64 r_satp() {
    uint64 x;
    asm volatile("csrr %0, satp" : "=r"(x));
    8000006e:	18002673          	csrr	a2,satp
    printf("[cpu %d] kvminithart: satp = %p, paging enabled\n",
    80000072:	00001517          	auipc	a0,0x1
    80000076:	bee50513          	addi	a0,a0,-1042 # 80000c60 <kfree+0xee>
    8000007a:	85ce                	mv	a1,s3
    8000007c:	00000097          	auipc	ra,0x0
    80000080:	506080e7          	jalr	1286(ra) # 80000582 <printf>
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
    80000098:	c0450513          	addi	a0,a0,-1020 # 80000c98 <kfree+0x126>
    8000009c:	fc26                	sd	s1,56(sp)
    8000009e:	f84a                	sd	s2,48(sp)
    800000a0:	f052                	sd	s4,32(sp)
    800000a2:	00000097          	auipc	ra,0x0
    800000a6:	4e0080e7          	jalr	1248(ra) # 80000582 <printf>
        void *p1 = kalloc();
    800000aa:	00001097          	auipc	ra,0x1
    800000ae:	a5e080e7          	jalr	-1442(ra) # 80000b08 <kalloc>
    800000b2:	84aa                	mv	s1,a0
        void *p2 = kalloc();
    800000b4:	00001097          	auipc	ra,0x1
    800000b8:	a54080e7          	jalr	-1452(ra) # 80000b08 <kalloc>
        printf("[cpu %d] alloc  p1=%p p2=%p\n", cpuid, p1, p2);
    800000bc:	86aa                	mv	a3,a0
    800000be:	8626                	mv	a2,s1
        void *p2 = kalloc();
    800000c0:	892a                	mv	s2,a0
        printf("[cpu %d] alloc  p1=%p p2=%p\n", cpuid, p1, p2);
    800000c2:	4581                	li	a1,0
    800000c4:	00001517          	auipc	a0,0x1
    800000c8:	c0450513          	addi	a0,a0,-1020 # 80000cc8 <kfree+0x156>
    800000cc:	00000097          	auipc	ra,0x0
    800000d0:	4b6080e7          	jalr	1206(ra) # 80000582 <printf>
        printf("[cpu %d] expect: p1!=0, p2!=0, p1!=p2\n", cpuid);
    800000d4:	4581                	li	a1,0
    800000d6:	00001517          	auipc	a0,0x1
    800000da:	c1250513          	addi	a0,a0,-1006 # 80000ce8 <kfree+0x176>
    800000de:	00000097          	auipc	ra,0x0
    800000e2:	4a4080e7          	jalr	1188(ra) # 80000582 <printf>
        kfree(p1);
    800000e6:	8526                	mv	a0,s1
    800000e8:	00001097          	auipc	ra,0x1
    800000ec:	a8a080e7          	jalr	-1398(ra) # 80000b72 <kfree>
        kfree(p2);
    800000f0:	854a                	mv	a0,s2
    800000f2:	00001097          	auipc	ra,0x1
    800000f6:	a80080e7          	jalr	-1408(ra) # 80000b72 <kfree>
        printf("[cpu %d] free   p1=%p p2=%p\n", cpuid, p1, p2);
    800000fa:	86ca                	mv	a3,s2
    800000fc:	8626                	mv	a2,s1
    800000fe:	4581                	li	a1,0
    80000100:	00001517          	auipc	a0,0x1
    80000104:	c1050513          	addi	a0,a0,-1008 # 80000d10 <kfree+0x19e>
    80000108:	00000097          	auipc	ra,0x0
    8000010c:	47a080e7          	jalr	1146(ra) # 80000582 <printf>
        printf("[cpu %d] --- test2: reuse after free ---\n", cpuid);
    80000110:	4581                	li	a1,0
    80000112:	00001517          	auipc	a0,0x1
    80000116:	c1e50513          	addi	a0,a0,-994 # 80000d30 <kfree+0x1be>
    8000011a:	00000097          	auipc	ra,0x0
    8000011e:	468080e7          	jalr	1128(ra) # 80000582 <printf>
        void *p3 = kalloc();
    80000122:	00001097          	auipc	ra,0x1
    80000126:	9e6080e7          	jalr	-1562(ra) # 80000b08 <kalloc>
        printf("[cpu %d] re-alloc after free: p3=%p\n", cpuid, p3);
    8000012a:	862a                	mv	a2,a0
        void *p3 = kalloc();
    8000012c:	84aa                	mv	s1,a0
        printf("[cpu %d] re-alloc after free: p3=%p\n", cpuid, p3);
    8000012e:	4581                	li	a1,0
    80000130:	00001517          	auipc	a0,0x1
    80000134:	c3050513          	addi	a0,a0,-976 # 80000d60 <kfree+0x1ee>
    80000138:	00000097          	auipc	ra,0x0
    8000013c:	44a080e7          	jalr	1098(ra) # 80000582 <printf>
        printf("[cpu %d] expect: p3==p2 (LIFO, last freed first)\n", cpuid);
    80000140:	4581                	li	a1,0
    80000142:	00001517          	auipc	a0,0x1
    80000146:	c4650513          	addi	a0,a0,-954 # 80000d88 <kfree+0x216>
    8000014a:	00000097          	auipc	ra,0x0
    8000014e:	438080e7          	jalr	1080(ra) # 80000582 <printf>
        kfree(p3);
    80000152:	8526                	mv	a0,s1
    80000154:	00001097          	auipc	ra,0x1
    80000158:	a1e080e7          	jalr	-1506(ra) # 80000b72 <kfree>
        printf("[cpu %d] --- test3: zero-fill ---\n", cpuid);
    8000015c:	4581                	li	a1,0
    8000015e:	00001517          	auipc	a0,0x1
    80000162:	c6250513          	addi	a0,a0,-926 # 80000dc0 <kfree+0x24e>
    80000166:	00000097          	auipc	ra,0x0
    8000016a:	41c080e7          	jalr	1052(ra) # 80000582 <printf>
        char *zp = (char *)kalloc();
    8000016e:	00001097          	auipc	ra,0x1
    80000172:	99a080e7          	jalr	-1638(ra) # 80000b08 <kalloc>
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
    8000018c:	ff279be3          	bne	a5,s2,80000182 <main+0x164>
        printf("[cpu %d] zero-fill check: %d/%d bytes non-zero\n",
    80000190:	6685                	lui	a3,0x1
    80000192:	4581                	li	a1,0
    80000194:	00001517          	auipc	a0,0x1
    80000198:	c5450513          	addi	a0,a0,-940 # 80000de8 <kfree+0x276>
    8000019c:	00000097          	auipc	ra,0x0
    800001a0:	3e6080e7          	jalr	998(ra) # 80000582 <printf>
        printf("[cpu %d] expect: 0\n", cpuid);
    800001a4:	4581                	li	a1,0
    800001a6:	00001517          	auipc	a0,0x1
    800001aa:	c7250513          	addi	a0,a0,-910 # 80000e18 <kfree+0x2a6>
    800001ae:	00000097          	auipc	ra,0x0
    800001b2:	3d4080e7          	jalr	980(ra) # 80000582 <printf>
            zp[i] = 0xFF;
    800001b6:	57fd                	li	a5,-1
    800001b8:	00f48023          	sb	a5,0(s1)
        for (int i = 0; i < PGSIZE; i++) {
    800001bc:	0485                	addi	s1,s1,1
    800001be:	ff249de3          	bne	s1,s2,800001b8 <main+0x19a>
        kfree(zp);
    800001c2:	8552                	mv	a0,s4
    800001c4:	00001097          	auipc	ra,0x1
    800001c8:	9ae080e7          	jalr	-1618(ra) # 80000b72 <kfree>
        zp = (char *)kalloc();
    800001cc:	00001097          	auipc	ra,0x1
    800001d0:	93c080e7          	jalr	-1732(ra) # 80000b08 <kalloc>
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
    800001e8:	fed79be3          	bne	a5,a3,800001de <main+0x1c0>
        printf("[cpu %d] dirty-then-realloc zero check: %d/%d bytes non-zero\n",
    800001ec:	6685                	lui	a3,0x1
    800001ee:	4581                	li	a1,0
    800001f0:	00001517          	auipc	a0,0x1
    800001f4:	c4050513          	addi	a0,a0,-960 # 80000e30 <kfree+0x2be>
    800001f8:	00000097          	auipc	ra,0x0
    800001fc:	38a080e7          	jalr	906(ra) # 80000582 <printf>
        printf("[cpu %d] expect: 0\n", cpuid);
    80000200:	4581                	li	a1,0
    80000202:	00001517          	auipc	a0,0x1
    80000206:	c1650513          	addi	a0,a0,-1002 # 80000e18 <kfree+0x2a6>
    8000020a:	00000097          	auipc	ra,0x0
    8000020e:	378080e7          	jalr	888(ra) # 80000582 <printf>
        kfree(zp);
    80000212:	8526                	mv	a0,s1
    80000214:	00001097          	auipc	ra,0x1
    80000218:	95e080e7          	jalr	-1698(ra) # 80000b72 <kfree>
        printf("[cpu %d] --- test4: kfree rejects bad addresses ---\n", cpuid);
    8000021c:	4581                	li	a1,0
    8000021e:	00001517          	auipc	a0,0x1
    80000222:	c5250513          	addi	a0,a0,-942 # 80000e70 <kfree+0x2fe>
    80000226:	00000097          	auipc	ra,0x0
    8000022a:	35c080e7          	jalr	860(ra) # 80000582 <printf>
        kfree((void *)0x80001001);
    8000022e:	00080537          	lui	a0,0x80
    80000232:	0505                	addi	a0,a0,1 # 80001 <_entry-0x7ff7ffff>
    80000234:	0532                	slli	a0,a0,0xc
    80000236:	0505                	addi	a0,a0,1
    80000238:	00001097          	auipc	ra,0x1
    8000023c:	93a080e7          	jalr	-1734(ra) # 80000b72 <kfree>
        kfree((void *)0x80000000);
    80000240:	4505                	li	a0,1
    80000242:	057e                	slli	a0,a0,0x1f
    80000244:	00001097          	auipc	ra,0x1
    80000248:	92e080e7          	jalr	-1746(ra) # 80000b72 <kfree>
        kfree((void *)0x88000000);
    8000024c:	4545                	li	a0,17
    8000024e:	056e                	slli	a0,a0,0x1b
    80000250:	00001097          	auipc	ra,0x1
    80000254:	922080e7          	jalr	-1758(ra) # 80000b72 <kfree>
        void *p4 = kalloc();
    80000258:	00001097          	auipc	ra,0x1
    8000025c:	8b0080e7          	jalr	-1872(ra) # 80000b08 <kalloc>
        printf("[cpu %d] alloc after bad frees: p4=%p\n", cpuid, p4);
    80000260:	862a                	mv	a2,a0
        void *p4 = kalloc();
    80000262:	84aa                	mv	s1,a0
        printf("[cpu %d] alloc after bad frees: p4=%p\n", cpuid, p4);
    80000264:	4581                	li	a1,0
    80000266:	00001517          	auipc	a0,0x1
    8000026a:	c4250513          	addi	a0,a0,-958 # 80000ea8 <kfree+0x336>
    8000026e:	00000097          	auipc	ra,0x0
    80000272:	314080e7          	jalr	788(ra) # 80000582 <printf>
        printf("[cpu %d] expect: p4!=0 (bad frees silently ignored)\n", cpuid);
    80000276:	4581                	li	a1,0
    80000278:	00001517          	auipc	a0,0x1
    8000027c:	c5850513          	addi	a0,a0,-936 # 80000ed0 <kfree+0x35e>
    80000280:	00000097          	auipc	ra,0x0
    80000284:	302080e7          	jalr	770(ra) # 80000582 <printf>
        kfree(p4);
    80000288:	8526                	mv	a0,s1
    8000028a:	00001097          	auipc	ra,0x1
    8000028e:	8e8080e7          	jalr	-1816(ra) # 80000b72 <kfree>
        printf("[cpu %d] --- test5: exhaustion ---\n", cpuid);
    80000292:	4581                	li	a1,0
    80000294:	00001517          	auipc	a0,0x1
    80000298:	c7450513          	addi	a0,a0,-908 # 80000f08 <kfree+0x396>
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	2e6080e7          	jalr	742(ra) # 80000582 <printf>
        int count = 0;
    800002a4:	fb840493          	addi	s1,s0,-72
            if (count < 3) saved[count] = q;
    800002a8:	4909                	li	s2,2
            void *q = kalloc();
    800002aa:	00001097          	auipc	ra,0x1
    800002ae:	85e080e7          	jalr	-1954(ra) # 80000b08 <kalloc>
            if (q == 0) break;
    800002b2:	c919                	beqz	a0,800002c8 <main+0x2aa>
            if (count < 3) saved[count] = q;
    800002b4:	01394363          	blt	s2,s3,800002ba <main+0x29c>
    800002b8:	e088                	sd	a0,0(s1)
            count++;
    800002ba:	2985                	addiw	s3,s3,1
        while (1) {
    800002bc:	04a1                	addi	s1,s1,8
            void *q = kalloc();
    800002be:	00001097          	auipc	ra,0x1
    800002c2:	84a080e7          	jalr	-1974(ra) # 80000b08 <kalloc>
            if (q == 0) break;
    800002c6:	f57d                	bnez	a0,800002b4 <main+0x296>
        printf("[cpu %d] allocated %d pages before NULL\n", cpuid, count);
    800002c8:	864e                	mv	a2,s3
    800002ca:	4581                	li	a1,0
    800002cc:	00001517          	auipc	a0,0x1
    800002d0:	c6450513          	addi	a0,a0,-924 # 80000f30 <kfree+0x3be>
    800002d4:	00000097          	auipc	ra,0x0
    800002d8:	2ae080e7          	jalr	686(ra) # 80000582 <printf>
        printf("[cpu %d] expect: >1000\n", cpuid);
    800002dc:	4581                	li	a1,0
    800002de:	00001517          	auipc	a0,0x1
    800002e2:	c8250513          	addi	a0,a0,-894 # 80000f60 <kfree+0x3ee>
    800002e6:	00000097          	auipc	ra,0x0
    800002ea:	29c080e7          	jalr	668(ra) # 80000582 <printf>
        printf("[cpu %d] --- test6: free-then-reuse after exhaustion ---\n", cpuid);
    800002ee:	4581                	li	a1,0
    800002f0:	00001517          	auipc	a0,0x1
    800002f4:	c8850513          	addi	a0,a0,-888 # 80000f78 <kfree+0x406>
    800002f8:	00000097          	auipc	ra,0x0
    800002fc:	28a080e7          	jalr	650(ra) # 80000582 <printf>
        void *check = kalloc();
    80000300:	00001097          	auipc	ra,0x1
    80000304:	808080e7          	jalr	-2040(ra) # 80000b08 <kalloc>
    80000308:	84aa                	mv	s1,a0
        printf("[cpu %d] kalloc after exhaustion: %p\n", cpuid, check);
    8000030a:	862a                	mv	a2,a0
    8000030c:	4581                	li	a1,0
    8000030e:	00001517          	auipc	a0,0x1
    80000312:	caa50513          	addi	a0,a0,-854 # 80000fb8 <kfree+0x446>
    80000316:	00000097          	auipc	ra,0x0
    8000031a:	26c080e7          	jalr	620(ra) # 80000582 <printf>
        printf("[cpu %d] expect: 0x0 (really out of memory)\n", cpuid);
    8000031e:	4581                	li	a1,0
    80000320:	00001517          	auipc	a0,0x1
    80000324:	cc050513          	addi	a0,a0,-832 # 80000fe0 <kfree+0x46e>
    80000328:	00000097          	auipc	ra,0x0
    8000032c:	25a080e7          	jalr	602(ra) # 80000582 <printf>
        if (check != 0) kfree(check);
    80000330:	c491                	beqz	s1,8000033c <main+0x31e>
    80000332:	8526                	mv	a0,s1
    80000334:	00001097          	auipc	ra,0x1
    80000338:	83e080e7          	jalr	-1986(ra) # 80000b72 <kfree>
        kfree(saved[2]);
    8000033c:	fc843a03          	ld	s4,-56(s0)
    80000340:	8552                	mv	a0,s4
    80000342:	00001097          	auipc	ra,0x1
    80000346:	830080e7          	jalr	-2000(ra) # 80000b72 <kfree>
        kfree(saved[1]);
    8000034a:	fc043983          	ld	s3,-64(s0)
    8000034e:	854e                	mv	a0,s3
    80000350:	00001097          	auipc	ra,0x1
    80000354:	822080e7          	jalr	-2014(ra) # 80000b72 <kfree>
        void *r1 = kalloc();
    80000358:	00000097          	auipc	ra,0x0
    8000035c:	7b0080e7          	jalr	1968(ra) # 80000b08 <kalloc>
    80000360:	84aa                	mv	s1,a0
        void *r2 = kalloc();
    80000362:	00000097          	auipc	ra,0x0
    80000366:	7a6080e7          	jalr	1958(ra) # 80000b08 <kalloc>
    8000036a:	892a                	mv	s2,a0
        printf("[cpu %d] freed 2 pages, re-alloc'd r1=%p r2=%p\n", cpuid, r1, r2);
    8000036c:	86aa                	mv	a3,a0
    8000036e:	8626                	mv	a2,s1
    80000370:	4581                	li	a1,0
    80000372:	00001517          	auipc	a0,0x1
    80000376:	c9e50513          	addi	a0,a0,-866 # 80001010 <kfree+0x49e>
    8000037a:	00000097          	auipc	ra,0x0
    8000037e:	208080e7          	jalr	520(ra) # 80000582 <printf>
        printf("[cpu %d] expect: r1==%p r2==%p (LIFO)\n", cpuid, saved[1], saved[2]);
    80000382:	86d2                	mv	a3,s4
    80000384:	864e                	mv	a2,s3
    80000386:	4581                	li	a1,0
    80000388:	00001517          	auipc	a0,0x1
    8000038c:	cb850513          	addi	a0,a0,-840 # 80001040 <kfree+0x4ce>
    80000390:	00000097          	auipc	ra,0x0
    80000394:	1f2080e7          	jalr	498(ra) # 80000582 <printf>
        kfree(r2);
    80000398:	854a                	mv	a0,s2
    8000039a:	00000097          	auipc	ra,0x0
    8000039e:	7d8080e7          	jalr	2008(ra) # 80000b72 <kfree>
        kfree(r1);
    800003a2:	8526                	mv	a0,s1
    800003a4:	00000097          	auipc	ra,0x0
    800003a8:	7ce080e7          	jalr	1998(ra) # 80000b72 <kfree>
        kfree(saved[0]);
    800003ac:	fb843503          	ld	a0,-72(s0)
    800003b0:	00000097          	auipc	ra,0x0
    800003b4:	7c2080e7          	jalr	1986(ra) # 80000b72 <kfree>
        printf("[cpu %d] --- test7: identity mapping ---\n", cpuid);
    800003b8:	4581                	li	a1,0
    800003ba:	00001517          	auipc	a0,0x1
    800003be:	cae50513          	addi	a0,a0,-850 # 80001068 <kfree+0x4f6>
    800003c2:	00000097          	auipc	ra,0x0
    800003c6:	1c0080e7          	jalr	448(ra) # 80000582 <printf>
    asm volatile("csrr %0, satp" : "=r"(x));
    800003ca:	18002673          	csrr	a2,satp
        printf("[cpu %d] satp=%p, mode=%d (8=Sv39)\n",
    800003ce:	4581                	li	a1,0
    800003d0:	03c65693          	srli	a3,a2,0x3c
    800003d4:	00001517          	auipc	a0,0x1
    800003d8:	cc450513          	addi	a0,a0,-828 # 80001098 <kfree+0x526>
    800003dc:	00000097          	auipc	ra,0x0
    800003e0:	1a6080e7          	jalr	422(ra) # 80000582 <printf>
        printf("[cpu %d] expect: mode=8\n", cpuid);
    800003e4:	4581                	li	a1,0
    800003e6:	00001517          	auipc	a0,0x1
    800003ea:	cda50513          	addi	a0,a0,-806 # 800010c0 <kfree+0x54e>
    800003ee:	00000097          	auipc	ra,0x0
    800003f2:	194080e7          	jalr	404(ra) # 80000582 <printf>
        printf("[cpu %d] printf after paging ON proves identity map works\n", cpuid);
    800003f6:	4581                	li	a1,0
    800003f8:	00001517          	auipc	a0,0x1
    800003fc:	ce850513          	addi	a0,a0,-792 # 800010e0 <kfree+0x56e>
    80000400:	00000097          	auipc	ra,0x0
    80000404:	182080e7          	jalr	386(ra) # 80000582 <printf>
        printf("[cpu %d] === ALL TESTS PASSED ===\n", cpuid);
    80000408:	4581                	li	a1,0
    8000040a:	00001517          	auipc	a0,0x1
    8000040e:	d1650513          	addi	a0,a0,-746 # 80001120 <kfree+0x5ae>
    80000412:	00000097          	auipc	ra,0x0
    80000416:	170080e7          	jalr	368(ra) # 80000582 <printf>
    8000041a:	74e2                	ld	s1,56(sp)
    8000041c:	7942                	ld	s2,48(sp)
    8000041e:	7a02                	ld	s4,32(sp)
    asm volatile("wfi");
    80000420:	10500073          	wfi
    for (;;) {
    80000424:	b1a5                	j	8000008c <main+0x6e>
        kinit();
    80000426:	00000097          	auipc	ra,0x0
    8000042a:	63c080e7          	jalr	1596(ra) # 80000a62 <kinit>
        printf("[cpu %d] kinit: free list built from %p to %p\n",
    8000042e:	46c5                	li	a3,17
    80000430:	4605                	li	a2,1
    80000432:	06ee                	slli	a3,a3,0x1b
    80000434:	067e                	slli	a2,a2,0x1f
    80000436:	4581                	li	a1,0
    80000438:	00000517          	auipc	a0,0x0
    8000043c:	7c850513          	addi	a0,a0,1992 # 80000c00 <kfree+0x8e>
    80000440:	00000097          	auipc	ra,0x0
    80000444:	142080e7          	jalr	322(ra) # 80000582 <printf>
        kvminit();
    80000448:	00000097          	auipc	ra,0x0
    8000044c:	59a080e7          	jalr	1434(ra) # 800009e2 <kvminit>
        printf("[cpu %d] kvminit: kernel page table at %p\n",
    80000450:	0000b617          	auipc	a2,0xb
    80000454:	bc063603          	ld	a2,-1088(a2) # 8000b010 <kernel_pgdir>
    80000458:	4581                	li	a1,0
    8000045a:	00000517          	auipc	a0,0x0
    8000045e:	7d650513          	addi	a0,a0,2006 # 80000c30 <kfree+0xbe>
    80000462:	00000097          	auipc	ra,0x0
    80000466:	120080e7          	jalr	288(ra) # 80000582 <printf>
    8000046a:	bec5                	j	8000005a <main+0x3c>

000000008000046c <my_put>:
#define IER_TX_ENABLE   0x01
#define LSR_TX_IDLE     0x20

static volatile uint8 *const uart = (volatile uint8 *)UART0;

void my_put(int c) {
    8000046c:	1141                	addi	sp,sp,-16
    8000046e:	e422                	sd	s0,8(sp)
    while ((uart[LSR] & LSR_TX_IDLE) == 0) {}
    80000470:	10000737          	lui	a4,0x10000
void my_put(int c) {
    80000474:	0800                	addi	s0,sp,16
    while ((uart[LSR] & LSR_TX_IDLE) == 0) {}
    80000476:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000478:	00074783          	lbu	a5,0(a4)
    8000047c:	0207f793          	andi	a5,a5,32
    80000480:	dfe5                	beqz	a5,80000478 <my_put+0xc>
    uart[THR] = (uint8)c;
    80000482:	0ff57513          	zext.b	a0,a0
    80000486:	100007b7          	lui	a5,0x10000
    8000048a:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    8000048e:	6422                	ld	s0,8(sp)
    80000490:	0141                	addi	sp,sp,16
    80000492:	8082                	ret

0000000080000494 <uartinit>:

void uartinit() {
    80000494:	1141                	addi	sp,sp,-16
    80000496:	e422                	sd	s0,8(sp)
    80000498:	0800                	addi	s0,sp,16
    uart[IER] = 0x00;
    8000049a:	100007b7          	lui	a5,0x10000
    8000049e:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    uart[LCR] = LCR_BAUD_LATCH;
    800004a2:	10000737          	lui	a4,0x10000
    800004a6:	f8000693          	li	a3,-128
    800004aa:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>
    uart[0] = 0x03;
    800004ae:	460d                	li	a2,3
    uart[IER] = 0x00;
    800004b0:	100006b7          	lui	a3,0x10000
    uart[0] = 0x03;
    800004b4:	00c68023          	sb	a2,0(a3) # 10000000 <_entry-0x70000000>
    uart[1] = 0x00;
    800004b8:	000780a3          	sb	zero,1(a5)
    uart[LCR] = LCR_EIGHT_BITS;
    800004bc:	00c701a3          	sb	a2,3(a4)
    uart[FCR] = FCR_FIFO_ENABLE | FCR_FIFO_CLEAR;
    800004c0:	471d                	li	a4,7
    800004c2:	00e68123          	sb	a4,2(a3)
    uart[IER] = IER_TX_ENABLE;
    800004c6:	4705                	li	a4,1
    800004c8:	00e780a3          	sb	a4,1(a5)
}
    800004cc:	6422                	ld	s0,8(sp)
    800004ce:	0141                	addi	sp,sp,16
    800004d0:	8082                	ret

00000000800004d2 <printint>:
        my_put('\r');
    }
    my_put(c);
}

static void printint(int64 xx, int base, int sign) {
    800004d2:	715d                	addi	sp,sp,-80
    800004d4:	e0a2                	sd	s0,64(sp)
    800004d6:	e486                	sd	ra,72(sp)
    800004d8:	fc26                	sd	s1,56(sp)
    800004da:	f84a                	sd	s2,48(sp)
    800004dc:	f44e                	sd	s3,40(sp)
    800004de:	f052                	sd	s4,32(sp)
    800004e0:	0880                	addi	s0,sp,80
    char buf[32];
    uint64 x;
    if (sign && xx < 0) {
    800004e2:	c609                	beqz	a2,800004ec <printint+0x1a>
        x = (uint64)(-xx);
    800004e4:	40a007b3          	neg	a5,a0
    if (sign && xx < 0) {
    800004e8:	00054363          	bltz	a0,800004ee <printint+0x1c>
    } else {
        x = (uint64)xx;
    800004ec:	87aa                	mv	a5,a0
    }
    int i = 0;
    do {
        buf[i++] = digits[x % base];
    800004ee:	fb040693          	addi	a3,s0,-80
    800004f2:	4801                	li	a6,0
    800004f4:	00001317          	auipc	t1,0x1
    800004f8:	cc430313          	addi	t1,t1,-828 # 800011b8 <digits>
    800004fc:	02b7f733          	remu	a4,a5,a1
        x /= base;
    } while (x != 0);
    80000500:	0685                	addi	a3,a3,1
    80000502:	88be                	mv	a7,a5
    80000504:	84c2                	mv	s1,a6
        buf[i++] = digits[x % base];
    80000506:	2805                	addiw	a6,a6,1
    80000508:	971a                	add	a4,a4,t1
    8000050a:	00074703          	lbu	a4,0(a4)
        x /= base;
    8000050e:	02b7d7b3          	divu	a5,a5,a1
        buf[i++] = digits[x % base];
    80000512:	fee68fa3          	sb	a4,-1(a3)
    } while (x != 0);
    80000516:	feb8f3e3          	bgeu	a7,a1,800004fc <printint+0x2a>
    if (sign && xx < 0) {
    8000051a:	c219                	beqz	a2,80000520 <printint+0x4e>
    8000051c:	04054a63          	bltz	a0,80000570 <printint+0x9e>
    80000520:	fb040793          	addi	a5,s0,-80
    80000524:	94be                	add	s1,s1,a5
    80000526:	fff78993          	addi	s3,a5,-1
    if (c == '\n') {
    8000052a:	4a29                	li	s4,10
    8000052c:	a809                	j	8000053e <printint+0x6c>
    my_put(c);
    8000052e:	854a                	mv	a0,s2
        buf[i++] = '-';
    }
    while (--i >= 0) {
    80000530:	14fd                	addi	s1,s1,-1
    my_put(c);
    80000532:	00000097          	auipc	ra,0x0
    80000536:	f3a080e7          	jalr	-198(ra) # 8000046c <my_put>
    while (--i >= 0) {
    8000053a:	03348363          	beq	s1,s3,80000560 <printint+0x8e>
        putc(buf[i]);
    8000053e:	0004c903          	lbu	s2,0(s1)
    if (c == '\n') {
    80000542:	ff4916e3          	bne	s2,s4,8000052e <printint+0x5c>
        my_put('\r');
    80000546:	4535                	li	a0,13
    80000548:	00000097          	auipc	ra,0x0
    8000054c:	f24080e7          	jalr	-220(ra) # 8000046c <my_put>
    my_put(c);
    80000550:	854a                	mv	a0,s2
    while (--i >= 0) {
    80000552:	14fd                	addi	s1,s1,-1
    my_put(c);
    80000554:	00000097          	auipc	ra,0x0
    80000558:	f18080e7          	jalr	-232(ra) # 8000046c <my_put>
    while (--i >= 0) {
    8000055c:	ff3491e3          	bne	s1,s3,8000053e <printint+0x6c>
    }
}
    80000560:	60a6                	ld	ra,72(sp)
    80000562:	6406                	ld	s0,64(sp)
    80000564:	74e2                	ld	s1,56(sp)
    80000566:	7942                	ld	s2,48(sp)
    80000568:	79a2                	ld	s3,40(sp)
    8000056a:	7a02                	ld	s4,32(sp)
    8000056c:	6161                	addi	sp,sp,80
    8000056e:	8082                	ret
        buf[i++] = '-';
    80000570:	fd080793          	addi	a5,a6,-48
    80000574:	97a2                	add	a5,a5,s0
    80000576:	02d00713          	li	a4,45
    8000057a:	fee78023          	sb	a4,-32(a5)
    while (--i >= 0) {
    8000057e:	84c2                	mv	s1,a6
    80000580:	b745                	j	80000520 <printint+0x4e>

0000000080000582 <printf>:
}

static struct spinlock pr_lock;
static int pr_lock_inited;

void printf(const char *fmt, ...) {
    80000582:	7131                	addi	sp,sp,-192
    80000584:	f8a2                	sd	s0,112(sp)
    80000586:	f4a6                	sd	s1,104(sp)
    80000588:	0100                	addi	s0,sp,128
    8000058a:	f0ca                	sd	s2,96(sp)
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	ecce                	sd	s3,88(sp)
    int c;
    const char *s;
    va_list ap;
    if (!pr_lock_inited) {
    80000590:	0000b917          	auipc	s2,0xb
    80000594:	a7090913          	addi	s2,s2,-1424 # 8000b000 <pr_lock_inited>
    80000598:	00092303          	lw	t1,0(s2)
void printf(const char *fmt, ...) {
    8000059c:	e40c                	sd	a1,8(s0)
    8000059e:	e810                	sd	a2,16(s0)
    800005a0:	ec14                	sd	a3,24(s0)
    800005a2:	f018                	sd	a4,32(s0)
    800005a4:	f41c                	sd	a5,40(s0)
    800005a6:	03043823          	sd	a6,48(s0)
    800005aa:	03143c23          	sd	a7,56(s0)
    800005ae:	84aa                	mv	s1,a0
    if (!pr_lock_inited) {
    800005b0:	20030b63          	beqz	t1,800007c6 <printf+0x244>
        initlock(&pr_lock, "printf");
        pr_lock_inited = 1;
    }
    acquire(&pr_lock);
    800005b4:	00002517          	auipc	a0,0x2
    800005b8:	a4c50513          	addi	a0,a0,-1460 # 80002000 <pr_lock>
    800005bc:	00000097          	auipc	ra,0x0
    800005c0:	2b8080e7          	jalr	696(ra) # 80000874 <acquire>
    va_start(ap, fmt);
    for (; (c = *fmt) != 0; fmt++) {
    800005c4:	0004c983          	lbu	s3,0(s1)
    va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
    for (; (c = *fmt) != 0; fmt++) {
    800005d0:	06098c63          	beqz	s3,80000648 <printf+0xc6>
    800005d4:	fc5e                	sd	s7,56(sp)
    800005d6:	f862                	sd	s8,48(sp)
    800005d8:	f466                	sd	s9,40(sp)
    800005da:	e8d2                	sd	s4,80(sp)
    800005dc:	e4d6                	sd	s5,72(sp)
        if (c != '%') { putc(c); continue; }
    800005de:	02500913          	li	s2,37
        fmt++;
        if (*fmt == 0) break;
        switch (*fmt) {
    800005e2:	4c55                	li	s8,21
    800005e4:	00001b97          	auipc	s7,0x1
    800005e8:	b7cb8b93          	addi	s7,s7,-1156 # 80001160 <kfree+0x5ee>
    if (c == '\n') {
    800005ec:	4ca9                	li	s9,10
        if (c != '%') { putc(c); continue; }
    800005ee:	1b299763          	bne	s3,s2,8000079c <printf+0x21a>
        if (*fmt == 0) break;
    800005f2:	0014c783          	lbu	a5,1(s1)
    800005f6:	c7a1                	beqz	a5,8000063e <printf+0xbc>
        switch (*fmt) {
    800005f8:	1b278a63          	beq	a5,s2,800007ac <printf+0x22a>
    800005fc:	f9d7879b          	addiw	a5,a5,-99
    80000600:	0ff7f793          	zext.b	a5,a5
    80000604:	00fc6763          	bltu	s8,a5,80000612 <printf+0x90>
    80000608:	078a                	slli	a5,a5,0x2
    8000060a:	97de                	add	a5,a5,s7
    8000060c:	439c                	lw	a5,0(a5)
    8000060e:	97de                	add	a5,a5,s7
    80000610:	8782                	jr	a5
    my_put(c);
    80000612:	02500513          	li	a0,37
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	e56080e7          	jalr	-426(ra) # 8000046c <my_put>
            if (s == 0) s = "(null)";
            while (*s) putc(*s++);
            break;
        case 'c': putc(va_arg(ap, int)); break;
        case '%': putc('%'); break;
        default:  putc('%'); putc(*fmt); break;
    8000061e:	0014c983          	lbu	s3,1(s1)
    if (c == '\n') {
    80000622:	47a9                	li	a5,10
    80000624:	16f98663          	beq	s3,a5,80000790 <printf+0x20e>
    my_put(c);
    80000628:	854e                	mv	a0,s3
    8000062a:	00000097          	auipc	ra,0x0
    8000062e:	e42080e7          	jalr	-446(ra) # 8000046c <my_put>
        fmt++;
    80000632:	0485                	addi	s1,s1,1
    for (; (c = *fmt) != 0; fmt++) {
    80000634:	0014c983          	lbu	s3,1(s1)
    80000638:	0485                	addi	s1,s1,1
    8000063a:	fa099ae3          	bnez	s3,800005ee <printf+0x6c>
    8000063e:	6a46                	ld	s4,80(sp)
    80000640:	6aa6                	ld	s5,72(sp)
    80000642:	7be2                	ld	s7,56(sp)
    80000644:	7c42                	ld	s8,48(sp)
    80000646:	7ca2                	ld	s9,40(sp)
        }
    }
    va_end(ap);
    release(&pr_lock);
    80000648:	00002517          	auipc	a0,0x2
    8000064c:	9b850513          	addi	a0,a0,-1608 # 80002000 <pr_lock>
    80000650:	00000097          	auipc	ra,0x0
    80000654:	246080e7          	jalr	582(ra) # 80000896 <release>
}
    80000658:	70e6                	ld	ra,120(sp)
    8000065a:	7446                	ld	s0,112(sp)
    8000065c:	74a6                	ld	s1,104(sp)
    8000065e:	7906                	ld	s2,96(sp)
    80000660:	69e6                	ld	s3,88(sp)
    80000662:	6129                	addi	sp,sp,192
    80000664:	8082                	ret
        case 'x': printint(va_arg(ap, unsigned int), 16, 0); break;
    80000666:	f8843783          	ld	a5,-120(s0)
    8000066a:	4601                	li	a2,0
    8000066c:	45c1                	li	a1,16
    8000066e:	0007e503          	lwu	a0,0(a5)
    80000672:	07a1                	addi	a5,a5,8
    80000674:	f8f43423          	sd	a5,-120(s0)
    80000678:	00000097          	auipc	ra,0x0
    8000067c:	e5a080e7          	jalr	-422(ra) # 800004d2 <printint>
    80000680:	bf4d                	j	80000632 <printf+0xb0>
        case 'u': printint(va_arg(ap, unsigned int), 10, 0); break;
    80000682:	f8843783          	ld	a5,-120(s0)
    80000686:	4601                	li	a2,0
    80000688:	45a9                	li	a1,10
    8000068a:	0007e503          	lwu	a0,0(a5)
    8000068e:	07a1                	addi	a5,a5,8
    80000690:	f8f43423          	sd	a5,-120(s0)
    80000694:	00000097          	auipc	ra,0x0
    80000698:	e3e080e7          	jalr	-450(ra) # 800004d2 <printint>
    8000069c:	bf59                	j	80000632 <printf+0xb0>
            s = va_arg(ap, const char *);
    8000069e:	f8843783          	ld	a5,-120(s0)
    800006a2:	0007b983          	ld	s3,0(a5)
    800006a6:	07a1                	addi	a5,a5,8
    800006a8:	f8f43423          	sd	a5,-120(s0)
            if (s == 0) s = "(null)";
    800006ac:	12098d63          	beqz	s3,800007e6 <printf+0x264>
            while (*s) putc(*s++);
    800006b0:	0009c783          	lbu	a5,0(s3)
    800006b4:	dfbd                	beqz	a5,80000632 <printf+0xb0>
    if (c == '\n') {
    800006b6:	4aa9                	li	s5,10
    800006b8:	a809                	j	800006ca <printf+0x148>
    my_put(c);
    800006ba:	8552                	mv	a0,s4
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	db0080e7          	jalr	-592(ra) # 8000046c <my_put>
            while (*s) putc(*s++);
    800006c4:	0009c783          	lbu	a5,0(s3)
    800006c8:	d7ad                	beqz	a5,80000632 <printf+0xb0>
    800006ca:	0985                	addi	s3,s3,1
    800006cc:	00078a1b          	sext.w	s4,a5
    if (c == '\n') {
    800006d0:	ff5795e3          	bne	a5,s5,800006ba <printf+0x138>
        my_put('\r');
    800006d4:	4535                	li	a0,13
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	d96080e7          	jalr	-618(ra) # 8000046c <my_put>
    800006de:	bff1                	j	800006ba <printf+0x138>
        case 'p': printptr((uint64)va_arg(ap, void *)); break;
    800006e0:	f8843783          	ld	a5,-120(s0)
    my_put(c);
    800006e4:	03000513          	li	a0,48
    800006e8:	e0da                	sd	s6,64(sp)
        case 'p': printptr((uint64)va_arg(ap, void *)); break;
    800006ea:	00878713          	addi	a4,a5,8
    800006ee:	0007bb03          	ld	s6,0(a5)
    800006f2:	f06a                	sd	s10,32(sp)
    800006f4:	f8e43423          	sd	a4,-120(s0)
    800006f8:	ec6e                	sd	s11,24(sp)
    my_put(c);
    800006fa:	00000097          	auipc	ra,0x0
    800006fe:	d72080e7          	jalr	-654(ra) # 8000046c <my_put>
    80000702:	07800513          	li	a0,120
    80000706:	00000097          	auipc	ra,0x0
    8000070a:	d66080e7          	jalr	-666(ra) # 8000046c <my_put>
    8000070e:	03c00d13          	li	s10,60
    80000712:	00001a97          	auipc	s5,0x1
    80000716:	aa6a8a93          	addi	s5,s5,-1370 # 800011b8 <digits>
    if (c == '\n') {
    8000071a:	4a29                	li	s4,10
    for (int i = 0; i < 16; i++) {
    8000071c:	59f1                	li	s3,-4
    8000071e:	a809                	j	80000730 <printf+0x1ae>
    my_put(c);
    80000720:	856e                	mv	a0,s11
    for (int i = 0; i < 16; i++) {
    80000722:	3d71                	addiw	s10,s10,-4
    my_put(c);
    80000724:	00000097          	auipc	ra,0x0
    80000728:	d48080e7          	jalr	-696(ra) # 8000046c <my_put>
    for (int i = 0; i < 16; i++) {
    8000072c:	033d0763          	beq	s10,s3,8000075a <printf+0x1d8>
        putc(digits[(x >> ((15 - i) * 4)) & 0xf]);
    80000730:	01ab57b3          	srl	a5,s6,s10
    80000734:	8bbd                	andi	a5,a5,15
    80000736:	97d6                	add	a5,a5,s5
    80000738:	0007cd83          	lbu	s11,0(a5)
    if (c == '\n') {
    8000073c:	ff4d92e3          	bne	s11,s4,80000720 <printf+0x19e>
        my_put('\r');
    80000740:	4535                	li	a0,13
    80000742:	00000097          	auipc	ra,0x0
    80000746:	d2a080e7          	jalr	-726(ra) # 8000046c <my_put>
    my_put(c);
    8000074a:	856e                	mv	a0,s11
    for (int i = 0; i < 16; i++) {
    8000074c:	3d71                	addiw	s10,s10,-4
    my_put(c);
    8000074e:	00000097          	auipc	ra,0x0
    80000752:	d1e080e7          	jalr	-738(ra) # 8000046c <my_put>
    for (int i = 0; i < 16; i++) {
    80000756:	fd3d1de3          	bne	s10,s3,80000730 <printf+0x1ae>
    8000075a:	6b06                	ld	s6,64(sp)
    8000075c:	7d02                	ld	s10,32(sp)
    8000075e:	6de2                	ld	s11,24(sp)
    80000760:	bdc9                	j	80000632 <printf+0xb0>
        case 'd': printint(va_arg(ap, int), 10, 1); break;
    80000762:	f8843783          	ld	a5,-120(s0)
    80000766:	4605                	li	a2,1
    80000768:	45a9                	li	a1,10
    8000076a:	4388                	lw	a0,0(a5)
    8000076c:	07a1                	addi	a5,a5,8
    8000076e:	f8f43423          	sd	a5,-120(s0)
    80000772:	00000097          	auipc	ra,0x0
    80000776:	d60080e7          	jalr	-672(ra) # 800004d2 <printint>
    8000077a:	bd65                	j	80000632 <printf+0xb0>
        case 'c': putc(va_arg(ap, int)); break;
    8000077c:	f8843783          	ld	a5,-120(s0)
    if (c == '\n') {
    80000780:	4729                	li	a4,10
        case 'c': putc(va_arg(ap, int)); break;
    80000782:	0007a983          	lw	s3,0(a5)
    80000786:	07a1                	addi	a5,a5,8
    80000788:	f8f43423          	sd	a5,-120(s0)
    if (c == '\n') {
    8000078c:	e8e99ee3          	bne	s3,a4,80000628 <printf+0xa6>
        my_put('\r');
    80000790:	4535                	li	a0,13
    80000792:	00000097          	auipc	ra,0x0
    80000796:	cda080e7          	jalr	-806(ra) # 8000046c <my_put>
    8000079a:	b579                	j	80000628 <printf+0xa6>
    if (c == '\n') {
    8000079c:	01998f63          	beq	s3,s9,800007ba <printf+0x238>
    my_put(c);
    800007a0:	854e                	mv	a0,s3
    800007a2:	00000097          	auipc	ra,0x0
    800007a6:	cca080e7          	jalr	-822(ra) # 8000046c <my_put>
        if (c != '%') { putc(c); continue; }
    800007aa:	b569                	j	80000634 <printf+0xb2>
    my_put(c);
    800007ac:	02500513          	li	a0,37
    800007b0:	00000097          	auipc	ra,0x0
    800007b4:	cbc080e7          	jalr	-836(ra) # 8000046c <my_put>
}
    800007b8:	bdad                	j	80000632 <printf+0xb0>
        my_put('\r');
    800007ba:	4535                	li	a0,13
    800007bc:	00000097          	auipc	ra,0x0
    800007c0:	cb0080e7          	jalr	-848(ra) # 8000046c <my_put>
    800007c4:	bff1                	j	800007a0 <printf+0x21e>
        initlock(&pr_lock, "printf");
    800007c6:	00001597          	auipc	a1,0x1
    800007ca:	98a58593          	addi	a1,a1,-1654 # 80001150 <kfree+0x5de>
    800007ce:	00002517          	auipc	a0,0x2
    800007d2:	83250513          	addi	a0,a0,-1998 # 80002000 <pr_lock>
    800007d6:	00000097          	auipc	ra,0x0
    800007da:	08c080e7          	jalr	140(ra) # 80000862 <initlock>
        pr_lock_inited = 1;
    800007de:	4785                	li	a5,1
    800007e0:	00f92023          	sw	a5,0(s2)
    800007e4:	bbc1                	j	800005b4 <printf+0x32>
    800007e6:	02800793          	li	a5,40
            if (s == 0) s = "(null)";
    800007ea:	00001997          	auipc	s3,0x1
    800007ee:	95e98993          	addi	s3,s3,-1698 # 80001148 <kfree+0x5d6>
    800007f2:	b5d1                	j	800006b6 <printf+0x134>

00000000800007f4 <r_mstatus>:
#include "arch/type.h"

uint64 r_mstatus() {
    800007f4:	1141                	addi	sp,sp,-16
    800007f6:	e422                	sd	s0,8(sp)
    800007f8:	0800                	addi	s0,sp,16
    uint64 x;
    asm volatile("csrr %0, mstatus" : "=r"(x));
    800007fa:	30002573          	csrr	a0,mstatus
    return x;
}
    800007fe:	6422                	ld	s0,8(sp)
    80000800:	0141                	addi	sp,sp,16
    80000802:	8082                	ret

0000000080000804 <w_mstatus>:

void w_mstatus(uint64 x) {
    80000804:	1141                	addi	sp,sp,-16
    80000806:	e422                	sd	s0,8(sp)
    80000808:	0800                	addi	s0,sp,16
    asm volatile("csrw mstatus, %0" : : "r"(x));
    8000080a:	30051073          	csrw	mstatus,a0
}
    8000080e:	6422                	ld	s0,8(sp)
    80000810:	0141                	addi	sp,sp,16
    80000812:	8082                	ret

0000000080000814 <w_mepc>:

void w_mepc(uint64 x) {
    80000814:	1141                	addi	sp,sp,-16
    80000816:	e422                	sd	s0,8(sp)
    80000818:	0800                	addi	s0,sp,16
    asm volatile("csrw mepc, %0" : : "r"(x));
    8000081a:	34151073          	csrw	mepc,a0
}
    8000081e:	6422                	ld	s0,8(sp)
    80000820:	0141                	addi	sp,sp,16
    80000822:	8082                	ret

0000000080000824 <w_pmpaddr0>:

void w_pmpaddr0(uint64 x) {
    80000824:	1141                	addi	sp,sp,-16
    80000826:	e422                	sd	s0,8(sp)
    80000828:	0800                	addi	s0,sp,16
    asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    8000082a:	3b051073          	csrw	pmpaddr0,a0
}
    8000082e:	6422                	ld	s0,8(sp)
    80000830:	0141                	addi	sp,sp,16
    80000832:	8082                	ret

0000000080000834 <w_pmpcfg0>:

void w_pmpcfg0(uint64 x) {
    80000834:	1141                	addi	sp,sp,-16
    80000836:	e422                	sd	s0,8(sp)
    80000838:	0800                	addi	s0,sp,16
    asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    8000083a:	3a051073          	csrw	pmpcfg0,a0
}
    8000083e:	6422                	ld	s0,8(sp)
    80000840:	0141                	addi	sp,sp,16
    80000842:	8082                	ret

0000000080000844 <r_mhartid>:

uint64 r_mhartid() {
    80000844:	1141                	addi	sp,sp,-16
    80000846:	e422                	sd	s0,8(sp)
    80000848:	0800                	addi	s0,sp,16
    uint64 x;
    asm volatile("csrr %0, mhartid" : "=r"(x));
    8000084a:	f1402573          	csrr	a0,mhartid
    return x;
}
    8000084e:	6422                	ld	s0,8(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <w_tp>:

void w_tp(uint64 x) {
    80000854:	1141                	addi	sp,sp,-16
    80000856:	e422                	sd	s0,8(sp)
    80000858:	0800                	addi	s0,sp,16
    asm volatile("mv tp, %0" : : "r"(x));
    8000085a:	822a                	mv	tp,a0
}
    8000085c:	6422                	ld	s0,8(sp)
    8000085e:	0141                	addi	sp,sp,16
    80000860:	8082                	ret

0000000080000862 <initlock>:
#include "arch/method.h"
#include "lock/mod.h"

void initlock(struct spinlock *lk, const char *name) {
    80000862:	1141                	addi	sp,sp,-16
    80000864:	e422                	sd	s0,8(sp)
    80000866:	0800                	addi	s0,sp,16
    lk->locked = 0;
    lk->name = name;
}
    80000868:	6422                	ld	s0,8(sp)
    lk->locked = 0;
    8000086a:	00052023          	sw	zero,0(a0)
    lk->name = name;
    8000086e:	e50c                	sd	a1,8(a0)
}
    80000870:	0141                	addi	sp,sp,16
    80000872:	8082                	ret

0000000080000874 <acquire>:

void acquire(struct spinlock *lk) {
    80000874:	1141                	addi	sp,sp,-16
    80000876:	e422                	sd	s0,8(sp)
    80000878:	0800                	addi	s0,sp,16
    asm volatile("csrc sstatus, %0" : : "r"(2UL));
    8000087a:	4789                	li	a5,2
    8000087c:	1007b073          	csrc	sstatus,a5
    intr_off();
    while (__sync_lock_test_and_set(&lk->locked, 1) != 0) {}
    80000880:	4705                	li	a4,1
    80000882:	87ba                	mv	a5,a4
    80000884:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    80000888:	2781                	sext.w	a5,a5
    8000088a:	ffe5                	bnez	a5,80000882 <acquire+0xe>
    __sync_synchronize();
    8000088c:	0330000f          	fence	rw,rw
}
    80000890:	6422                	ld	s0,8(sp)
    80000892:	0141                	addi	sp,sp,16
    80000894:	8082                	ret

0000000080000896 <release>:

void release(struct spinlock *lk) {
    80000896:	1141                	addi	sp,sp,-16
    80000898:	e422                	sd	s0,8(sp)
    8000089a:	0800                	addi	s0,sp,16
    __sync_synchronize();
    8000089c:	0330000f          	fence	rw,rw
    __sync_lock_release(&lk->locked);
    800008a0:	0310000f          	fence	rw,w
    800008a4:	00052023          	sw	zero,0(a0)
    asm volatile("csrs sstatus, %0" : : "r"(2UL));
    800008a8:	4789                	li	a5,2
    800008aa:	1007a073          	csrs	sstatus,a5
    intr_on();
}
    800008ae:	6422                	ld	s0,8(sp)
    800008b0:	0141                	addi	sp,sp,16
    800008b2:	8082                	ret

00000000800008b4 <start>:
void   w_pmpcfg0(uint64 x);
uint64 r_mhartid();
void   w_tp(uint64 x);


void start() {
    800008b4:	1141                	addi	sp,sp,-16
    800008b6:	e406                	sd	ra,8(sp)
    800008b8:	e022                	sd	s0,0(sp)
    800008ba:	0800                	addi	s0,sp,16
    w_tp(r_mhartid());
    800008bc:	00000097          	auipc	ra,0x0
    800008c0:	f88080e7          	jalr	-120(ra) # 80000844 <r_mhartid>
    800008c4:	00000097          	auipc	ra,0x0
    800008c8:	f90080e7          	jalr	-112(ra) # 80000854 <w_tp>

    uint64 x = r_mstatus();
    800008cc:	00000097          	auipc	ra,0x0
    800008d0:	f28080e7          	jalr	-216(ra) # 800007f4 <r_mstatus>
    x &= ~(2UL << 11);
    800008d4:	777d                	lui	a4,0xfffff
    800008d6:	177d                	addi	a4,a4,-1 # ffffffffffffefff <kernel_pgdir+0xffffffff7fff3fef>
    x |=  (1UL << 11);
    800008d8:	6785                	lui	a5,0x1
    x &= ~(2UL << 11);
    800008da:	8d79                	and	a0,a0,a4
    x |=  (1UL << 11);
    800008dc:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    w_mstatus(x);
    800008e0:	8d5d                	or	a0,a0,a5
    800008e2:	00000097          	auipc	ra,0x0
    800008e6:	f22080e7          	jalr	-222(ra) # 80000804 <w_mstatus>

    w_mepc((uint64)main);
    800008ea:	fffff517          	auipc	a0,0xfffff
    800008ee:	73450513          	addi	a0,a0,1844 # 8000001e <main>
    800008f2:	00000097          	auipc	ra,0x0
    800008f6:	f22080e7          	jalr	-222(ra) # 80000814 <w_mepc>

    asm volatile("csrw satp, %0" : : "r"(0));
    800008fa:	4781                	li	a5,0
    800008fc:	18079073          	csrw	satp,a5
    asm volatile("csrw medeleg, %0" : : "r"(0));
    80000900:	30279073          	csrw	medeleg,a5
    asm volatile("csrw mideleg, %0" : : "r"(0));
    80000904:	30379073          	csrw	mideleg,a5
    asm volatile("csrw sie, %0" : : "r"(0));
    80000908:	10479073          	csrw	sie,a5

    w_pmpaddr0(0x3fffffffffffffull);
    8000090c:	557d                	li	a0,-1
    8000090e:	8129                	srli	a0,a0,0xa
    80000910:	00000097          	auipc	ra,0x0
    80000914:	f14080e7          	jalr	-236(ra) # 80000824 <w_pmpaddr0>
    w_pmpcfg0(0xf);
    80000918:	453d                	li	a0,15
    8000091a:	00000097          	auipc	ra,0x0
    8000091e:	f1a080e7          	jalr	-230(ra) # 80000834 <w_pmpcfg0>

    asm volatile("mret");
    80000922:	30200073          	mret

    while (1) {}
    80000926:	a001                	j	80000926 <start+0x72>

0000000080000928 <kvmmap>:
        }
    }
    return &pgdir[PX(va, 0)];
}

static void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
    80000928:	711d                	addi	sp,sp,-96
    8000092a:	e8a2                	sd	s0,80(sp)
    8000092c:	e0ca                	sd	s2,64(sp)
    8000092e:	fc4e                	sd	s3,56(sp)
    80000930:	f852                	sd	s4,48(sp)
    80000932:	f456                	sd	s5,40(sp)
    80000934:	f05a                	sd	s6,32(sp)
    80000936:	e862                	sd	s8,16(sp)
    80000938:	e466                	sd	s9,8(sp)
    8000093a:	ec86                	sd	ra,88(sp)
    8000093c:	e4a6                	sd	s1,72(sp)
    8000093e:	ec5e                	sd	s7,24(sp)
    80000940:	e06a                	sd	s10,0(sp)
    80000942:	1080                	addi	s0,sp,96
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    80000944:	8c2e                	mv	s8,a1
static void kvmmap(uint64 *pgdir, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
    80000946:	8a2a                	mv	s4,a0
    80000948:	8aba                	mv	s5,a4
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    8000094a:	00d58933          	add	s2,a1,a3
    8000094e:	40b609b3          	sub	s3,a2,a1
    80000952:	4c85                	li	s9,1
    80000954:	6b05                	lui	s6,0x1
    80000956:	013c0bb3          	add	s7,s8,s3
    for (int level = 2; level >= 1; level--) {
    8000095a:	8552                	mv	a0,s4
    8000095c:	4d09                	li	s10,2
    8000095e:	4789                	li	a5,2
        uint64 *pte = &pgdir[PX(va, level)];
    80000960:	0037949b          	slliw	s1,a5,0x3
    80000964:	9cbd                	addw	s1,s1,a5
    80000966:	24b1                	addiw	s1,s1,12
    80000968:	009c54b3          	srl	s1,s8,s1
    8000096c:	1ff4f493          	andi	s1,s1,511
    80000970:	048e                	slli	s1,s1,0x3
    80000972:	94aa                	add	s1,s1,a0
        if (*pte & PTE_V) {
    80000974:	6088                	ld	a0,0(s1)
    80000976:	00157793          	andi	a5,a0,1
            pgdir = (uint64 *)PTE2PA(*pte);
    8000097a:	8129                	srli	a0,a0,0xa
    8000097c:	0532                	slli	a0,a0,0xc
        if (*pte & PTE_V) {
    8000097e:	ef81                	bnez	a5,80000996 <kvmmap+0x6e>
            pgdir = (uint64 *)kalloc();
    80000980:	00000097          	auipc	ra,0x0
    80000984:	188080e7          	jalr	392(ra) # 80000b08 <kalloc>
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
    80000988:	00c55793          	srli	a5,a0,0xc
    8000098c:	07aa                	slli	a5,a5,0xa
    8000098e:	0017e793          	ori	a5,a5,1
            if (pgdir == 0) {
    80000992:	c915                	beqz	a0,800009c6 <kvmmap+0x9e>
            *pte = PA2PTE((uint64)pgdir) | PTE_V;
    80000994:	e09c                	sd	a5,0(s1)
    for (int level = 2; level >= 1; level--) {
    80000996:	4785                	li	a5,1
    80000998:	019d0463          	beq	s10,s9,800009a0 <kvmmap+0x78>
    8000099c:	4d05                	li	s10,1
    8000099e:	b7c9                	j	80000960 <kvmmap+0x38>
    return &pgdir[PX(va, 0)];
    800009a0:	00cc5793          	srli	a5,s8,0xc
    800009a4:	1ff7f793          	andi	a5,a5,511
    800009a8:	078e                	slli	a5,a5,0x3
    800009aa:	953e                	add	a0,a0,a5
        uint64 *pte = walk(pgdir, a, 1);
        if (pte == 0) {
    800009ac:	cd09                	beqz	a0,800009c6 <kvmmap+0x9e>
            return;
        }
        *pte = PA2PTE(pa) | perm | PTE_V;
    800009ae:	00cbdb93          	srli	s7,s7,0xc
    800009b2:	0baa                	slli	s7,s7,0xa
    800009b4:	015bebb3          	or	s7,s7,s5
    800009b8:	001beb93          	ori	s7,s7,1
    800009bc:	01753023          	sd	s7,0(a0)
    for (uint64 a = PGROUNDDOWN(va); a < va + sz; a += PGSIZE, pa += PGSIZE) {
    800009c0:	9c5a                	add	s8,s8,s6
    800009c2:	f92c6ae3          	bltu	s8,s2,80000956 <kvmmap+0x2e>
    }
}
    800009c6:	60e6                	ld	ra,88(sp)
    800009c8:	6446                	ld	s0,80(sp)
    800009ca:	64a6                	ld	s1,72(sp)
    800009cc:	6906                	ld	s2,64(sp)
    800009ce:	79e2                	ld	s3,56(sp)
    800009d0:	7a42                	ld	s4,48(sp)
    800009d2:	7aa2                	ld	s5,40(sp)
    800009d4:	7b02                	ld	s6,32(sp)
    800009d6:	6be2                	ld	s7,24(sp)
    800009d8:	6c42                	ld	s8,16(sp)
    800009da:	6ca2                	ld	s9,8(sp)
    800009dc:	6d02                	ld	s10,0(sp)
    800009de:	6125                	addi	sp,sp,96
    800009e0:	8082                	ret

00000000800009e2 <kvminit>:

void kvminit() {
    800009e2:	1101                	addi	sp,sp,-32
    800009e4:	e822                	sd	s0,16(sp)
    800009e6:	e426                	sd	s1,8(sp)
    800009e8:	ec06                	sd	ra,24(sp)
    800009ea:	1000                	addi	s0,sp,32
    kernel_pgdir = (uint64 *)kalloc();
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	11c080e7          	jalr	284(ra) # 80000b08 <kalloc>
    800009f4:	0000a497          	auipc	s1,0xa
    800009f8:	61c48493          	addi	s1,s1,1564 # 8000b010 <kernel_pgdir>
    800009fc:	e088                	sd	a0,0(s1)
    if (kernel_pgdir == 0) {
    800009fe:	c91d                	beqz	a0,80000a34 <kvminit+0x52>
        return;
    }
    kvmmap(kernel_pgdir, UART0, UART0, PGSIZE, PTE_KERN_RW);
    80000a00:	4719                	li	a4,6
    80000a02:	6685                	lui	a3,0x1
    80000a04:	10000637          	lui	a2,0x10000
    80000a08:	100005b7          	lui	a1,0x10000
    80000a0c:	00000097          	auipc	ra,0x0
    80000a10:	f1c080e7          	jalr	-228(ra) # 80000928 <kvmmap>
    kvmmap(kernel_pgdir, KERNBASE, KERNBASE, PHYSTOP - KERNBASE, PTE_KERN_RWX);
    80000a14:	6088                	ld	a0,0(s1)
    80000a16:	4605                	li	a2,1
    80000a18:	067e                	slli	a2,a2,0x1f
    80000a1a:	4739                	li	a4,14
    80000a1c:	080006b7          	lui	a3,0x8000
    80000a20:	85b2                	mv	a1,a2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	f06080e7          	jalr	-250(ra) # 80000928 <kvmmap>
    kvminit_done = 1;
    80000a2a:	4785                	li	a5,1
    80000a2c:	0000a717          	auipc	a4,0xa
    80000a30:	5cf72e23          	sw	a5,1500(a4) # 8000b008 <kvminit_done>
}
    80000a34:	60e2                	ld	ra,24(sp)
    80000a36:	6442                	ld	s0,16(sp)
    80000a38:	64a2                	ld	s1,8(sp)
    80000a3a:	6105                	addi	sp,sp,32
    80000a3c:	8082                	ret

0000000080000a3e <kvminithart>:

void kvminithart() {
    80000a3e:	1141                	addi	sp,sp,-16
    80000a40:	e422                	sd	s0,8(sp)
    80000a42:	0800                	addi	s0,sp,16
    w_satp(MAKE_SATP(kernel_pgdir));
    80000a44:	0000a797          	auipc	a5,0xa
    80000a48:	5cc7b783          	ld	a5,1484(a5) # 8000b010 <kernel_pgdir>
    80000a4c:	577d                	li	a4,-1
    80000a4e:	177e                	slli	a4,a4,0x3f
    80000a50:	83b1                	srli	a5,a5,0xc
    80000a52:	8fd9                	or	a5,a5,a4
    asm volatile("csrw satp, %0" : : "r"(x));
    80000a54:	18079073          	csrw	satp,a5
    return x;
}

static inline void sfence_vma() {
    asm volatile("sfence.vma");
    80000a58:	12000073          	sfence.vma
    sfence_vma();
}
    80000a5c:	6422                	ld	s0,8(sp)
    80000a5e:	0141                	addi	sp,sp,16
    80000a60:	8082                	ret

0000000080000a62 <kinit>:
    struct run *freelist;
} kmem;

extern char end;

void kinit() {
    80000a62:	7139                	addi	sp,sp,-64
    80000a64:	f822                	sd	s0,48(sp)
    80000a66:	f426                	sd	s1,40(sp)
    80000a68:	f04a                	sd	s2,32(sp)
    80000a6a:	fc06                	sd	ra,56(sp)
    80000a6c:	0080                	addi	s0,sp,64
    initlock(&kmem.lock, "kmem");
    80000a6e:	00000597          	auipc	a1,0x0
    80000a72:	6ea58593          	addi	a1,a1,1770 # 80001158 <kfree+0x5e6>
    80000a76:	00001517          	auipc	a0,0x1
    80000a7a:	59a50513          	addi	a0,a0,1434 # 80002010 <kmem>
    80000a7e:	00000097          	auipc	ra,0x0
    80000a82:	de4080e7          	jalr	-540(ra) # 80000862 <initlock>
    char *p = (char *)PGROUNDUP((uint64)&end);
    80000a86:	77fd                	lui	a5,0xfffff
    80000a88:	0000b497          	auipc	s1,0xb
    80000a8c:	57748493          	addi	s1,s1,1399 # 8000bfff <kernel_pgdir+0xfef>
    80000a90:	8cfd                	and	s1,s1,a5
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000a92:	4945                	li	s2,17
    80000a94:	6785                	lui	a5,0x1
    80000a96:	97a6                	add	a5,a5,s1
    80000a98:	096e                	slli	s2,s2,0x1b
    80000a9a:	02f96c63          	bltu	s2,a5,80000ad2 <kinit+0x70>
    80000a9e:	ec4e                	sd	s3,24(sp)
    80000aa0:	e852                	sd	s4,16(sp)
    80000aa2:	e456                	sd	s5,8(sp)
    80000aa4:	89a6                	mv	s3,s1
    80000aa6:	6a05                	lui	s4,0x1
void kfree(void *pa) {
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
        return;
    }
    struct run *r = (struct run *)pa;
    acquire(&kmem.lock);
    80000aa8:	00001a97          	auipc	s5,0x1
    80000aac:	568a8a93          	addi	s5,s5,1384 # 80002010 <kmem>
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
    80000ab0:	0134eb63          	bltu	s1,s3,80000ac6 <kinit+0x64>
    acquire(&kmem.lock);
    80000ab4:	00001517          	auipc	a0,0x1
    80000ab8:	55c50513          	addi	a0,a0,1372 # 80002010 <kmem>
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
    80000abc:	0324e163          	bltu	s1,s2,80000ade <kinit+0x7c>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000ac0:	94d2                	add	s1,s1,s4
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
    80000ac2:	ff34f9e3          	bgeu	s1,s3,80000ab4 <kinit+0x52>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000ac6:	94d2                	add	s1,s1,s4
    80000ac8:	ff2494e3          	bne	s1,s2,80000ab0 <kinit+0x4e>
    80000acc:	69e2                	ld	s3,24(sp)
    80000ace:	6a42                	ld	s4,16(sp)
    80000ad0:	6aa2                	ld	s5,8(sp)
}
    80000ad2:	70e2                	ld	ra,56(sp)
    80000ad4:	7442                	ld	s0,48(sp)
    80000ad6:	74a2                	ld	s1,40(sp)
    80000ad8:	7902                	ld	s2,32(sp)
    80000ada:	6121                	addi	sp,sp,64
    80000adc:	8082                	ret
    acquire(&kmem.lock);
    80000ade:	00000097          	auipc	ra,0x0
    80000ae2:	d96080e7          	jalr	-618(ra) # 80000874 <acquire>
    r->next = kmem.freelist;
    80000ae6:	010ab783          	ld	a5,16(s5)
    kmem.freelist = r;
    release(&kmem.lock);
    80000aea:	00001517          	auipc	a0,0x1
    80000aee:	52650513          	addi	a0,a0,1318 # 80002010 <kmem>
    r->next = kmem.freelist;
    80000af2:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000af4:	009ab823          	sd	s1,16(s5)
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000af8:	94d2                	add	s1,s1,s4
    release(&kmem.lock);
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	d9c080e7          	jalr	-612(ra) # 80000896 <release>
    for (; p + PGSIZE <= (char *)PHYSTOP; p += PGSIZE) {
    80000b02:	fb2497e3          	bne	s1,s2,80000ab0 <kinit+0x4e>
    80000b06:	b7d9                	j	80000acc <kinit+0x6a>

0000000080000b08 <kalloc>:
void *kalloc() {
    80000b08:	1101                	addi	sp,sp,-32
    80000b0a:	e822                	sd	s0,16(sp)
    80000b0c:	e426                	sd	s1,8(sp)
    80000b0e:	e04a                	sd	s2,0(sp)
    80000b10:	ec06                	sd	ra,24(sp)
    80000b12:	1000                	addi	s0,sp,32
    acquire(&kmem.lock);
    80000b14:	00001917          	auipc	s2,0x1
    80000b18:	4fc90913          	addi	s2,s2,1276 # 80002010 <kmem>
    80000b1c:	854a                	mv	a0,s2
    80000b1e:	00000097          	auipc	ra,0x0
    80000b22:	d56080e7          	jalr	-682(ra) # 80000874 <acquire>
    struct run *r = kmem.freelist;
    80000b26:	01093483          	ld	s1,16(s2)
    if (r) {
    80000b2a:	c885                	beqz	s1,80000b5a <kalloc+0x52>
        kmem.freelist = r->next;
    80000b2c:	609c                	ld	a5,0(s1)
    release(&kmem.lock);
    80000b2e:	854a                	mv	a0,s2
        kmem.freelist = r->next;
    80000b30:	00f93823          	sd	a5,16(s2)
    release(&kmem.lock);
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	d62080e7          	jalr	-670(ra) # 80000896 <release>
        for (int i = 0; i < PGSIZE; i++) {
    80000b3c:	6705                	lui	a4,0x1
    80000b3e:	87a6                	mv	a5,s1
    80000b40:	9726                	add	a4,a4,s1
            v[i] = 0;
    80000b42:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
        for (int i = 0; i < PGSIZE; i++) {
    80000b46:	0785                	addi	a5,a5,1
    80000b48:	fee79de3          	bne	a5,a4,80000b42 <kalloc+0x3a>
}
    80000b4c:	60e2                	ld	ra,24(sp)
    80000b4e:	6442                	ld	s0,16(sp)
    80000b50:	6902                	ld	s2,0(sp)
    80000b52:	8526                	mv	a0,s1
    80000b54:	64a2                	ld	s1,8(sp)
    80000b56:	6105                	addi	sp,sp,32
    80000b58:	8082                	ret
    release(&kmem.lock);
    80000b5a:	854a                	mv	a0,s2
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	d3a080e7          	jalr	-710(ra) # 80000896 <release>
}
    80000b64:	60e2                	ld	ra,24(sp)
    80000b66:	6442                	ld	s0,16(sp)
    80000b68:	6902                	ld	s2,0(sp)
    80000b6a:	8526                	mv	a0,s1
    80000b6c:	64a2                	ld	s1,8(sp)
    80000b6e:	6105                	addi	sp,sp,32
    80000b70:	8082                	ret

0000000080000b72 <kfree>:
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
    80000b72:	03451793          	slli	a5,a0,0x34
    80000b76:	e3ad                	bnez	a5,80000bd8 <kfree+0x66>
void kfree(void *pa) {
    80000b78:	1101                	addi	sp,sp,-32
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	ec06                	sd	ra,24(sp)
    80000b80:	1000                	addi	s0,sp,32
    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < (char *)PGROUNDUP((uint64)&end) || (uint64)pa >= PHYSTOP) {
    80000b82:	0000b797          	auipc	a5,0xb
    80000b86:	47d78793          	addi	a5,a5,1149 # 8000bfff <kernel_pgdir+0xfef>
    80000b8a:	777d                	lui	a4,0xfffff
    80000b8c:	8ff9                	and	a5,a5,a4
    80000b8e:	84aa                	mv	s1,a0
    80000b90:	02f56f63          	bltu	a0,a5,80000bce <kfree+0x5c>
    80000b94:	47c5                	li	a5,17
    80000b96:	07ee                	slli	a5,a5,0x1b
    80000b98:	02f57b63          	bgeu	a0,a5,80000bce <kfree+0x5c>
    80000b9c:	e04a                	sd	s2,0(sp)
    acquire(&kmem.lock);
    80000b9e:	00001917          	auipc	s2,0x1
    80000ba2:	47290913          	addi	s2,s2,1138 # 80002010 <kmem>
    80000ba6:	854a                	mv	a0,s2
    80000ba8:	00000097          	auipc	ra,0x0
    80000bac:	ccc080e7          	jalr	-820(ra) # 80000874 <acquire>
    r->next = kmem.freelist;
    80000bb0:	01093783          	ld	a5,16(s2)
}
    80000bb4:	6442                	ld	s0,16(sp)
    80000bb6:	60e2                	ld	ra,24(sp)
    r->next = kmem.freelist;
    80000bb8:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000bba:	00993823          	sd	s1,16(s2)
    release(&kmem.lock);
    80000bbe:	854a                	mv	a0,s2
}
    80000bc0:	64a2                	ld	s1,8(sp)
    release(&kmem.lock);
    80000bc2:	6902                	ld	s2,0(sp)
}
    80000bc4:	6105                	addi	sp,sp,32
    release(&kmem.lock);
    80000bc6:	00000317          	auipc	t1,0x0
    80000bca:	cd030067          	jr	-816(t1) # 80000896 <release>
}
    80000bce:	60e2                	ld	ra,24(sp)
    80000bd0:	6442                	ld	s0,16(sp)
    80000bd2:	64a2                	ld	s1,8(sp)
    80000bd4:	6105                	addi	sp,sp,32
    80000bd6:	8082                	ret
    80000bd8:	8082                	ret
