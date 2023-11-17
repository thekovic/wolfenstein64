// WL_UTILS.C

#include "wl_def.h"
#include "wl_utils.h"

/*
===================
=
= safe_malloc
=
= Wrapper for malloc with a NULL check
=
===================
*/

void *safe_malloc (size_t size, const char *fname, uint32_t line)
{
    void *ptr;

    ptr = malloc(size);

    if (!ptr)
        Quit ("SafeMalloc: Out of memory at %s: line %u",fname,line);

    return ptr;
}

fixed FixedMul (fixed a, fixed b)
{
    return (fixed)(((int64_t)a * b + 0x8000) >> FRACBITS);
}

fixed FixedDiv (fixed a, fixed b)
{
    int64_t c = ((int64_t)a << FRACBITS) / (int64_t)b;

    return (fixed)c;
}

 __attribute__((always_inline))
char* itoa(int value, char* string, int radix)
{
    sprintf(string, "%d", value);
    return string;
}

 __attribute__((always_inline))
char* ltoa(long value, char* string, int radix)
{
    sprintf(string, "%ld", value);
    return string;
}

word READWORD (byte *ptr)
{
    word val = ptr[0] | ptr[1] << 8;

    return val;
}

longword READLONGWORD (byte *ptr)
{
    longword val = ptr[0] | ptr[1] << 8 | ptr[2] << 16 | ptr[3] << 24;

    return val;
}
