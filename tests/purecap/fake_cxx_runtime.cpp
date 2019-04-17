#include "cheri_c_test.h"

/* Ensure that we get a capability aligned allocation */
_Alignas(sizeof(void* __capability)) static char _new_buffer[4096];
static unsigned _new_allocated = 0;

// A very simple operator new implementation
void* operator new(unsigned long size) {
	void* result = _new_buffer + _new_allocated;
	// Round the used size to capability size
	_new_allocated += __builtin_align_up(size, sizeof(void* __capability));
	assert(_new_allocated < sizeof(_new_buffer));
	// Check that the result is correctly aligned
	assert(__builtin_is_aligned(result, sizeof(void* __capability)));
	return __builtin_cheri_bounds_set(result, size);
}

extern "C" int printf(const char* msg, ...) {
	DEBUG_MSG(msg);
	return 0;
}
