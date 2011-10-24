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
# Test a burst of sequential stores to memory from registers.  Repeat multiple
# times so that the sequence runs from the instruction cache at least once.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		dli	$k0, 8

		dla	$t0, dword

		dli	$s0, 0x0123456789abcdef
		dli	$s1, 0x0123456789abcdef
		dli	$s2, 0x0123456789abcdef
		dli	$s3, 0x0123456789abcdef
		dli	$s4, 0x0123456789abcdef
		dli	$s5, 0x0123456789abcdef
		dli	$s6, 0x0123456789abcdef
		dli	$s7, 0x0123456789abcdef

		dli	$t0, 0x0123456789abcdef
		dli	$t1, 0x0123456789abcdef
		dli	$t2, 0x0123456789abcdef
		dli	$t3, 0x0123456789abcdef

		dli	$a0, 0x0123456789abcdef
		dli	$a1, 0x0123456789abcdef
		dli	$a2, 0x0123456789abcdef
		dli	$a3, 0x0123456789abcdef
		dli	$a4, 0x0123456789abcdef
		dli	$a5, 0x0123456789abcdef
		dli	$a6, 0x0123456789abcdef
		dli	$a7, 0x0123456789abcdef

loop:
		sd	$s0, 0($t0)
		sd	$s1, 8($t0)
		sd	$s2, 16($t0)
		sd	$s3, 24($t0)
		sd	$s4, 32($t0)
		sd	$s5, 40($t0)
		sd	$s6, 48($t0)
		sd	$s7, 56($t0)

		sd	$t0, 64($t0)
		sd	$t1, 72($t0)
		sd	$t2, 80($t0)
		sd	$t3, 88($t0)

		sd	$a0, 96($t0)
		sd	$a1, 104($t0)
		sd	$a2, 112($t0)
		sd	$a3, 120($t0)
		sd	$a4, 128($t0)
		sd	$a5, 136($t0)
		sd	$a6, 144($t0)
		sd	$a7, 152($t0)

		ld	$a0, 0($t0)
		ld	$a1, 8($t0)
		ld	$a2, 16($t0)
		ld	$a3, 24($t0)
		ld	$a4, 32($t0)
		ld	$a5, 40($t0)
		ld	$a6, 48($t0)
		ld	$a7, 56($t0)

		ld	$t0, 64($t0)
		ld	$t1, 72($t0)
		ld	$t2, 80($t0)
		ld	$t3, 88($t0)

		ld	$a0, 96($t0)
		ld	$a1, 104($t0)
		ld	$a2, 112($t0)
		ld	$a3, 120($t0)
		ld	$a4, 128($t0)
		ld	$a5, 136($t0)
		ld	$a6, 144($t0)
		ld	$a7, 152($t0)

		# Loop until zero
		daddiu	$k0, $k0, -1
		bne	$k0, $zero, loop
		nop			# branch-delay slot

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

		.data
dword:		.dword	0x0000000000000000	# 0
		.dword	0x0000000000000000	# 8
		.dword	0x0000000000000000	# 16
		.dword	0x0000000000000000	# 24
		.dword	0x0000000000000000	# 32
		.dword	0x0000000000000000	# 40
		.dword	0x0000000000000000	# 48
		.dword	0x0000000000000000	# 56
		.dword	0x0000000000000000	# 64
		.dword	0x0000000000000000	# 72
		.dword	0x0000000000000000	# 80
		.dword	0x0000000000000000	# 88
		.dword	0x0000000000000000	# 96
		.dword	0x0000000000000000	# 104
		.dword	0x0000000000000000	# 112
		.dword	0x0000000000000000	# 120
		.dword	0x0000000000000000	# 128
		.dword	0x0000000000000000	# 136
		.dword	0x0000000000000000	# 144
		.dword	0x0000000000000000	# 152
