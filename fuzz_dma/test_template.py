#include "DMAAsm.h"
#include "DMAControl.h"
#include "mips_assert.h"

volatile uint8_t source[$sourcesize];
volatile uint8_t dest[$destsize];

dma_instruction dma_program[] = {
	$program
};

int test(void)
{
	$setsource

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

	$asserts

	return 0;
}
