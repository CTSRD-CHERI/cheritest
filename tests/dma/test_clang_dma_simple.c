#include "DMAAsm.h"
#include "stdint.h"

#ifdef DMAMODEL
#include "DMAModelSimple.h"
#include "ModelAssert.h"
#else
#include "DMAControl.h"
#include "mips_assert.h"
#endif

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

	dma_set_pc(DMA_PHYS, 0, dma_program);
	dma_set_source_address(DMA_PHYS, 0, (uint64_t)source_ptr);
	dma_set_dest_address(DMA_PHYS, 0, (uint64_t)dest_ptr);

	dma_start_transfer(DMA_PHYS, 0);

	while (!dma_thread_ready(DMA_PHYS, 0)) {
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

#ifdef DMAMODEL
int main()
{
	test();
	return 0;
}
#endif
