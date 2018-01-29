#-
# Copyright (c) 2013-2015 Robert M. Norton
# Copyright (c) 2015 Jonathan Woodruff
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

# Macro for declaring an exported function. Just saves some typing.
.macro global_func name
        .ent \name
        .global \name
\name :
.endm

# Decrement stack pointer by 32 and save stack and
# frame pointer.
.macro prelude
	daddu	$sp, $sp, -32
	sd	$ra, 24($sp)
	sd	$fp, 16($sp)
	daddu	$fp, $sp, 32
.endm

.macro epilogue
        ld      $ra, 24($sp)
        ld      $fp, 16($sp)
        daddu   $sp, 32
.endm

.macro mips_function_entry extra_stack_space=0
	daddiu	$sp, $sp, -(\extra_stack_space + 16)
	sd	$ra, (\extra_stack_space + 8)($sp)
	sd	$fp, (\extra_stack_space)($sp)
	daddiu	$fp, $sp, (\extra_stack_space + 16)
.endm

.macro mips_function_return extra_stack_space=0
	ld      $ra, (\extra_stack_space + 8)($sp)
	ld      $fp, (\extra_stack_space)($sp)
	jr $ra
	daddiu	$fp, $sp, (\extra_stack_space + 16)
.endm

        
# The maximum number of hw threads (threads*cores) we expect for
# any configuration. This is so that we can allocate a conservative
# amount of space for static per thread structures. May need to
# increase in future.
max_thread_count = 32

# Create the data structure used for thread barriers.
# Should be placed in .data section.
# No particular alignment is required.
.macro mkBarrier
        .rept max_thread_count
        .byte 0
        .endr
.endm

.macro cincbase dest, source, offset
        #cgetoffset $t9, \source
        cgetlen    $at, \source
        dsubu      $at, $at, \offset
        csetoffset \dest, \source, \offset
        csetbounds \dest, \dest, $at
        #csetoffset \dest, \dest, $t9
.endm

.macro csetlen dest, source, offset
        #cgetoffset $at, \source
        #csetoffset \dest, \source, $0
        csetbounds \dest, \source, \offset
        #csetoffset \dest, \dest, $at
.endm


.macro jump_to_usermode function
		# To test user code we must set up a TLB entry.
		dmtc0	$zero, $5		# Write 0 to page mask i.e. 4k pages
		dmtc0	$zero, $0		# TLB index
		dmtc0	$zero, $10		# TLB entryHi

		dla	$a0, \function		# Load address of testcode
		and	$a2, $a0, 0xffffffe000	# Get physical page (PFN) of testcode (40 bits less 13 low order bits)
		dsrl	$a3, $a2, 6		# Put PFN in correct position for EntryLow
		or	$a3, 0x13   		# Set valid and global bits, uncached
		dmtc0	$a3, $2			# TLB EntryLow0
		daddu	$a4, $a3, 0x40		# Add one to PFN for EntryLow1
		dmtc0	$a4, $3			# TLB EntryLow1
		tlbwi				# Write Indexed TLB Entry

		dli	$a5, 0			# Initialise test flag

		and	$k0, $a0, 0xfff		# Get offset of testcode within page.
		dmtc0	$k0, $14		# Put EPC
		dmfc0	$t2, $12		# Read status
		ori	$t2, 0x12		# Set user mode, exl
		and	$t2, 0xffffffffefffffff	# Clear cu0 bit
		dmtc0	$t2, $12		# Write status
		nop
		nop
		eret				# Jump to test code
		nop
		nop
.endm

.macro branch_if_is_qemu target_label, tmpreg
	# Check for QEMU: https://github.com/CTSRD-CHERI/qemu/issues/56
	mfc0 \tmpreg, $15		# PrId
	andi \tmpreg, \tmpreg, 0xffff
	# QEMU ID from https://github.com/CTSRD-CHERI/qemu/commit/12b39eaa9a3c17c7b0438b1536d8b6b9849cc1fc
	# only check the lower 16 bits to avoid using another register
	xor \tmpreg, 0x0401
	beqz \tmpreg, \target_label
	nop
.endm
