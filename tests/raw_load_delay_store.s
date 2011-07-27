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
# Load from an address into reg a1, and then immediately store the value into
# memory.  As per raw_load_delay.s, MIPS 4400 doesn't require (although does
# encourage) load delay slots.  Unlike raw_load_delay.s, this test checks
# that an immediate store to memory works.  By varying the number of NOPs, we
# can see how far a (possible) bug in pipeline might exist.
#

		.text
start:
		# No NOP
		dla	$a0, load0
		dla	$a1, store0
		ld	$a2, 0($a0)
		sd	$a2, 0($a1)

		# One NOP
		dla	$a0, load1
		dla	$a1, store1
		ld	$a2, 0($a0)
		nop
		sd	$a2, 0($a1)

		# Two NOPs
		dla	$a0, load2
		dla	$a1, store2
		ld	$a2, 0($a0)
		nop
		nop
		sd	$a2, 0($a1)

		# Three NOPs
		dla	$a0, load3
		dla	$a1, store3
		ld	$a2, 0($a0)
		nop
		nop
		nop
		sd	$a2, 0($a1)

		# Spacer to let pipeline drain
		nop
		nop
		nop
		nop
		nop
		nop

		# Load results into temporaries for checking
		dla	$a0, store0
		ld	$t0, 0($a0)
		dla	$a0, store1
		ld	$t1, 0($a0)
		dla	$a0, store2
		ld	$t2, 0($a0)
		dla	$a0, store3
		ld	$t3, 0($a0)

		# Spacer to let pipeline drain
		nop
		nop
		nop
		nop
		nop
		nop

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end

		.data
		.align 5
load0:		.dword	0xfedcba9876543210
load1:		.dword	0xfedcba9876543210
load2:		.dword	0xfedcba9876543210
load3:		.dword	0xfedcba9876543210

		.align 5
store0:		.dword	0
store1:		.dword	0
store2:		.dword	0
store3:		.dword	0
