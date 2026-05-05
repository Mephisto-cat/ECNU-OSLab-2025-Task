include common.mk

C_SRCS := $(shell find src -name '*.c')
S_SRCS := $(shell find src -name '*.S')

OBJS := $(C_SRCS:.c=.o) $(S_SRCS:.S=.o)

BUILD_DIR := build
ELF      := $(BUILD_DIR)/kernel-qemu.elf
ASM      := $(BUILD_DIR)/kernel.asm

all: $(ELF) $(ASM)

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

$(ELF): $(OBJS) kernel.ld
	@mkdir -p $(BUILD_DIR)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

$(ASM): $(ELF)
	$(OBJDUMP) -S $< > $@

run: $(ELF)
	qemu-system-riscv64 \
		-machine virt \
		-bios none \
		-kernel $(ELF) \
		-m 128M \
		-smp 2 \
		-nographic

qemu-gdb: $(ELF)
	qemu-system-riscv64 \
		-machine virt \
		-bios none \
		-kernel $(ELF) \
		-m 128M \
		-smp 1 \
		-S -gdb tcp::1234 \
		-nographic

clean:
	rm -f $(OBJS) $(ELF) $(ASM)

.PHONY: all run qemu-gdb clean
