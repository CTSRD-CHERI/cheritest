#include "DMAAsm.h"
#include "stdint.h"

#ifdef DMAMODEL
#include "DMAModelSimple.h"
#include "ModelAssert.h"
#else
#include "DMAControl.h"
#include "mips_assert.h"
#endif

uint32_t source[6] = { 0xA, 0xB, 0xC, 0xD, 0xE, 0xF };
uint32_t dest[6] = {0, 0, 0, 0, 0, 0};

dma_instruction dma_program[4];

int test(void)
{
	dma_program[0] = dma_op_set(LOOP_REG_0, 4);
	dma_program[1] = dma_op_transfer(TS_BITS_32);
	dma_program[2] = dma_op_loop(LOOP_REG_0, 1);
	dma_program[3] = dma_op_stop();

	dma_set_pc(0, dma_program);
	dma_set_source_address(0, (uint64_t)source);
	dma_set_dest_address(0, (uint64_t)dest);

	dma_start_transfer(0);

	while (!dma_thread_ready(0)) {
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

#ifdef DMAMODEL
int main()
{
	test();
	return 0;
}
#endif
