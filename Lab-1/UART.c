#define UART0 0x10000000L

void UARTinit() {
    // volatile 告诉编译器这个地址是一块硬件区域
    volatile unsigned char *uart = (volatile unsigned char *)UART0;
    uart[1] = 0x00; // 往地址 0x10000001 写一个字节 0x00


    (void)uart;
}
