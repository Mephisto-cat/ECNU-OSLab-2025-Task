#include "lib/method.h"

void *memset(void *dst, int c, uint64 n) {
    char *p = (char *)dst;
    for (uint64 i = 0; i < n; i++) {
        p[i] = (char)c;
    }
    return dst;
}

void *memcpy(void *dst, const void *src, uint64 n) {
    char *d = (char *)dst;
    const char *s = (const char *)src;
    for (uint64 i = 0; i < n; i++) {
        d[i] = s[i];
    }
    return dst;
}

int memcmp(const void *a, const void *b, uint64 n) {
    const char *ca = (const char *)a;
    const char *cb = (const char *)b;
    for (uint64 i = 0; i < n; i++) {
        if (ca[i] != cb[i]) {
            return ca[i] - cb[i];
        }
    }
    return 0;
}
