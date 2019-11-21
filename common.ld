/*
 * Copyright (c) 2019 Alex Richardson
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory (Department of Computer Science and
 * Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
 * DARPA SSITH research programme.
 *
 * Copyright (c) 2011-2012 Robert N. M. Watson
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

__stack_size__ = 0x1000; /* 4k stack */
__kernel_load_offset__ = 0x100000;
__cached_base_32__ = 0xffffffff80000000;
__cached_base__ = 0x9800000000000000;
__uncached_base__ = 0x9000000000000000;
__boot_phys_addr__ = 0x000000ff40000000;
__mem_size__ = 0x8000000 - __kernel_load_offset__;
__sp = __cached_base__ + __mem_size__ - __stack_size__;
__os_memory_size__ = __mem_size__ - __stack_size__;
__os_elf_header__ = __cached_base__ + __kernel_load_offset__;
__dip_switches__ = __uncached_base__ + 0xff7f009000;
__dtb__ = __uncached_base__ + 0xff7f010000;
__spin_table_top__ =  __cached_base__ + __kernel_load_offset__;
/*
 * It seems like LLD allows us to define __base__ = __(un)cached_base__
 * in the mains script so that these can be resolved lazily
 */
__mem_size__ = 0x8000;
__mem_top__ = __base__ + __mem_size__;
__sp = __mem_top__ - __stack_size__;
__heap_top__ = __mem_top__ - __stack_size__;
__sp_bottom = __heap_top__;
__text_start_phys__ = __kernel_load_offset__ + SIZEOF_HEADERS;
__text_start__ = __base__ + __text_start_phys__;
