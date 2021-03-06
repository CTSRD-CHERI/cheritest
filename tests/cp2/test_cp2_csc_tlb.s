#-
# Copyright (c) 2012, 2014 Robert M. Norton
# Copyright (c) 2014 Michael Roe
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
# Test that csc does NOT raise an exception if the 'disable capability store'
# bit is set in the TLB entry for the page but the tag bit on data is unset.
#

BEGIN_TEST
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

		dla	$a2, cap
		andi	$a2, 0x1fff

		dla     $a1, testcode		# Load address of testcode
		and     $a0, $a1, 0xffffffe000	# Get physical page (PFN) of testcode (40 bits less 13 low order bits)
		dsrl    $a0, $a0, 6		# Put PFN in correct position for EntryLow
		#
		# Set global, valid and dirty bits, cached noncoherent
		#

		ori     $a0, $a0, 0x1f  	

		#
		# Set the 'disable capability store' bit
		#

		dli	$t0, 0x1
		dsll	$t0, $t0, 63
		or	$a0, $a0, $t0

		dmtc0	$a0, $2			# TLB EntryLow0
		daddu 	$a0, $a0, 0x40		# Add one to PFN for EntryLow1
		dmtc0	$a0, $3			# TLB EntryLow1
		tlbwi				# Write Indexed TLB Entry

		dli	$a5, 0			# Initialise test flag
	
		and     $k0, $a1, 0xfff		# Get offset of testcode within page.
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

.balign 8192  # Note: this test assumes testcode lies on an even page!
.ent testcode
testcode:
		clear_counting_exception_handler_regs
		nop
		# Set the test flags
		li      $a3, 0
		li      $a4, 0
		dli	$a5, 1
		li      $a6, 1
		li      $a7, 0

		#
		# Check that non-capability loads and stores work
		#

		ld 	$t0, 0($a2)

		dli	$a5, 2

		dli	$t0, 0xdead
		sd	$t0, 0($a2)

		dli	$a5, 3

		#
		# Store an invalid capability to 'cap'
		# This should NOT raise an exception.
		#
		dli	$t0, 64
		cgetdefault $c1
		cincoffset $c1, $c1, $t0
		csetbounds	$c1, $c1, $t0
		ccleartag $c1, $c1
		csc 	$c1, $a2, 0($ddc)

		dli	$a5, 4

		#
		# Check to see if the capability store succeeded
		#
		clc      $c2, $a2, 0($ddc)
		cgetbase $a3, $c2
		cgetlen  $a4, $c2
		cgettag  $a6, $c2
	
		#
		# Return to kernel mode and exit the test
		#

		# save the last trap cause (should be zero)
		save_counting_exception_handler_cause $c8

		syscall	0
		nop
.end testcode


		.data
		.align 5
cap:
		.dword 0x0123
		.dword 0x4567
		.dword 0x89ab
		.dword 0xcdef
