#include "DMAAsm.h"
#include "stdint.h"

#ifdef DMAMODEL
#include "DMAModelSimple.h"
#include "ModelAssert.h"
#else
#include "DMAControl.h"
#include "mips_assert.h"
#endif

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
	dma_set_pc(DMA_PHYS, 0, dma_program);
	dma_set_source_address(DMA_PHYS, 0, (uint64_t)(source + 2));
	dma_set_dest_address(DMA_PHYS, 0, (uint64_t)(dest + 2));

	dma_start_transfer(DMA_PHYS, 0);

	while (!dma_thread_ready(DMA_PHYS, 0)) {
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

#ifdef DMAMODEL
int main()
{
	test();
	return 0;
}
#endif
