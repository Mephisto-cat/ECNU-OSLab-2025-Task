OUTPUT_ARCH("riscv")
ENTRY(_entry)

SECTIONS {
    . = 0x80000000;

    /* 存放程序代码和常量数据 */
    .text : {
        *(.text .text.*)
    }

    /* 只读数据 */
    .rodata : {
        . = ALIGN(16);
        *(.rodata .rodata.*)
    }

    /* 已初始化的全局变量和静态变量 */
    .data : {
        . = ALIGN(16);
        *(.data .data.*)
    }

    /* 未初始化的全局和静态变量 */
    .bss : {
        . = ALIGN(16);
        *(.bss .bss.*)
    }

    PROVIDE(end = .);
}
