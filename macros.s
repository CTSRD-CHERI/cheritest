#-
# Copyright (c) 2013-2015 Robert M. Norton
# Copyright (c) 2015 Jonathan Woodruff
# Copyright (c) 2017-2018 Alex Richardson
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

.macro set_mips_bev0_handler handler
	jal	bev_clear
	nop
	dla	$a0, \handler
	jal	bev0_handler_install
	nop
.endm


# define a trap handler function that sets the following:
# a1 = Trap count
# a2 = Cause (mfc0 $a2, $13)
# a3 = capcause (cgetcause $a3)
# a4 = BadVAddr
# a5 = EPC
# On return it just jumps to EPC+4 (i.e. it doesn't handle traps in branches/jumps)
# This handler also allows exiting from usermode by treating sycall as a request to exit
.macro DEFINE_COUNTING_CHERI_TRAP_HANDLER name=counting_trap_handler, global_range_cap_reg=c0

.text
.ent \name
\name:
	# increment trap_count and keep result in a1
.ifdef COUNTING_EXCEPTION_HANDLER_STORE_TO_MEM
	dla	$k0, trap_count
	cld	$a1, $k0, 0($\global_range_cap_reg)
	daddiu	$a1, $a1, 1		# a1 = number of traps so far
	cld	$a1, $k0, 0($\global_range_cap_reg)
.else
	# There also seems to be Kscratch (dmf0 $a1, $31, 2/3) but not sure
	# that that is implemented in BERI
	# TODO: we could also use some other COP0 register instead? E.g. Compare?
	# Use the UserLocal register to store the exception count
	dmfc0	$a1, $4, 2		# a1 = Old exception count
	daddiu	$a1, $a1, 1		# a1 = number of traps so far
	dmtc0	$a1, $4, 2		# save new count
.endif
	dmfc0 	$a2, $13		# a2 = Cause
	cgetcause $a3			# a3 = CapCause
	dmfc0	$a4, $8			# a4 = BadVaddr

	# Check if this is a syscall and exit if it is
	li	$k0, (8 << 2)		# Syscall is cause 8
	andi	$k1, $a2, (0x1f << 2)	# Extract the cause bits
	bne $k0, $k1, .Lnot_syscall
	nop
.Lsyscall:
	# For now just exit the test on any syscall trap
	# TODO: should we check for code == 42?
	# dmfc0 	$k1, $8, 1	# Get BadInstr
	j finish
	nop
.Lnot_syscall:
	dmfc0	$a5, $14		# a5 = EPC
	daddiu	$k0, $a5, 4		# EPC += 4 to bump PC forward on ERET
	dmtc0	$k0, $14
	ssnop
	ssnop
	ssnop
	ssnop
	eret
.end \name

.ifdef COUNTING_EXCEPTION_HANDLER_STORE_TO_MEM
.data
trap_count:
		.8byte 0
.size trap_count, 8
.text
.endif

.endm


.macro clear_counting_exception_handler_regs
	dli $a1, 0
	dli $a2, 0
	dli $a3, 0
	dli $a4, 0
	dli $a5, 0
.endm

# Store CP0 Cause and capcause and the exception count as an integer value in
# capreg \capreg.
# Bits 0-7 are capcause.reg, 8-15 are capcause.cause
# Bits 16-31 are the low 16 bits of CP0_Cause (i.e. the cause is bits 18-22)
# Bits 32-63 are the exception count
# This assumes Exception count is in a1, CPO_Cause is in a2 and Capcause in a3
# See DEFINE_COUNTING_CHERI_TRAP_HANDLER
.macro save_counting_exception_handler_cause capreg
	# Clear the high 48 bits of $a2 (CPO_Cause) and shift by 16
	andi	$a2, $a2, 0xffff
	dsll	$a2, 16
	# Ensure the high bits of capcause are empty
	andi	$a3, $a3, 0xffff
	# Shift exception count to the high 32 bits
	dsll	$a1, $a1, 32
	# combine all the values and store in capreg offset field
	or	$a3, $a3, $a1
	or	$a3, $a3, $a2
	CFromInt	\capreg, $a3
.endm

# Invokes the special syscall trap that will instruct the
# DEFINE_COUNTING_CHERI_TRAP_HANDLER to jump to finish instred of returning
# to EPC + 4
.macro EXIT_TEST_WITH_COUNTING_CHERI_TRAP_HANDLER
	syscall 42
	nop
.endm


# Define the test function. Optional argument 1 can be used to declare
# extra stack space used by the function.
.macro BEGIN_TEST extra_stack_space=0
	.set mips64
	.set noreorder
	.set nobopt
	.set noat
	.text
	.global test
	.ent test
	test:
		mips_function_entry \extra_stack_space
.endm

# End of the test function. Optional argument 1 can be used to declare
# extra stack space used by the function (must match BEGIN_TEST value).
.macro END_TEST extra_stack_space=0
	mips_function_return \extra_stack_space
	.end test
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


.set __CHERI_CAP_PERMISSION_GLOBAL__, 1
.set __CHERI_CAP_PERMISSION_PERMIT_EXECUTE__, 2
.set __CHERI_CAP_PERMISSION_PERMIT_LOAD_CAPABILITY__, 16
.set __CHERI_CAP_PERMISSION_PERMIT_LOAD__, 4
.set __CHERI_CAP_PERMISSION_PERMIT_SEAL__, 128
.set __CHERI_CAP_PERMISSION_PERMIT_STORE_CAPABILITY__, 32
.set __CHERI_CAP_PERMISSION_PERMIT_STORE_LOCAL__, 64
.set __CHERI_CAP_PERMISSION_PERMIT_STORE__, 8
