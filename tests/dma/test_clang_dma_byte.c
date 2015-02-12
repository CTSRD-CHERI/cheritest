#include "DMAAsm.h"
#include "stdint.h"

#ifdef DMAMODEL
#include "ModelAssert.h"
#include "DMAModelSimple.h"
#else
#include "DMAControl.h"
#include "mips_assert.h"
#endif

uint8_t source = 0xFF;
uint64_t dest  = 0x1122334455667788;

dma_instruction dma_program[2];

int test(void)
{
	dma_program[0] = dma_op_transfer(TS_BITS_8);
	dma_program[1] = dma_op_stop();

	dma_set_pc(0, dma_program);
	dma_set_source_address(0, (uint64_t)&source);
	dma_set_dest_address(0, (uint64_t)&dest);

	dma_start_transfer(0);

	while (!dma_thread_ready(0)) {
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
	}

#ifdef DMAMODEL
	// There may be a way to properly simulate different endiannesses, but
	// if there is I don't know it.
	assert(dest == 0x11223344556677FF);
#else
	assert(dest == 0xFF22334455667788);
#endif
	return 0;
}

#ifdef DMAMODEL
int main()
{
	test();
	return 0;
}
#endif
