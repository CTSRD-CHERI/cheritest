#-
# Copyright (c) 2011 William M. Morland
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
# Test of msub which multiplies two 32-bit numbers and then subtracts the
# 64-bit result from the 64-bit number made up of the 32 least significant
# bits in lo and hi.  Results are 32-bit numbers (sign-extended to 64-bits)
# which are stored in hi (most-significant 32 bits) and lo (least-significant
# 32 bits).
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Test itself goes here
		li	$t0, 65535
		li	$t1, 65537
		mult	$t0, $t1
		mfhi	$a0
		mflo	$a1

		li	$t0, 1
		li	$t1, -1
		msub	$t0, $t1
		mfhi	$a2
		mflo	$a3

		li	$t0, 123
		li	$t1, 21
		msub	$t0, $t1
		mfhi	$a4
		mflo	$a5

		li	$t0, -1024
		li	$t1, 536870912
		msub	$t0, $t1
		mfhi	$a6
		mflo	$a7

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
