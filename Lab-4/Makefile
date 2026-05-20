include common.mk

CPUNUM = 2

KernelPath = src/kernel
UserPath = src/user
BUILD_DIR = build
ELF = $(BUILD_DIR)/kernel-qemu.elf
ASM = $(BUILD_DIR)/kernel.asm

KernelSourceFile = $(wildcard $(KernelPath)/*.c) $(wildcard $(KernelPath)/*.S)
KernelSourceFile += $(wildcard $(KernelPath)/*/*.c) $(wildcard $(KernelPath)/*/*.S)

# Lab-4 只运行第一个用户进程 initcode，不自动收集其它用户样例
UserSourceFile = $(UserPath)/initcode.c

KernelOBJ = src/kernel/boot/entry.o
KernelOBJ += $(patsubst %.c, %.o, $(filter %.c, $(KernelSourceFile)))
KernelOBJ += $(filter-out src/kernel/boot/entry.o, $(patsubst %.S, %.o, $(filter %.S, $(KernelSourceFile))))
UserOBJ = $(patsubst %.c, %.o, $(filter %.c, $(UserSourceFile)))
DEP = $(patsubst %.o, %.d, $(KernelOBJ) $(UserOBJ))

all: build

$(BUILD_DIR)/.dir:
	@mkdir -p $(BUILD_DIR)
	@touch $(BUILD_DIR)/.dir

src/user/initcode.h: $(UserOBJ) | $(BUILD_DIR)/.dir
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o $(BUILD_DIR)/initcode.out src/user/initcode.o
	$(OBJCOPY) -S -O binary $(BUILD_DIR)/initcode.out $(BUILD_DIR)/initcode
	xxd -i $(BUILD_DIR)/initcode > src/user/initcode.h
	sed -i 's/build_initcode/target_user_initcode/g' src/user/initcode.h

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

$(ELF): src/user/initcode.h $(KernelOBJ) | $(BUILD_DIR)/.dir
	$(LD) $(LDFLAGS) -T kernel.ld -o $(ELF) $(KernelOBJ)

$(ASM): $(ELF)
	$(OBJDUMP) -S $(ELF) > $(ASM)

build: $(ELF) $(ASM)
	@echo "===== make success! ====="

run: build
	qemu-system-riscv64 \
		-machine virt \
		-bios none \
		-kernel $(ELF) \
		-m 128M \
		-smp $(CPUNUM) \
		-nographic

debug: build .gdbinit
	qemu-system-riscv64 \
		-machine virt \
		-bios none \
		-kernel $(ELF) \
		-m 128M \
		-smp $(CPUNUM) \
		-S -gdb tcp::1234 \
		-nographic

.gdbinit: .gdbinit.tmpl-riscv
	sed "s/:1234/:1234/" < $^ > $@

clean:
	rm -f $(UserOBJ) $(KernelOBJ) $(ELF) $(ASM)
	rm -f $(DEP)
	rm -f $(BUILD_DIR)/initcode $(BUILD_DIR)/initcode.out
	rm -f $(BUILD_DIR)/.dir
	rm -f src/user/initcode.h .gdbinit

.PHONY: all build run debug clean
