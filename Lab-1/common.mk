CROSS_COMPILE := riscv64-linux-gnu-
CC            := $(CROSS_COMPILE)gcc
OBJDUMP       := $(CROSS_COMPILE)objdump

CFLAGS := -Wall -Wextra -O2 -g -ffreestanding -fno-common \
	-fno-omit-frame-pointer -fno-pie -fno-pic -mno-relax \
	-mcmodel=medany -march=rv64gc -mabi=lp64d \
	-I src/kernel

LDFLAGS := -nostdlib -no-pie -Wl,--build-id=none \
	-z max-page-size=4096 -T kernel.ld
