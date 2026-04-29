# 交叉编译工具链前缀
# 用 riscv64-linux-gnu-gcc 编译出在 RISC-V 64 位平台上运行的代码
CROSS_COMPILE := riscv64-linux-gnu-
CC            := $(CROSS_COMPILE)gcc
OBJDUMP       := $(CROSS_COMPILE)objdump

.DEFAULT_GOAL := all

# -ffreestanding: 不依赖宿主操作系统的标准库
# -fno-pie/fno-pic: 禁用位置无关代码，内核加载地址是固定的 (0x80000000)
# -mcmodel=medany: 代码模型，允许寻址 ±2GB，够覆盖内核的地址空间
# -march=rv64gc: 目标架构 RISC-V 64，扩展 g(通用)+c(压缩指令)
# -mabi=lp64d: ABI: long/pointer 64 位，硬件浮点
CFLAGS := -Wall -Wextra -O2 -g -ffreestanding -fno-common \
	-fno-omit-frame-pointer -fno-pie -fno-pic -mno-relax \
	-mcmodel=medany -march=rv64gc -mabi=lp64d

# -nostdlib: 不链接标准 C 库（我们没有操作系统，标准库用不了）
# -T kernel.ld: 用我们自己的链接脚本
LDFLAGS := -nostdlib -no-pie -Wl,--build-id=none \
	-z max-page-size=4096 -T kernel.ld

# 需要链接的所有目标文件
OBJS := \
	entry.o \
	start.o \
	main.o \
	UART.o \
	printf.o \
	spinlock.o \
	kalloc.o \
	vm.o

all: kernel-qemu.elf kernel.asm

# 编译汇编文件
entry.o: entry.S
	$(CC) $(CFLAGS) -c -o $@ $<

# 链接生成 ELF（QEMU 直接加载这个）
kernel-qemu.elf: $(OBJS) kernel.ld
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

# 生成反汇编文件，方便调试时对照 C 源码和汇编
kernel.asm: kernel-qemu.elf
	$(OBJDUMP) -S $< > $@

# 运行：在 QEMU 中启动内核
# -machine virt: 使用 RISC-V 虚拟平台
# -bios none: 不加载固件（我们自己就是固件）
# -kernel: 指定内核 ELF 文件
# -m 128M: 分配 128MB 内存
# -smp 2: 模拟 2 个 CPU 核（用于验证自旋锁）
# -nographic: 不使用图形窗口，串口输出直接到终端
run: kernel-qemu.elf
	qemu-system-riscv64 \
		-machine virt \
		-bios none \
		-kernel kernel-qemu.elf \
		-m 128M \
		-smp 2 \
		-nographic

clean:
	rm -f *.o *.elf *.asm

.PHONY: all run clean
