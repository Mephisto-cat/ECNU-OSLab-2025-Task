#ifndef KALLOC_H
#define KALLOC_H

#include "types.h"

void  kinit(void);
void *kalloc(void);
void  kfree(void *pa);

#endif
