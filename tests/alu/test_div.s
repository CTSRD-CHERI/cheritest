#-
# Copyright (c) 2011 William M. Morland
# Copyright (c) 2012 Jonathan Woodruff
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
# Test which tries the 32-bit division operator with each combination
# of positive and negative arguments.  Results are 32-bit numbers
# (sign-extended to 64-bits) which are stored in hi (remainder) and lo
# (quotient).
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Test itself goes here
		li	$t0, 123
		li	$t1, 24
		#$zero prevents assembler adding checking instructions
		div	$zero, $t0, $t1
		mfhi	$a0
		mflo	$a1

		li	$t0, -123
		li	$t1, -24
		div	$zero, $t0, $t1
		mfhi	$a2
		mflo	$a3

		li	$t0, -123
		li	$t1, 24
		div	$zero, $t0, $t1
		mfhi	$a4
		mflo	$a5

		li	$t0, 123
		li	$t1, -24
		div	$zero, $t0, $t1
		mfhi	$a6
		mflo	$a7

		# The result of the following is undefined
		# (only way to produce integer divide overflow).
		# Useful to test that cheri does not blow up,
		# don't really care about result. gxemul crashes!
		li      $t0, 0x80000000
		li      $t1, 0xffffffff
		div     $zero, $t0, $t1
		mfhi    $s0
		mflo	$s1
		
		# Below is a case found in the freeBSD kernel,
		# mult followed immediatly by div.
		li	$t0, 25
		li	$t1, 4
		li	$t2, 5
		mul	$t0, $t1, $t0
		div	$zero, $t0, $t2
		mfhi	$s2
		mflo	$s3

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
