#ifndef MIPS_TLB_H
#define MIPS_TLB_H

volatile inline void
add_tlb_mapping(uint64_t virtual_pn, uint64_t physical_pn_0,
		uint64_t physical_pn_1)
{
	// Important CP0 Registers
	// Page Mask: 	R5,  S0
	// EntryLo0 	R2,  S0
	// EntryLo1	R3,  S0
	// EntryHi	R10, S0

	uint64_t page_mask = 0;
	uint64_t entry_hi = virtual_pn << 12;
	// | 7 sets Valid, Dirty (Writeble) and Global bit so that ASID
	// comparison is skipped
	uint64_t entry_lo0 = (physical_pn_0 << 6) | 7;
	uint64_t entry_lo1 = (physical_pn_1 << 6) | 7;

	asm ("dmtc0 %0, $5"  : : "r"(page_mask));
	asm ("dmtc0 %0, $2"  : : "r"(entry_lo0));
	asm ("dmtc0 %0, $3"  : : "r"(entry_lo1));
	asm ("dmtc0 %0, $10" : : "r"(entry_hi));
	asm ("tlbwr");
}

#endif
