#include "DMAAsm.h"
#include "stdint.h"

#ifdef DMAMODEL
#include "DMAModelSimple.h"
#include "ModelAssert.h"
#else
#include "DMAControl.h"
#include "mips_assert.h"
#endif

// This is as much as we can run on the simulator. Oh well!
const uint64_t size = 0x4000;

// Source starts offset, because otherwise it collides with the stack.
uint64_t source     = 0x9000000000008000;
uint64_t dest       = 0x9000000020000000;

// We copy from the bottom 512MiB of memory into the top 512 MiB.
// The program is loop unrolled to minimise the missed cycles due to the loop
// instruction.
// It is unrolled to a total program size of 8 instructions so as to fit
// exactly in a DMA ICache line.
// Loop reg value is size / (5 * 32) - 1

dma_instruction dma_program[] = {
	DMA_OP_SET(LOOP_REG_0, size / (5 * 32) - 1),
	DMA_OP_TRANSFER(TS_BITS_256),
	DMA_OP_TRANSFER(TS_BITS_256),
	DMA_OP_TRANSFER(TS_BITS_256),
	DMA_OP_TRANSFER(TS_BITS_256),
	DMA_OP_TRANSFER(TS_BITS_256),
	DMA_OP_LOOP(LOOP_REG_0, 5),
	DMA_OP_STOP
};

int test(void)
{
#ifdef DMAMODEL
	source = (uint64_t)malloc(size);
	dest = (uint64_t)malloc(size);
#endif
	uint16_t volatile *cursor, count = 0;
	for (cursor = (uint16_t *)source; cursor < (source + size / 2); ++cursor) {
		*cursor = count;
		++count;
	}

	dma_set_pc(dma_program);
	dma_set_source_address(source);
	dma_set_dest_address(dest);

	dma_start_transfer();

	while (!dma_ready()) {
		for (uint32_t stall = 0; stall < 1000; ++stall) {
			DEBUG_NOP();
			DEBUG_NOP();
			DEBUG_NOP();
			DEBUG_NOP();
		}
	}

	count = 0;
	for (cursor = (uint16_t *)dest; cursor < (dest + size / 2); ++cursor) {
		if (*cursor != count) {
			DEBUG_DUMP_REG(10, cursor);
			DEBUG_DUMP_REG(11, *cursor);
			DEBUG_DUMP_REG(12, count);
		}
		assert(*cursor == count);
		++count;
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
