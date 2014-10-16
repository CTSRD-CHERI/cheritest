#include "assert.h"
#include "DMAAsm.h"
#include "DMAControl.h"
#include "stdint.h"

int8_t source[] = { -2, -1, 0 };
int8_t dest[] =   {  1,  1, 1 };

dma_instruction dma_program[] = {
	DMA_OP_SUB(AT_BOTH, 1),
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_SUB(AT_SOURCE_ONLY, 2),
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_SUB(AT_DEST_ONLY, 3),
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_STOP
};

int test(void)
{
	dma_set_pc(dma_program);
	dma_set_source_address((uint64_t)(source + 2));
	dma_set_dest_address((uint64_t)(dest + 2));

	dma_start_transfer();

	while (!dma_ready()) {
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
	}

	assert(dest[0] == -1);
	assert(dest[1] == -1);
	assert(dest[2] == -2);

	return 0;
}
