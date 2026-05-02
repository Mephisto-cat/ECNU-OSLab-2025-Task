#ifndef KALLOC_H
#define KALLOC_H

#include "types.h"

void  kinit();
void *kalloc();
void  kfree(void *pa);

#endif
