.section .text
.global kernel_vector
.align 4

# S-mode 陷阱入口
# sscratch 指向当前 hart 的 trapframe
kernel_vector:
    # 交换 sp 和 sscratch: sp = &trapframe, sscratch = 被打断前的 sp
    csrrw sp, sscratch, sp

    # 保存全部 32 个通用寄存器到 trapframe (基址 = sp)
    sd ra,    0(sp)
    sd gp,   16(sp)
    sd tp,   24(sp)
    sd t0,   32(sp)
    sd t1,   40(sp)
    sd t2,   48(sp)
    sd s0,   56(sp)
    sd s1,   64(sp)
    sd a0,   72(sp)
    sd a1,   80(sp)
    sd a2,   88(sp)
    sd a3,   96(sp)
    sd a4,  104(sp)
    sd a5,  112(sp)
    sd a6,  120(sp)
    sd a7,  128(sp)
    sd s2,  136(sp)
    sd s3,  144(sp)
    sd s4,  152(sp)
    sd s5,  160(sp)
    sd s6,  168(sp)
    sd s7,  176(sp)
    sd s8,  184(sp)
    sd s9,  192(sp)
    sd s10, 200(sp)
    sd s11, 208(sp)
    sd t3,  216(sp)
    sd t4,  224(sp)
    sd t5,  232(sp)
    sd t6,  240(sp)

    # 从 sscratch 取出原来的 sp 并保存到 trapframe.sp
    csrr  t0, sscratch
    sd    t0,   8(sp)

    # 保存 trap 相关 CSR
    csrr  t0, sepc
    sd    t0, 248(sp)
    csrr  t0, sstatus
    sd    t0, 256(sp)
    csrr  t0, scause
    sd    t0, 264(sp)
    csrr  t0, stval
    sd    t0, 272(sp)

    # 切回内核栈: 先把 trapframe 地址存到 sscratch, 再恢复 sp
    csrw  sscratch, sp     # sscratch = &trapframe
    ld    sp, 8(sp)        # sp = 原来的内核栈指针

    # 调用 C 处理函数, a0 = &trapframe
    csrr  a0, sscratch
    call  trap_kernel_handler

# 从 trap 返回, 恢复全部上下文
trap_return:
    # 换回 trapframe: sp = &trapframe, sscratch = 当前 sp
    csrrw sp, sscratch, sp

    # 恢复 CSR
    ld    t0, 248(sp)
    csrw  sepc, t0
    ld    t0, 256(sp)
    csrw  sstatus, t0

    # 恢复所有 GPR
    ld    ra,   0(sp)
    ld    gp,  16(sp)
    ld    tp,  24(sp)
    ld    t0,  32(sp)
    ld    t1,  40(sp)
    ld    t2,  48(sp)
    ld    s0,  56(sp)
    ld    s1,  64(sp)
    ld    a0,  72(sp)
    ld    a1,  80(sp)
    ld    a2,  88(sp)
    ld    a3,  96(sp)
    ld    a4, 104(sp)
    ld    a5, 112(sp)
    ld    a6, 120(sp)
    ld    a7, 128(sp)
    ld    s2, 136(sp)
    ld    s3, 144(sp)
    ld    s4, 152(sp)
    ld    s5, 160(sp)
    ld    s6, 168(sp)
    ld    s7, 176(sp)
    ld    s8, 184(sp)
    ld    s9, 192(sp)
    ld    s10,200(sp)
    ld    s11,208(sp)
    ld    t3, 216(sp)
    ld    t4, 224(sp)
    ld    t5, 232(sp)
    ld    t6, 240(sp)

    # 恢复 sp 前把 &trapframe 写回 sscratch (为下次 trap 做准备)
    mv    t0, sp
    ld    sp,   8(sp)
    csrw  sscratch, t0

    sret
