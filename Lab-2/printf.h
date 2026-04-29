#ifndef PRINTF_H
#define PRINTF_H

/*
 * 自己实现的简化版 printf，无任何标准库依赖。
 * 支持的格式符：%d %u %x %p %s %c %%
 */
void printf(const char *fmt, ...);

#endif
