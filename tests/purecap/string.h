#pragma once

#include <stddef.h>

#define STANDALONE
#define CMEMCPY
#include "../c/memcpy.c"
#undef CMEMCPY

#define CMEMMOVE
#include "../c/memcpy.c"
#undef CMEMMOVE

#define memcpy cmemcpy
#define memmove cmemmove

void*
memset(void *s, int c, size_t len)
{
	unsigned char *dst = s;
	while (len > 0) {
		*dst = (unsigned char)c;
		dst++;
		len--;
	}
	return s;
}

int
strcmp(const char *s1, const char *s2)
{
	while (*s1 == *s2++)
		if (*s1++ == '\0')
			return (0);
	return (*(const unsigned char *)s1 - *(const unsigned char *)(s2 - 1));
}
