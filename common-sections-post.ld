	.data . : {
		. = ALIGN(8);
		*(.data);
		*(.global_sizes);
		*(.rodata);
		*(.rodata.*);
		PROVIDE_HIDDEN(_edata = .);
	}
	__cap_relocs : {
		. = ALIGN(32);
		PROVIDE_HIDDEN(__start___cap_relocs = .);
		*(__cap_relocs);
		PROVIDE_HIDDEN(__stop___cap_relocs = .);
	}
	.got . : {
		. = ALIGN(16);
		PROVIDE_HIDDEN(_gp = ALIGN(16) + 0x7ff0);
		*(.got.plt) *(.got)
	}
	.bss  . : { . = ALIGN(8); *(.bss); } =0
	PROVIDE_HIDDEN(__heap = ALIGN(0x8));	/* 64-bit aligned heap pointer */
	PROVIDE_HIDDEN(__bss_start = ADDR(.bss));
	PROVIDE_HIDDEN(__bss_end = ALIGN(__bss_start + SIZEOF(.bss), 0x8));
	. = .; /* Force placement of orphan sections */
	PROVIDE_HIDDEN(__end_of_elf_file__ = ALIGN(8));
	/DISCARD/ : { *(.MIPS.options) *(.MIPS.abiflags) *(.pdr)}
