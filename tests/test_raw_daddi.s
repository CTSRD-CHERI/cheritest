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
# Simple test for daddi -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

start:
		#
		# daddi with independent input and output; preserve input for
		# test framework so we can check it wasn't improperly
		# modified.
		#
		dli	$a0, 1
		daddi	$a1, $a0, 1

		#
		# daddi with input as the output
		#
		dli	$a2, 1
		daddi	$a2, $a2, 1

		#
		# Feed output of one straight into the input of another.
		#
		dli	$a3, 1
		daddi	$a3, $a3, 1
		daddi	$a3, $a3, 1

		#
		# check that immediate is sign-extended
		#
		dli	$a4, 1
		daddi	$a4, $a4, -1

		#
		# simple exercises for signed arithmetic
		#
		dli	$a5, 1
		daddi	$a5, $a5, -1	# to zero

		dli	$a6, -1
		add	$a6, $a6, -1	# to negative

		dli	$a7, -1
		daddi	$a7, $a7, 2	# to positive

		dli	$s0, 1
		add	$s0, $s0, -2	# to negative

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
