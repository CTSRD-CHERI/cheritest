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
# Set each CP2 register to use a quickly recognised upper address, in order
# to confirm that the assembler, simulator, and test suite (rouchly) agree.
# This test assumes that $c2_kcc is an appropriate origin for the length
# 0xffffffffffffffff, and relies on at least cdecleng and dli working.  The
# order of assignments is slightly subtle: we do c29 last so as not to
# introduce confusion.  A delta of 0 is reserved for $c2_pcc, which we don't
# directly manipulate.
#
# XXXRW: once we support mneumonics such as $c2_kcc, we should test those as
# well.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		dli		$at, 2
		cdecleng	$c0, $c29, $at
		dli		$at, 3
		cdecleng	$c1, $c29, $at
		dli		$at, 4
		cdecleng	$c2, $c29, $at
		dli		$at, 5
		cdecleng	$c3, $c29, $at
		dli		$at, 6
		cdecleng	$c4, $c29, $at
		dli		$at, 7
		cdecleng	$c5, $c29, $at
		dli		$at, 8
		cdecleng	$c6, $c29, $at
		dli		$at, 9
		cdecleng	$c7, $c29, $at
		dli		$at, 10
		cdecleng	$c8, $c29, $at
		dli		$at, 11
		cdecleng	$c9, $c29, $at
		dli		$at, 12
		cdecleng	$c10, $c29, $at
		dli		$at, 13
		cdecleng	$c11, $c29, $at
		dli		$at, 14
		cdecleng	$c12, $c29, $at
		dli		$at, 15
		cdecleng	$c13, $c29, $at
		dli		$at, 16
		cdecleng	$c14, $c29, $at
		dli		$at, 17
		cdecleng	$c15, $c29, $at
		dli		$at, 18
		cdecleng	$c16, $c29, $at
		dli		$at, 19
		cdecleng	$c17, $c29, $at
		dli		$at, 20
		cdecleng	$c18, $c29, $at
		dli		$at, 21
		cdecleng	$c19, $c29, $at
		dli		$at, 22
		cdecleng	$c20, $c29, $at
		dli		$at, 23
		cdecleng	$c21, $c29, $at
		dli		$at, 24
		cdecleng	$c22, $c29, $at
		dli		$at, 25
		cdecleng	$c23, $c29, $at
		dli		$at, 26
		cdecleng	$c24, $c29, $at
		dli		$at, 27
		cdecleng	$c25, $c29, $at
		dli		$at, 28
		cdecleng	$c26, $c29, $at
		dli		$at, 29
		cdecleng	$c27, $c29, $at
		dli		$at, 30
		cdecleng	$c28, $c29, $at
		dli		$at, 31
		cdecleng	$c30, $c29, $at
		dli		$at, 32
		cdecleng	$c31, $c29, $at
		dli		$at, 1
		cdecleng	$c29, $c29, $at
		
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
