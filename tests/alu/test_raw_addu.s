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
# Simple test for addu -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

		.global start
start:
		#
		# addu with independent inputs and outputs; preserve inputs
		# for test framework so we can check they weren't improperly
		# modified.
		#
		li	$s3, 1
		li	$s4, 2
		addu	$a0, $s3, $s4

		#
		# addu with first input as the output
		#
		li	$t0, 1
		li	$a1, 2
		addu	$a1, $a1, $t0

		#
		# addu with second input as the output
		#
		li	$t0, 1
		li	$a2, 2
		addu	$a2, $t0, $a2

		#
		# addu with both inputs the same as the output
		#
		li	$a3, 1
		addu	$a3, $a3, $a3

		#
		# Feed output of one straight into the input of another.
		#
		li	$t0, 1
		li	$t1, 2
		li	$t2, 3
		addu	$t3, $t0, $t1
		addu	$a4, $t3, $t2

		#
		# Even though addu arithmetic is "unsigned", in 64-bit mode,
		# registers are still sign-extended.
		#
		li	$t0, 1
		li	$t1, -1
		addu	$a5, $t0, $t1	# to 0x0000000000000000

		li	$t0, -1
		li	$t1, -1
		addu	$a6, $t0, $t1	# to 0xfffffffffffffffe

		li	$t0, -1
		li	$t1, 2
		addu	$a7, $t0, $t1	# to 0x0000000000000001

		li	$t0, 1
		li	$t1, -2
		addu	$s0, $t0, $t1	# to 0xffffffffffffffff

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
		nop
