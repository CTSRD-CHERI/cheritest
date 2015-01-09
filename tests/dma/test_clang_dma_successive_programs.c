#include "DMAAsm.h"
#include "stdint.h"

#ifdef DMAMODEL
#include "DMAModelSimple.h"
#include "ModelAssert.h"
#else
#include "DMAControl.h"
#include "mips_assert.h"
#endif

uint8_t source1[] = { 0xBE };
uint8_t dest1[]   = { 0 };

dma_instruction dma_program1[] = {
	DMA_OP_TRANSFER(TS_BITS_8),
	DMA_OP_STOP
};

uint64_t source2[] = { 0xDEADBEEF };
uint64_t dest2[]   = { 0 };

dma_instruction dma_program2[] = {
	DMA_OP_TRANSFER(TS_BITS_64),
	DMA_OP_STOP
};

int test(void)
{
	dma_set_pc(dma_program1);
	dma_set_source_address((uint64_t)source1);
	dma_set_dest_address((uint64_t)dest1);

	dma_start_transfer();

	//We can set up the new transfer whilst the old transfer is happening.

	dma_set_pc(dma_program2);
	dma_set_source_address((uint64_t)source2);
	dma_set_dest_address((uint64_t)dest2);

	while (!dma_ready()) {
		DEBUG_NOP();
		DEBUG_NOP();
		DEBUG_NOP();
		DEBUG_NOP();
	}

	dma_start_transfer();

	while (!dma_ready()) {
		DEBUG_NOP();
		DEBUG_NOP();
		DEBUG_NOP();
		DEBUG_NOP();
	}

	assert(dest1[0] == 0xBE);
	assert(dest2[0] == 0xDEADBEEF);

	return 0;
}

#ifdef DMAMODEL
int main()
{
	test();
	return 0;
}
#endif
