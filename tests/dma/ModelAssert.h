#ifndef MODEL_ASSERT_H
#define MODEL_ASSERT_H

#include "stdlib.h"
#include "stdio.h"

void _assert(int cond, int line)
{
    if (!cond) {
        printf("%d\n", line);
        exit(1);
    }
}
#define assert(cond) _assert(cond, __LINE__)

#define DEBUG_NOP()

void _debug_dump_reg(int regno, long int val)
{
    fprintf(stderr, "r%d <- %ld = 0x%lx\n", regno, val, val);
}

#define DEBUG_DUMP_REG(regno, val) _debug_dump_reg(regno, (long int)val)

#endif
