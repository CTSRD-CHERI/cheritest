#include "assert.h"
#include "DMAAsm.h"
#include "DMAControl.h"
#include "stdint.h"

uint64_t source = 0;
uint64_t dest = 0;

dma_instruction dma_program[2];

int test(void)
{
	uint64_t *source_ptr = &source;
	uint64_t *dest_ptr = &dest;
	*source_ptr = 0xDEADBEDE;

	dma_program[0] = dma_op_transfer(TS_BITS_64);
	dma_program[1] = dma_op_stop();

	dma_set_pc(dma_program);
	dma_set_source_address((uint64_t)source_ptr);
	dma_set_dest_address((uint64_t)dest_ptr);

	dma_start_transfer();

	while (!dma_ready()) {
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
	}

	assert(*dest_ptr == 0xDEADBEDE);
	/*assert(1 == 0);*/
	return 0;
}
