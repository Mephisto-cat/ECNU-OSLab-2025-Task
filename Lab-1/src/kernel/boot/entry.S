.section .text
.global _entry

_entry:
    csrr a0, mhartid
    la sp, stacks
    li t0, 4096
    addi a0, a0, 1
    mul a0, a0, t0
    add sp, sp, a0
    call start

.section .bss
.align 12
.global stacks
stacks:
    .space 4096 * 8
