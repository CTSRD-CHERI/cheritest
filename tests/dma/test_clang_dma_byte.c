#include "assert.h"
#include "DMAAsm.h"
#include "DMAControl.h"
#include "stdint.h"

uint8_t source = 0xFF;
uint64_t dest  = 0x1122334455667788;

dma_instruction dma_program[2];

int test(void)
{
	dma_program[0] = dma_op_transfer(TS_BITS_8);
	dma_program[1] = dma_op_stop();

	dma_set_pc(dma_program);
	dma_set_source_address((uint64_t)&source);
	dma_set_dest_address((uint64_t)&dest);

	dma_start_transfer();

	while (!dma_ready()) {
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
	}

	assert(dest == 0xFF22334455667788);
	return 0;
}
