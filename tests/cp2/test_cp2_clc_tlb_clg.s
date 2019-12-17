#-
# Copyright (c) 2012, 2014 Robert M. Norton
# Copyright (c) 2014 Michael Roe
# Copyright (c) 2019 Alex Richardson
# Copyright (c) 2019 Nathaniel Filardo
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory (Department of Computer Science and
# Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
# DARPA SSITH research programme.
#
# @BERI_LICENSE_HEADER_START@
#
# Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  BERI licenses this
# file to you under the BERI Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://www.beri-open-systems.org/legal/license-1-0.txt
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @BERI_LICENSE_HEADER_END@
#

.include "macros.s"

#
# Test that we trap when loading tagged capabilities if the "capability load
# generation" bits mismatch between a TLB entry (lo) and the global bits in
# EntryHi.
#

.macro tlb_preproc_set_bits tlbentryreg, tempreg
	dli \tempreg, 0x1		# Set CLG == 1, which mismatches EntryHi
	dsll \tempreg, \tempreg, 61
	ori \tempreg, 0xc		# Make entry cached and valid
	or \tlbentryreg, \tlbentryreg, \tempreg
.endm

BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER
.set at
		li	$a0, 0

		dla	$a2, cap
		andi	$a2, 0x1fff

		li	$a6, 1

		jump_to_usermode testcode, tlb_preproc_set_bits

the_end:
END_TEST

.balign 8192	# ensure all the userspace testcode is on one page
	nop
testcode:
		nop
		dli	$a5, 1			# Set the test flag

		#
		# Check that non-capability loads and stores work
		#

		ld 	$t0, 0($a2)

		dli	$a5, 2

		dli	$t0, 0xdead
		sd	$t0, 0($a2)

		dli	$a5, 3

		#
		# Store a valid capability to 'cap'
		#

		dli	$t0, 64
		cgetdefault $c1
		cincoffset $c1, $c1, $t0
		csetbounds	$c1, $c1, $t0
		csc 	$c1, $a2, 0($ddc)

		dli	$a5, 4

		#
		# Prepare target registers
		#

		cgetdefault	$c2

		#
		# This should trap
		#

		clc 	$c2, $a2, 0($ddc)

		dli	$a5, 5

		# Return to kernel mode to finish test
		syscall	0
		nop

BEGIN_CUSTOM_TRAP_HANDLER
		# If this is a syscall, bail
		mfc0	$t0, $13
		andi	$t0, $t0, 0x7C
		dli	$t1, 0x20
		bne	$t0, $t1, 1f
		dli	$a5, 6
		j	the_end
1:

		#
		# Check to see if the capability load succeeded
		# exception handler should not be called for clc,
		# but will be called for syscall to end test.
		# increment a0 to count number of exceptions
		collect_compressed_trap_info compressed_info_reg=$s1, trap_count_reg=$a0

		# Set the CLG user bit and go again
		dmfc0	$t0, $10
		dli	$t1, 1
		dsll	$t1, $t1, 59
		or	$t0, $t0, $t1
		dmtc0	$t0, $10

		DO_ERET
		nop

END_CUSTOM_TRAP_HANDLER

		.data
		.align 5
cap:
		.dword 0x0123
		.dword 0x4567
		.dword 0x89ab
		.dword 0xcdef

# At end of test,

#	a0	trap count (exp: 1)
#	a5	test stage (exp: 6)
#
#	s1	compressed trap info
#
#	c1	stored capability
#	c2	loaded capability (exp: == c1)
