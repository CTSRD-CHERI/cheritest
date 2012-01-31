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
# Simple test for addiu -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

		.global start
start:
		#
		# add with independent input and output; preserve input for
		# test framework so we can check it wasn't improperly
		# modified.
		#
		li	$a0, 1
		addiu	$a1, $a0, 1

		#
		# add with input as the output
		#
		li	$a2, 1
		addiu	$a2, $a2, 1

		#
		# Feed output of one straight into the input of another.
		#
		li	$a3, 1
		addiu	$a3, $a3, 1
		addiu	$a3, $a3, 1

		#
		# check that immediate is sign-extended
		#
		li	$a4, 1
		addiu	$a4, $a4, -1

		#
		# Even though addiu arithmetic is "unsigned", in 64-bit mode,
		# registers are still sign-extended.
		#
		li	$a5, 1
		addiu	$a5, $a5, -1	# to 0x0000000000000000

		li	$a6, -1
		add	$a6, $a6, -1	# to 0xfffffffffffffffe

		li	$a7, -1
		addiu	$a7, $a7, 2	# to 0x0000000000000001

		li	$s0, 1
		add	$s0, $s0, -2	# to 0xffffffffffffffff

		#
		# Muck around with higher 32 bits in a way that should be
		# masked in the output due to sign extension at 32 bits.
		#
		dli	$t0, 0x0010000000000000		# top 32b -> 0's
		addiu	$s1, $t0, 1

		dli	$t0, 0xffeffffffffffffe		# top 32b -> 1's
		addiu	$s2, $t0, 1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
		nop
