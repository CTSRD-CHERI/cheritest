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
# Test csbr (store byte via capability, offset by register) using a
# constrained capability.
#

		.global test
test:		.ent test
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Set up $c1 to point at data
		#
		dla	$t0, data
		cincbase	$c1, $c1, $t0

		#
		# We want $c1.length to be 8 -- query the current $c1,
		# subtract 8, and then pass that to cdecleng.
		#
		cgetleng	$t1, $c1
		dsub		$t1, 8
		cdecleng	$c1, $c1, $t1

		dli	$s0, 0
		dli	$t2, 0x01
		csbr	$t2, $c1, $s0
		dli	$s0, 1
		dli	$t2, 0x23
		csbr	$t2, $c1, $s0
		dli	$s0, 2
		dli	$t2, 0x45
		csbr	$t2, $c1, $s0
		dli	$s0, 3
		dli	$t2, 0x67
		csbr	$t2, $c1, $s0
		dli	$s0, 4
		dli	$t2, 0x89
		csbr	$t2, $c1, $s0
		dli	$s0, 5
		dli	$t2, 0xab
		csbr	$t2, $c1, $s0
		dli	$s0, 6
		dli	$t2, 0xcd
		csbr	$t2, $c1, $s0
		dli	$s0, 7
		dli	$t2, 0xef
		csbr	$t2, $c1, $s0

		#
		# Load using regular MIPS instructions for checking.
		#
		dla	$t3, underflow
		ld	$a0, 0($t3)
		dla	$t3, data
		ld	$a1, 0($t3)
		dla	$t3, overflow
		ld	$a2, 0($t3)

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

		.data
		.align 3
underflow:	.dword	0x0000000000000000
data:		.dword	0x0000000000000000
overflow:	.dword	0x0000000000000000
