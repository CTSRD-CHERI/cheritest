__stack_size__ = 0x400; /* 1k stack */
__mem_top__ = 0x9000000080008000;

__sp = __mem_top__;
__heap_top__ = __mem_top__ - __stack_size__;
__sp_bottom = __heap_top__;

SECTIONS
{
. = 0x9000000040000000;

.text ALIGN(0x8): { init.o(.text) 
	*(EXCLUDE_FILE (init.o) .text) }
.bss ALIGN(0x8): { *(.bss) }
.data ALIGN(0x8): { *(.data)}

__heap = ALIGN(0x8); /*64-bit alligned heap pointer */
__bss_start = ADDR(.bss);
__bss_end = ALIGN(__bss_start + SIZEOF(.bss), 0x8);
}

