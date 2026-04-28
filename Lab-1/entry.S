.section .text
.global _entry
_entry:
    la sp, stacks  // sp（栈指针）= stacks 的地址
    li t0, 4096
    add sp, sp, t0
    call start     // 调用 C 函数 start()

.section .bss
.align 12          // 按 2^12 = 4096 字节对齐
stacks:
    .space 4096