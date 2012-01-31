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

		.global start
start:
		# Set all registers to known values so that we can check they
		# are unmodified after the NOP.
		dli	$zero, 0		# no-op
		dli	$at, 1
		dli	$v0, 2
		dli	$v1, 3
		dli	$a0, 4
		dli	$a1, 5
		dli	$a2, 6
		dli	$a3, 7
		dli	$a4, 8
		dli	$a5, 9
		dli	$a6, 10
		dli	$a7, 11
		dli	$t0, 12
		dli	$t1, 13
		dli	$t2, 14
		dli	$t3, 15
		dli	$s0, 16
		dli	$s1, 17
		dli	$s2, 18
		dli	$s3, 19
		dli	$s4, 20
		dli	$s5, 21
		dli	$s6, 22
		dli	$s7, 23
		dli	$t8, 24
		dli	$t9, 25
		dli	$k0, 26
		dli	$k1, 27
		dli	$gp, 28
		dli	$sp, 29
		dli	$fp, 30
		dli	$ra, 31

		# Perform a NOP; we can then check if any registers changed.
		nop

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
		nop
