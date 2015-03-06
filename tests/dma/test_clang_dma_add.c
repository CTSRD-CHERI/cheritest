#include "DMAAsm.h"
#include "stdint.h"

#ifdef DMAMODEL
#include "DMAModelSimple.h"
#include "ModelAssert.h"
#else
#include "DMAControl.h"
#include "mips_assert.h"
#endif

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
	dma_set_pc(DMA_PHYS, 0, dma_program);
	dma_set_source_address(DMA_PHYS, 0, (uint64_t)source);
	dma_set_dest_address(DMA_PHYS, 0, (uint64_t)dest);

	dma_start_transfer(DMA_PHYS, 0);

	while(!dma_thread_ready(DMA_PHYS, 0)) {
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

#ifdef DMAMODEL
int main()
{
	test();
	return 0;
}
#endif
