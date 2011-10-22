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
# Set each CP2 register to use an easily recognised otype, in order to
# confirm that the assembler, simulator, and test suite (roughly) agree.  This
# test depends on at least csetotype and dli working.  $c2_pcc is left
# unmodified form boot, so should be 0.
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

		dli		$t0, 1
		csettype	$c0, $c0, $t0
		dli		$t0, 2
		csettype	$c1, $c1, $t0
		dli		$t0, 3
		csettype	$c2, $c2, $t0
		dli		$t0, 4
		csettype	$c3, $c3, $t0
		dli		$t0, 5
		csettype	$c4, $c4, $t0
		dli		$t0, 6
		csettype	$c5, $c5, $t0
		dli		$t0, 7
		csettype	$c6, $c6, $t0
		dli		$t0, 8
		csettype	$c7, $c7, $t0
		dli		$t0, 9
		csettype	$c8, $c8, $t0
		dli		$t0, 10
		csettype	$c9, $c9, $t0
		dli		$t0, 11
		csettype	$c10, $c10, $t0
		dli		$t0, 12
		csettype	$c11, $c11, $t0
		dli		$t0, 13
		csettype	$c12, $c12, $t0
		dli		$t0, 14
		csettype	$c13, $c13, $t0
		dli		$t0, 15
		csettype	$c14, $c14, $t0
		dli		$t0, 16
		csettype	$c15, $c15, $t0
		dli		$t0, 17
		csettype	$c16, $c16, $t0
		dli		$t0, 18
		csettype	$c17, $c17, $t0
		dli		$t0, 19
		csettype	$c18, $c18, $t0
		dli		$t0, 20
		csettype	$c19, $c19, $t0
		dli		$t0, 21
		csettype	$c20, $c20, $t0
		dli		$t0, 22
		csettype	$c21, $c21, $t0
		dli		$t0, 23
		csettype	$c22, $c22, $t0
		dli		$t0, 24
		csettype	$c23, $c23, $t0
		dli		$t0, 25
		csettype	$c24, $c24, $t0
		dli		$t0, 26
		csettype	$c25, $c25, $t0
		dli		$t0, 27
		csettype	$c26, $c26, $t0
		dli		$t0, 28
		csettype	$c27, $c27, $t0
		dli		$t0, 29
		csettype	$c28, $c28, $t0
		dli		$t0, 30
		csettype	$c29, $c29, $t0
		dli		$t0, 31
		csettype	$c30, $c30, $t0
		dli		$t0, 32
		csettype	$c31, $c31, $t0

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
