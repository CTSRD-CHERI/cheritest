	/* Rodata */
	.rodata . : {
		. = ALIGN(8);
		*(.rodata);
		*(.rodata.*);
	} :p_code_rodata
	__cap_relocs . : {
		PROVIDE_HIDDEN(__start___cap_relocs = ABSOLUTE(.));
		*(__cap_relocs);
		PROVIDE_HIDDEN(__stop___cap_relocs = ABSOLUTE(.));
	} :p_rwdata
	.got . : {
		. = ALIGN(16);
		PROVIDE_HIDDEN(_gp = ABSOLUTE(ALIGN(16) + 0x7ff0));
		*(.got.plt) *(.got)
	} :p_rwdata
	.data . : {
		. = ALIGN(8);
		*(.data);
		*(.global_sizes);
		PROVIDE_HIDDEN(_edata = ABSOLUTE(.));
	} :p_rwdata
	.bss  . : {
		. = ALIGN(8);
		*(.bss);
	} :p_rwdata =0
	PROVIDE_HIDDEN(__heap = ABSOLUTE(ALIGN(0x8)));	/* 64-bit aligned heap pointer */
	PROVIDE_HIDDEN(__bss_start = ADDR(.bss));
	PROVIDE_HIDDEN(__bss_end = ALIGN(__bss_start + SIZEOF(.bss), 0x8));
	. = .; /* Force placement of orphan sections */
	PROVIDE_HIDDEN(__end_of_elf_file__ = ALIGN(8));
	/DISCARD/ : { *(.MIPS.options) *(.MIPS.abiflags) *(.pdr)}
