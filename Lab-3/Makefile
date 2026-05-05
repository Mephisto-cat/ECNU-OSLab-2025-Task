CROSS_COMPILE := riscv64-linux-gnu-
CC            := $(CROSS_COMPILE)gcc
OBJDUMP       := $(CROSS_COMPILE)objdump

CFLAGS := -Wall -Wextra -O2 -g -ffreestanding -fno-common \
	-fno-omit-frame-pointer -fno-pie -fno-pic -mno-relax \
	-mcmodel=medany -march=rv64gc -mabi=lp64d

LDFLAGS := -nostdlib -no-pie -Wl,--build-id=none \
	-z max-page-size=4096 -T kernel.ld

OBJS := entry.o start.o main.o UART.o printf.o spinlock.o kalloc.o vm.o trap_entry.o trap.o plic.o timer_entry.o timer.o

all: kernel-qemu.elf kernel.asm

entry.o: entry.S
	$(CC) $(CFLAGS) -c -o $@ $<

kernel-qemu.elf: $(OBJS) kernel.ld
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

kernel.asm: kernel-qemu.elf
	$(OBJDUMP) -S $< > $@

run: kernel-qemu.elf
	qemu-system-riscv64 \
		-machine virt \
		-bios none \
		-kernel kernel-qemu.elf \
		-m 128M \
		-smp 2 \
		-nographic

qemu-gdb: kernel-qemu.elf
	qemu-system-riscv64 \
		-machine virt \
		-bios none \
		-kernel kernel-qemu.elf \
		-m 128M \
		-smp 1 \
		-S -gdb tcp::1234 \
		-nographic

clean:
	rm -f *.o *.elf *.asm

.PHONY: all run qemu-gdb clean