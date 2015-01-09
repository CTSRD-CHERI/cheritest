#include "DMAAsm.h"
#include "stdint.h"

#ifdef DMAMODEL
#include "DMAModelSimple.h"
#include "ModelAssert.h"
#else
#include "DMAControl.h"
#include "mips_assert.h"
#endif

uint64_t source_wrap[8];
uint64_t dest_wrap[8];

dma_instruction dma_program[2];

int test(void)
{
	// 256 bit align manually
	uint64_t * source = (uint64_t *)((uint64_t)(&source_wrap + 7) & ~0x1F);
	uint64_t * dest = (uint64_t *)((uint64_t)(&dest_wrap + 7) & ~0x1F);

	source[0] = 1;
	source[1] = 2;
	source[2] = 3;
	source[3] = 4;

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

#ifdef DMAMODEL
int main()
{
	test();
	return 0;
}
#endif
