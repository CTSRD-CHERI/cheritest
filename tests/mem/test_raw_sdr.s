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
.set noat

		.global start
start:
		dla	$a0, dword

		dli	$a1, 0xfedcba9876543210
		sdr	$a1, 0($a0)
		ld	$a1, 0($a0)

		dli	$a2, 0xfedcba9876543210
		sdr	$a2, 1($a0)
		ld	$a2, 0($a0)

		dli	$a3, 0xfedcba9876543210
		sdr	$a3, 2($a0)
		ld	$a3, 0($a0)

		dli	$a4, 0xfedcba9876543210
		sdr	$a4, 3($a0)
		ld	$a4, 0($a0)

		dli	$a5, 0xfedcba9876543210
		sdr	$a5, 4($a0)
		ld	$a5, 0($a0)

		dli	$a6, 0xfedcba9876543210
		sdr	$a6, 5($a0)
		ld	$a6, 0($a0)

		dli	$a7, 0xfedcba9876543210
		sdr	$a7, 6($a0)
		ld	$a7, 0($a0)

		dli	$t0, 0xfedcba9876543210
		sdr	$t0, 7($a0)
		ld	$t0, 0($a0)

		dli	$t1, 0xfedcba9876543210
		sdr	$t1, 8($a0)
		ld	$t1, 8($a0)

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end

		.data
dword:		.dword 0x0000000000000000
