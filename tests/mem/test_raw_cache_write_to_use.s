#-
# Copyright (c) 2011 Robert N. M. Watson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
# ("CTSRD"), as part of the DARPA CRASH research programme.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that stores a series of bytes to memory to test cache store-to-use
# forwarding in sequential cycles.
#
		.text
		.global start
start:
		# Store a series of bytes to a double word.  We do it twice to make sure
		# that the instructions are cached and thus packed together as much as possible.
		# Since we do not load from this location this time, it will be in the L2 cache.
		dla	$a7, dwords
		dli	$a0, 0x00
		dla	$t3, dword
againL2:
# This initial sd causes a cache miss in the L2 that will compact the following byte stores.
		sd  $a7, 0($a7)
		sb	$a0, 0($t3)
		sb	$a0, 1($t3)
		sb	$a0, 2($t3)
		sb	$a0, 3($t3)
		sb	$a0, 4($t3)
		sb	$a0, 5($t3)
		sb	$a0, 6($t3)
		sb	$a0, 7($t3)
		daddi $a7, $a7, 32
		blez $a0, againL2
		addi $a0, $a0, 1
		# Value to test
		ld	$a1, 0($t3)
# Do the same thing for the next word, but since we have just loaded from the line, 
# it will now be in the L1.
startL1:
		dli	$a0, 0x00
againL1:
# This initial ld causes a cache miss in the L1 that will compact the following byte stores.
		ld  $a5, 0($a7)
		sb	$a0, 8($t3)
		sb	$a0, 9($t3)
		sb	$a0,10($t3)
		sb	$a0,11($t3)
		sb	$a0,12($t3)
		sb	$a0,13($t3)
		sb	$a0,14($t3)
		sb	$a0,15($t3)
		daddi $a7, $a7, 32
		blez $a0, againL1
		addi $a0, $a0, 1
		# Value to test
		ld	$a2, 8($t3)

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
		nop

		.data
dword:		.dword	0x0000000000000000
dwords:	    .dword	0x0000000000000000
