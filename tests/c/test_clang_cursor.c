#include "assert.h"
int buffer[42];

extern volatile long long exception_count;

__attribute__((noinline))
void set(__capability int* x)
{
	for (int i=0 ; i<42 ; i++)
	{
		x[i] = i;
	}
}

__attribute__((noinline))
void get(__capability int* x)
{
	for (int i=41 ; i>=0 ; i--,x--)
	{
		assert(*x==i);
	}
}

int test(void)
{
	// Explicitly set the size of the capability
	__capability int *b = __builtin_cheri_set_cap_length((__capability void*)buffer, 42*sizeof(int));
	// Check that the base is correctly set to the start of the array
	assert((long long)buffer == __builtin_cheri_get_cap_base(b));
	// Check that the offset is correctly set to the start of the array
	assert(0 == __builtin_cheri_cap_offset_get(b));
	// Fill in the array such that every element contains its index
	set(b);
	// Check that pointer arithmetic moves the cursor
	b += 41;
	assert(41*sizeof(int) == __builtin_cheri_cap_offset_get(b));
	// Check that the pointer version of the capability is what we'd expect
	DEBUG_DUMP_REG(18, (int*)b);
	DEBUG_DUMP_REG(19, &buffer);
	assert(((int*)b) == &buffer[41]);
	// Check that we can read all of the array back by reverse itteration
	get(b);
	// Now check some explicit cursor manipulation
	__capability int *v = b;
	// Incrementing the offset shouldn't be visible after setting the offset
	v = __builtin_cheri_cap_offset_increment(v, 42);
	v = __builtin_cheri_cap_offset_set(v, 0);
	assert(__builtin_cheri_cap_offset_get(v) == 0);
	// Incrementing the base only should give a negative offset
	v = __builtin_cheri_cap_base_inc_only(v, 10);
	assert(__builtin_cheri_cap_offset_get(v) == -10);
	// Nothing in this test should have triggered any exceptions
	assert(exception_count == 0);
	return 0;
}
