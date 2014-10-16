#include "assert.h"
#include "DMAAsm.h"
#include "DMAControl.h"
#include "stdint.h"

uint64_t source[4] = { 1, 2, 3, 4 };
uint64_t dest[4] = { 0, 0, 0, 0 };

dma_instruction dma_program[2];

int test(void)
{

	dma_program[0] = DMA_OP_TRANSFER(TS_BITS_256);
	dma_program[1] = dma_op_stop();

	dma_set_pc(dma_program);
	dma_set_source_address((uint64_t)source);
	dma_set_dest_address((uint64_t)dest);

	dma_start_transfer();

	// Aggressive polling clogs the bus, but this catches a bug where the
	// DMA would report that it had finished before all the write
	// responses were returned.
	while (!dma_ready()) {
	}

	assert(dest[0] == 1);
	assert(dest[1] == 2);
	assert(dest[2] == 3);
	assert(dest[3] == 4);

	return 0;
}
