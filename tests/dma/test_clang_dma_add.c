#include "assert.h"
#include "DMAAsm.h"
#include "DMAControl.h"
#include "stdint.h"

uint32_t source[8] = { 0, 1, 2, 0, 0, 0, 3, 0xDEAD };
uint32_t dest[9] =   { 1, 0, 0, 0, 0, 0, 0, 0, 0xBEEF };

dma_instruction dma_program[] = {
	DMA_OP_ADD(AT_SOURCE_ONLY, 4),
	DMA_OP_TRANSFER(TS_BITS_32),
	DMA_OP_ADD(AT_DEST_ONLY, 8),
	DMA_OP_TRANSFER(TS_BITS_32),
	DMA_OP_ADD(AT_BOTH, 12),
	DMA_OP_TRANSFER(TS_BITS_32),
	DMA_OP_STOP
};

int test(void)
{
	dma_set_pc(dma_program);
	dma_set_source_address((uint64_t)source);
	dma_set_dest_address((uint64_t)dest);

	dma_start_transfer();

	while(!dma_ready()) {
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
	}

	assert(dest[0] == 1);
	assert(dest[3] == 2);
	assert(dest[7] == 3);
	assert(dest[8] == 0xBEEF);

	return 0;
}
