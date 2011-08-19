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
# Unit test that stores bytes to, and then loads bytes from, memory.
#
		.text
start:
		# Store and load a byte into double word storage
		dli	$a0, 0xfe
		dla	$t3, dword
		sb	$a0, 0($t3)
		lbu	$a0, 0($t3)

		# Store and load bytes with sign extension
		dli	$a1, 1
		dla	$t3, positive
		sb	$a1, 0($t3)
		lb	$a1, 0($t3)

		dli	$a2, -1
		dla	$t3, negative
		sb	$a2, 0($t3)
		lb	$a2, 0($t3)

		# Store and load bytes without sign extension
		dli	$a3, 1
		dla	$t3, positive
		sb	$a3, 0($t3)
		lbu	$a3, 0($t3)

		dli	$a4, -1
		dla	$t3, negative
		sb	$a4, 0($t3)
		lbu	$a4, 0($t3)

		# Store and load bytes at non-zero offsets
		dla	$t0, val1
		dli	$a5, 2
		sb	$a5, 1($t0)
		lb	$a5, 1($t0)

		dla	$t1, val2
		dli	$a6, 1
		sb	$a6, -1($t1)
		lb	$a6, -1($t1)

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
positive:	.byte	0x00
negative:	.byte	0x00
val1:		.byte	0x00
val2:		.byte	0x00
