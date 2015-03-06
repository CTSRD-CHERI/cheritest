
#include "mips_assert.h"
#include "DMAAsm.h"
#include "DMAControl.h"
#include "stdint.h"
#include "stdbool.h"

// Test that interrupt 31 (the DMA engine) can be mapped to a MIPS interrupt
// input.
// This doesn't test complex IRQ semantics. There are Bluespec unit tests for
// that.

uint64_t * PIC_DMA_CONFIG_REG = (uint64_t *)0x900000007f8040f8;
uint64_t * PIC_IP_READ_BASE   = (uint64_t *)(0x900000007f804000 + (8 * 1024));

dma_instruction dma_program[] = {
	DMA_OP_STOP
};

static inline bool get_dma_irq()
{
	return (*PIC_IP_READ_BASE) & (1 << 31);
}

int test(void)
{
	*PIC_DMA_CONFIG_REG = (1 << 31); // enanble PIC IRQ

	assert(get_dma_irq() == false);

	dma_set_pc(DMA_PHYS, 0, dma_program);

	dma_write_control(DMA_PHYS, 0, DMA_START_TRANSFER | DMA_ENABLE_IRQ);

	while (!dma_thread_ready(DMA_PHYS, 0)) {
		DEBUG_NOP();
		DEBUG_NOP();
		DEBUG_NOP();
		DEBUG_NOP();
	}

	assert(get_dma_irq() == true);

	dma_write_control(DMA_PHYS, 0, DMA_CLEAR_IRQ);

	DEBUG_NOP();
	DEBUG_NOP();
	DEBUG_NOP();
	DEBUG_NOP();

	assert(get_dma_irq() == false);

	return 0;
}
