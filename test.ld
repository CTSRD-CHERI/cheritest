__stack_size__ = 0x400; /* 1k stack */
__mem_top__ = 0x80008000;

__sp = __mem_top__;
__heap_top__ = __mem_top__ - __stack_size__;
__sp_bottom = __heap_top__;

SECTIONS
{
. = 0x40000000;

.text : { init.o(.text) 
	*(EXCLUDE_FILE (init.o) .text) }
.bss : { *(.bss) }
.data : { *(.data)}

__heap = ALIGN(0x8); /*64-bit alligned heap pointer */
__bss_start = ADDR(.bss);
__bss_end = ALIGN(__bss_start + SIZEOF(.bss), 0x8);
}

