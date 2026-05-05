#pragma once

#include "arch/type.h"

void *memset(void *dst, int c, uint64 n);
void *memcpy(void *dst, const void *src, uint64 n);
int   memcmp(const void *a, const void *b, uint64 n);
