.section .text
.global timer_vector
.align 4

# M-mode 时钟中断入口
# 更新 MTIMECMP 并触发 S-mode 软件中断
timer_vector:
    addi sp, sp, -32
    sd   a0, 0(sp)
    sd   a1, 8(sp)
    sd   t0, 16(sp)
    sd   ra, 24(sp)

    # 读当前 mtime
    rdtime a0

    # 下一个触发目标 = 当前 + INTERVAL (10000000 cycles)
    li     a1, 10000000
    add    a0, a0, a1

    # 写 MTIMECMP = CLINT_BASE + 0x4000 + 8 * hartid
    csrr   a1, mhartid
    li     t0, 0x02004000        # CLINT + 0x4000
    slli   a1, a1, 3
    add    t0, t0, a1
    sd     a0, 0(t0)

    # 直接置 S-mode 软件中断 pending (sip.SSIP = bit1)
    li     t0, 2
    csrs   mip, t0

    ld     ra, 24(sp)
    ld     t0, 16(sp)
    ld     a1, 8(sp)
    ld     a0, 0(sp)
    addi   sp, sp, 32
    mret
