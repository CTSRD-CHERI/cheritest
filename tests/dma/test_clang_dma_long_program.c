#include "DMAAsm.h"
#include "stdint.h"

#ifdef DMAMODEL
#include "DMAModelSimple.h"
#include "ModelAssert.h"
#else
#include "DMAControl.h"
#include "mips_assert.h"
#endif

// This is designed to test program occupying more than one line of the DMA
// ICache.

uint8_t source[] = { 0, 1, 2, 3, 4, 5, 6, 7 };
uint8_t dest[]   = { 9, 9, 9, 9, 9, 9, 9, 9 };

dma_instruction dma_program[] = {
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_STOP
};

int test(void)
{
	dma_set_pc(dma_program);
	dma_set_source_address((uint64_t)source);
	dma_set_dest_address((uint64_t)dest);

	dma_start_transfer();

	while (!dma_ready()) {
		DEBUG_NOP();
		DEBUG_NOP();
		DEBUG_NOP();
		DEBUG_NOP();
	}

	for (uint64_t i = 0; i < 8; ++i) {
		assert(dest[i] == i);
	}

	return 0;
}

#ifdef DMAMODEL
int main()
{
	test();
	return 0;
}
#endif
