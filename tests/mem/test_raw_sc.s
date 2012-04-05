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
# Unit test that stores words to, and then loads words from, memory using
# store conditional.  Interruption behaviour is deferred to a higher-level
# test.
#

		.text
		.global start
start:
		#
		# Store conditional only works against addresses in cached
		# memory.  Calculate a cached address for our data segment,
		# and store pointer in $gp.
		#

		dla	$gp, dword
		dli	$a0, 0x00000000FFFFFFFF
		and $gp, $gp, $a0
		dli	$t0, 0x9800000000000000		# Cached, non-coherenet
		daddu	$gp, $gp, $t0

		# Initialize link register to the store address.
		ll 	$k0, 0($gp)
		
		# Store and load a word into double word storage
		dli	$a0, 0xfedcba98
		sc	$a0, 0($gp)			# @dword
		lwu	$a1, 0($gp)

		# Store and load words with sign extension
		daddiu	$gp, $gp, 8			# @positive
		ll 	$k0, 0($gp)
		dli	$a2, 1
		sc	$a2, 0($gp)
		lw	$a3, 0($gp)

		daddiu	$gp, $gp, 4			# @negative
		ll 	$k0, 0($gp)
		dli	$a4, -1
		sc	$a4, 0($gp)
		lw	$a5, 0($gp)

		# Store and load words at non-zero offsets
		daddiu	$gp, $gp, 4			# @val1
		ll 	$k0, 4($gp)
		dli	$a6, 2
		sc	$a6, 4($gp)
		lw	$a7, 4($gp)

		daddiu	$gp, $gp, 4			# @val2
		ll 	$k0, -4($gp)
		dli	$s0, 1
		sc	$s0, -4($gp)
		lw	$s1, -4($gp)

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
positive:	.word	0x00000000
negative:	.word	0x00000000
val1:		.word	0x00000000
val2:		.word	0x00000000
