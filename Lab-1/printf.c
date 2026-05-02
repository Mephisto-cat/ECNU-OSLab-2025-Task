#include <stdarg.h>

#include "spinlock.h"
#include "types.h"
#include "uart.h"

// 十六进制数字表
static const char digits[] = "0123456789abcdef";

// 发一个字符。串口终端需要 \r\n 表示换行
static void putc(int c) {
    if (c == '\n')
        my_put('\r');
    my_put(c);
}

/* 按指定进制打印整数
   base: 10=十进制, 16=十六进制
   sign: 1=负号, 0=无负号 
*/
static void printint(int64 xx, int base, int sign) {
    char buf[32];
    uint64 x;

    if (sign && xx < 0) {
        x = (uint64)(-xx);
    } else {
        x = (uint64)xx;
    }

    int i = 0;
    do {
        buf[i++] = digits[x % base];
        x /= base;
    } while (x != 0);

    if (sign && xx < 0) {
        buf[i++] = '-';
    }

    while (--i >= 0) {
        putc(buf[i]);
    }
}

// 打印指针：16 位十六进制 + 0x 前缀
static void printptr(uint64 x) {
    putc('0');
    putc('x');
    for (int i = 0; i < 16; i++) {
        int shift = (15 - i) * 4;
        putc(digits[(x >> shift) & 0xf]);
    }
}

static struct spinlock pr_lock;
static int pr_lock_inited;

// 格式化输出。支持 %d %u %x %p %s %c %%
void printf(const char *fmt, ...) {
    int c;
    const char *s;
    va_list ap;

    if (!pr_lock_inited) {
        initlock(&pr_lock, "printf");
        pr_lock_inited = 1;
    }

    acquire(&pr_lock);
    va_start(ap, fmt);
    for (; (c = *fmt) != 0; fmt++) {
        if (c != '%') {
            putc(c);
            continue;
        }

        fmt++;
        if (*fmt == 0)
            break;

        switch (*fmt) {
        case 'd':
            printint(va_arg(ap, int), 10, 1);
            break;
        case 'u':
            printint(va_arg(ap, unsigned int), 10, 0);
            break;
        case 'x':
            printint(va_arg(ap, unsigned int), 16, 0);
            break;
        case 'p':
            printptr((uint64)va_arg(ap, void *));
            break;
        case 's':
            s = va_arg(ap, const char *);
            if (s == 0)
                s = "(null)";
            while (*s)
                putc(*s++);
            break;
        case 'c':
            putc(va_arg(ap, int));
            break;
        case '%':
            putc('%');
            break;
        default:
            putc('%');
            putc(*fmt);
            break;
        }
    }
    va_end(ap);
    release(&pr_lock);
}