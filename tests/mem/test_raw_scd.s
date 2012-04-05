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
# memory using store conditional.  Interruption behaviour is deferred to a
# higher-level test.
#

		.text
		.global start
start:
		#
		# Store conditional only works against addresses in cached
		# memory.  Calculate a cached address for our data segment,
		# and store pointer in $gp.
		#

		dla	$gp, dword
		dli	$a0, 0x00000000FFFFFFFF
		and $gp, $gp, $a0
		dli	$t0, 0x9800000000000000		# Cached, non-coherenet
		daddu	$gp, $gp, $t0

		# Initialize link register to the store address.
		lld 	$k0, 0($gp)
		
		# Store and load a double word into double word storage
		dli	$a0, 0xfedcba9876543210
		scd	$a0, 0($gp)			# @dword
		ld	$a1, 0($gp)

		# Store and load double with sign extension
		daddiu	$gp, $gp, 8			# @positive
		lld 	$k0, 0($gp)
		dli	$a2, 1
		scd	$a2, 0($gp)
		ld	$a3, 0($gp)

		daddiu	$gp, $gp, 8			# @negative
		lld 	$k0, 0($gp)
		dli	$a4, -1
		scd	$a4, 0($gp)
		ld	$a5, 0($gp)

		# Store and load double words at non-zero offsets
		daddiu	$gp, $gp, 8			# @val1
		lld 	$k0, 8($gp)
		dli	$a6, 2
		scd	$a6, 8($gp)
		ld	$a7, 8($gp)

		daddiu	$gp, $gp, 8			# @val2
		lld 	$k0, -8($gp)
		dli	$s0, 1
		scd	$s0, -8($gp)
		ld	$s1, -8($gp)

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
		nop

		.data
dword:		.dword	0x0000000000000000
positive:	.dword	0x0000000000000000
negative:	.dword	0x0000000000000000
val1:		.dword	0x0000000000000000
val2:		.dword	0x0000000000000000
