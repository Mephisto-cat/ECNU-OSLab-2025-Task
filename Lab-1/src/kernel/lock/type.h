#pragma once

#include "arch/type.h"

struct spinlock {
    uint32 locked;
    const char *name;
};
