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

BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER
.set at
 		dmtc0	$zero, $5		# Page mask = 0 (4K pages)
		dmtc0	$zero, $0		# TLB index
		dmtc0	$zero, $10		# TLB entryHi

		dla	$a2, cap
		andi	$a2, 0x1fff

		dla	$a1, testcode		# Load address of testcode
		and	$a0, $a1, 0xffffffe000	# Get physical page (PFN) of testcode (40 bits less 13 low order bits)
		dsrl	$a0, $a0, 6		# Put PFN in correct position for EntryLow
		ori	$a0, $a0, 0x1f		# Set global, valid and dirty bits, cached noncoherent

		dli	$t0, 0x1		# Set CLG == 1, which mismatches EntryHi
		dsll	$t0, $t0, 61
		or	$a0, $a0, $t0

		dmtc0	$a0, $2			# TLB EntryLow0
		daddu 	$a0, $a0, 0x40		# Add one to PFN for EntryLow1
		dmtc0	$a0, $3			# TLB EntryLow1
		tlbwi				# Write Indexed TLB Entry

		dli	$a5, 0			# Initialise test flags
		li	$a6, 1
		li	$a0, 0

		and	$k0, $a1, 0xfff		# Get offset of testcode within page.
		dmtc0	$k0, $14		# Put EPC
		dmfc0	$t2, $12		# Read status
		ori	$t2, 0x12		# Set user mode, exl
		and	$t2, 0xffffffffefffffff # Clear cu0 bit
		dmtc0	$t2, $12		# Write status
		DO_ERET				# Jump to test code
		nop
		nop

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
