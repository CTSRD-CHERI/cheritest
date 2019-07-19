#-
# Copyright (c) 2012 Robert M. Norton
# Cipyright (c) 2014 Michael Roe
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
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
# Test that trying to store a capability raises an exception if the
# 'disable capability store' bit is set in the TLB entry for the page.
#

BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER
		#
		# To test user code we must set up a TLB entry.
		#
.set at
		#
		# Write 0 to page mask i.e. 4k pages
		#

		dmtc0	$zero, $5

		dmtc0	$zero, $0		# TLB index
		dmtc0	$zero, $10		# TLB entryHi

		dla	$a1, cap
		andi	$a1, 0x1fff

		dla     $a2, testcode		# Load address of testcode
		and     $a0, $a2, 0xffffffe000	# Get physical page (PFN) of testcode (40 bits less 13 low order bits)
		dsrl    $a0, $a0, 6		# Put PFN in correct position for EntryLow
		#
		# Set global and valid bits (but not dirty), cached noncoherent
		#

		ori     $a0, $a0, 0x1b

		#
		# Set the 'disable capability store' bit
		#

		dli	$t0, 0x1
		dsll	$t0, $t0, 63
		or	$a0, $a0, $t0

		dmtc0	$a0, $2			# TLB EntryLow0
		daddu	$t0, $a0, 0x40		# Add one to PFN for EntryLow1
		dmtc0	$t0, $3			# TLB EntryLow1
		tlbwi				# Write Indexed TLB Entry

		dli	$a5, 0			# Initialise test flag

		and     $k0, $a2, 0xfff		# Get offset of testcode within page.
		dmtc0   $k0, $14		# Put EPC
		dmfc0   $t2, $12                # Read status
		ori     $t2, 0x12               # Set user mode, exl
		and     $t2, 0xffffffffefffffff # Clear cu0 bit
		dmtc0   $t2, $12                # Write status
		DO_ERET                            # Jump to test code
		nop
		nop

the_end:
END_TEST

# a0: TLB entry lo
# a1: address of capability
# a2: initial data load
# a3: trap handler store of cp0 cause for first trap (checked)
# a4: trap handler store of capcause for second trap (checked)
# a5: test stage counter (checked & used by fault handler)
# a6: trap handler store of cp0 cause for second trap (cp2 exception)

# c1: capability being stored
# c2: initial capability load
# c3: trap handler read-back for first trap (checked against c2)
# c4: trap handler read-back for second trap (checked against c2)
# c5: mainline read-back after store (checked equal to c1)

testcode:
		nop
		dli	$a5, 1

		#
		# Check that loads, both data and cap, are permitted
		#

		ld	$a2, 0($a1)
		clc	$c2, $a1, 0($ddc)

		dli	$a5, 2

		#
		# Store a valid capability to 'cap'
		# This should raise two exceptions, in order, then succeed:
		#   - A TLB Modified exception (D bit clear)
		#   - A CP2 MMU store inhibit exception (SC bit set)

		cgetdefault $c1
		dli	$t0, 64
		csetoffset $c1, $c1, $t0
		csetbounds $c1, $c1, $t0
		csc	$c1, $a1, 0($ddc)

		dli	$a5, 5
		clc	$c5, $a1, 0($ddc)

		syscall	0
		nop


BEGIN_CUSTOM_TRAP_HANDLER

		# If this is a syscall, bail out
		mfc0	$t0, $13
		andi	$t0, $t0, 0x7C
		dli	$t1, 0x20
		bne	$t0, $t1, 1f
		nop
		j	the_end

1:
		slti	$t0, $a5, 3
		beq	$t0, $zero, 1f
		addi	$a5, 1

		#
		# First fault should be TLB Modified, a CP0 exception.
		# Read cause and OR in the dirty bit.
		#

		clc	$c3, $a1, 0($ddc)

		mfc0	$a3, $13
		ori     $a0, $a0, 0x4
		dmtc0	$a0, $2
		daddu	$t0, $a0, 0x40
		dmtc0	$t0, $3
		tlbwi

		j	2f
		nop

1:
		#
		# Second fault should be a CP2 MMU store inhibit.
		# Read capcause and clear inhibit.
		#

		clc	$c4, $a1, 0($ddc)

		cgetcause	$a4
		mfc0	$a6, $13

		dli	$t0, 0x1
		dsll	$t0, $t0, 63
		xor	$a0, $a0, $t0
		dmtc0	$a0, $2
		daddu	$t0, $a0, 0x40
		dmtc0	$t0, $3
		tlbwi

2:
		DO_ERET
		nop
		nop

END_CUSTOM_TRAP_HANDLER
		.data
		.align 5
cap:
		.dword 0x0123
		.dword 0x4567
		.dword 0x89ab
		.dword 0xcdef
