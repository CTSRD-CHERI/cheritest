#include "DMAAsm.h"
#include "DMAControl.h"
#include "mips_assert.h"
#include "stdint.h"

static volatile void
add_tlb_mapping(uint64_t virtual_pn, uint64_t physical_pn_0,
		uint64_t physical_pn_1)
{
	// Important CP0 Registers
	// Page Mask: 	R5,  S0
	// EntryLo0 	R2,  S0
	// EntryLo1	R3,  S0
	// EntryHi	R10, S0

	uint64_t page_mask = 0;
	uint64_t entry_hi = virtual_pn << 13;
	// & 7 sets Valid, Dirty (Writeble) and Global bit so that ASID
	// comparison is skipped
	uint64_t entry_lo0 = (physical_pn_0 << 6) & 7;
	uint64_t entry_lo1 = (physical_pn_1 << 6) & 7;

	asm (
		"dmtc0 %0, $5;"
		"dmtc0 %1, $2;"
		"dmtc0 %2, $3;"
		"dmtc0 %3, $10;"
		"tlbwr"
		: /* No outputs */
		: "r"(page_mask), "r"(entry_lo0), "r"(entry_lo1), "r"(entry_hi)
	    );
}

dma_instruction dma_program_physical[] = {
	DMA_OP_TRANSFER(TS_BITS_64),
	DMA_OP_STOP
};

// Let's arbitrarily map virtual pages 40 and 41 to physical pages 11
// and 73. Let's put the program into physical page 11, and the data
// in 73.

#define PHYSICAL_START		((void *)0x9000000000000000)
#define PHYS_P0_START		((void *)(PHYSICAL_START + (11 << 13)))
#define PHYS_P1_START		((void *)(PHYSICAL_START + (73 << 13)))
#define VIRT_P0_START		((void *)(40 << 13))
#define VIRT_P1_START		((void *)(41 << 13))

int test(void) {
	add_tlb_mapping(20, 11, 73);

	*(uint64_t *)PHYS_P0_START = *(uint64_t *)(dma_program_physical);
	*(uint64_t *)PHYS_P1_START = 0xFEEDBEDE;

	dma_set_pc(0, VIRT_P0_START);
	dma_set_source_address(0, (uint64_t)VIRT_P1_START);
	dma_set_dest_address(0, (uint64_t)(VIRT_P1_START + 8));

	dma_start_transfer(0);

	while (!dma_thread_ready(0)) {
		DEBUG_NOP();
		DEBUG_NOP();
		DEBUG_NOP();
		DEBUG_NOP();
	}

	assert(*(uint64_t *)(PHYS_P1_START + 8) == 0xFEEDBEDE);

	return 0;
}
