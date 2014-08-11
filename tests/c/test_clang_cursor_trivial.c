#include "assert.h"
int buffer[42];

extern volatile long long exception_count;

int test(void)
{
	__capability int *b = (__capability int*)buffer;
	long long count = exception_count;
	b[41] = 12;
	// Explicitly set the length of the capability, in case the compiler fails
	__capability volatile int *v = __builtin_cheri_set_cap_length(b, sizeof(buffer));
	// Set the cursor past the end and check that dereferencing fires an exception
	v = __builtin_cheri_cap_offset_increment((__capability void*)v, 42*sizeof(int));
	int unused = *v;
	assert(exception_count == count+1);
	// Move the cursor back into range and check that it works
	v = __builtin_cheri_cap_offset_increment((__capability void*)v, (-1)*sizeof(int));
	assert(*v == 12);
	// Set the cursor before the start and check that dereferencing fires an exception
	v = __builtin_cheri_cap_offset_set((__capability void*)v, -1);
	unused = *v;
	assert(exception_count == count+2);
	// Move the cursor back into range and check that it works
	v = __builtin_cheri_cap_offset_set((__capability void*)v, 41*sizeof(int));
	assert(*v == 12);
	return 0;
}
