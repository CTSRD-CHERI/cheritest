#include "cheri_c_test.h"

static char _new_buffer[4096];
static unsigned _new_allocated = 0;

void* operator new(unsigned long size) {
	void* result = _new_buffer + _new_allocated;
	_new_allocated += size;
	assert(_new_allocated < sizeof(_new_buffer));
	return __builtin_cheri_bounds_set(result, size);
}

extern "C" int printf(const char* msg, ...) {
	DEBUG_MSG(msg);
	return 0;
}
