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
# Unit test that stores double words to, and then loads double words from,
# memory.  Unlike shorter loads, there is no distinction between
# sign-extended and unsigned loads, but we do positive and negative
# variations to check all is well.
#
		.text
start:
		dli	$a0, 0xfedcba9876543210
		dla	$t3, dword
		sd	$a0, 0($t3)
		ld	$a0, 0($t3)

		# Store and load double with sign extension
		dli	$a1, 1
		dla	$t3, positive
		sd	$a1, 0($t3)
		ld	$a1, 0($t3)

		dli	$a2, -1
		dla	$t3, negative
		sd	$a2, 0($t3)
		ld	$a2, 0($t3)

		# Store and load double words at non-zero offsets
		dla	$t0, val1
		dli	$a3, 2
		sd	$a3, 8($t0)
		ld	$a3, 8($t0)

		dla	$t1, val2
		dli	$a4, 1
		sd	$a4, -8($t1)
		ld	$a4, -8($t1)

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end

		.data
dword:		.dword	0x0000000000000000
positive:	.dword	0x0000000000000000
negative:	.dword	0x0000000000000000
val1:		.dword	0x0000000000000000
val2:		.dword	0x0000000000000000
