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

#
# Check that the CP0 "lladdr" register is properly updated during load linked
# and store conditional operations.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Save addresses that will be checked in test results;
		# convert to physical addresses as that is what lladdr will
		# report.
		#
		dli	$t0, 0x9800000000000000
		dla	$s0, word1
		dsubu	$s0, $s0, $t0
		dla	$s1, word2
		dsubu	$s1, $s1, $t0
		dla	$s2, word3
		dsubu	$s2, $s2, $t0
		dla	$s3, dword1
		dsubu	$s3, $s3, $t0
		dla	$s4, dword2
		dsubu	$s4, $s4, $t0
		dla	$s5, dword3
		dsubu	$s5, $s5, $t0

		#
		# Query value on reset
		#
		dmfc0	$a0, $17

		#
		# Simple load linked and store conditional
		#
		ll	$t0, word1
		nop
		nop
		nop
		dmfc0	$a1, $17
		sc	$t0, word1
		nop
		nop
		nop
		dmfc0	$a2, $17

		#
		# Simple load linked and store conditional double word1
		#
		lld	$t0, dword1
		nop
		nop
		nop
		dmfc0	$a3, $17
		scd	$t0, dword1
		nop
		nop
		nop
		dmfc0	$a4, $17

		#
		# If we do two load linkeds in a row, we get the second one.
		#
		ll	$t0, word1
		ll	$t0, word2
		nop
		nop
		nop
		dmfc0	$a5, $17

		#
		# If we do two load linked double words in a row, we get the
		# second one.
		#
		lld	$t0, dword1
		lld	$t0, dword2
		nop
		nop
		nop
		dmfc0	$a6, $17

		#
		# If we interrupt the load linked, store conditional through
		# an operation that clears LLbit, we should still get the
		# same address.
		#
		ll	$t0, word3
		sw	$zero, word3
		nop
		nop
		nop
		dmfc0	$a7, $17

		#
		# If we interrupt the load linked, store conditional double
		# word through an operation that clears LLbit, we should
		# still get the same address.
		#
		lld	$t0, dword3
		sd	$zero, dword3
		nop
		nop
		nop
		dmfc0	$s6, $17

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

		.data
word1:		.word	0xffffffff
word2:		.word	0xffffffff
word3:		.word	0xffffffff
fill:		.word	0x00000000		
dword1:		.dword	0xffffffffffffffff
dword2:		.dword	0xffffffffffffffff
dword3:		.dword	0xffffffffffffffff
