#include <stdarg.h>

#include "spinlock.h"
#include "types.h"
#include "uart.h"

static struct spinlock pr_lock;
static int pr_lock_inited;

static const char digits[] = "0123456789abcdef";

static void putc(int c)
{
    if (c == '\n')
        uartputc_sync('\r');    // 串口需要 \r\n
    uartputc_sync(c);
}

static void printint(int64 xx, int base, int sign)
{
    char buf[32];
    int i;
    uint64 x;

    if (sign && xx < 0)
        x = (uint64)(-xx);
    else
        x = (uint64)xx;

    i = 0;
    do {
        buf[i++] = digits[x % base];
        x /= base;
    } while (x != 0);

    if (sign && xx < 0)
        buf[i++] = '-';

    while (--i >= 0)
        putc(buf[i]);
}

static void printptr(uint64 x)
{
    int i;
    putc('0');
    putc('x');
    for (i = 0; i < 16; i++) {
        int shift = (15 - i) * 4;
        putc(digits[(x >> shift) & 0xf]);
    }
}

// 支持 %d %u %x %p %s %c %%
void printf(const char *fmt, ...)
{
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
