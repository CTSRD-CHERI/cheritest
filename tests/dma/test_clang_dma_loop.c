#include "assert.h"
#include "DMAAsm.h"
#include "DMAControl.h"
#include "stdint.h"

uint32_t source[6] = { 0xA, 0xB, 0xC, 0xD, 0xE, 0xF };
uint32_t dest[6] = {0, 0, 0, 0, 0, 0};

dma_instruction dma_program[4];

int test(void)
{
	dma_program[0] = dma_op_set(LOOP_REG_0, 4);
	dma_program[1] = dma_op_transfer(TS_BITS_32);
	dma_program[2] = dma_op_loop(LOOP_REG_0, 1);
	dma_program[3] = dma_op_stop();

	dma_set_pc(dma_program);
	dma_set_source_address((uint64_t)source);
	dma_set_dest_address((uint64_t)dest);

	dma_start_transfer();

	while (!dma_ready()) {
		asm("nop");
		asm("nop");
		asm("nop");
		asm("nop");
	}

	assert(dest[0] == 0xA);
	assert(dest[1] == 0xB);
	assert(dest[2] == 0xC);
	assert(dest[3] == 0xD);
	assert(dest[4] == 0xE);
	assert(dest[5] == 0);

	return 0;
}