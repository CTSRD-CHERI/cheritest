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


# We are running baremetal so the registers 27-31 are not reserved by the kernel.
.set cheri_sysregs_accessible

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
.set push
.set noreorder
.set nobopt
	daddiu	$sp, $sp, -(\extra_stack_space + 16)
	sd	$ra, (\extra_stack_space + 8)($sp)
	sd	$fp, (\extra_stack_space)($sp)
	daddiu	$fp, $sp, (\extra_stack_space + 16)
.set pop
.endm

.macro mips_function_return extra_stack_space=0
.set push
.set noreorder
.set nobopt
	ld	$ra, (\extra_stack_space + 8)($sp)
	ld	$fp, (\extra_stack_space)($sp)
	jr	$ra
	daddiu	$sp, $sp, (\extra_stack_space + 16)	# Branch delay slot
.set pop
.endm

.macro set_mips_common_bev0_handler handler
	jal	bev_clear
	nop
	dla	$a0, \handler
	dla	$a1, end_of_\handler
	jal	bev0_set_common_handler_raw
	nop
.endm


# Use the UserLocal register to store the exception count
# TODO: we could also use some other COP0 register instead? E.g. Compare?
# There also seems to be Kscratch (dmf0 $a1, $31, 2/3) but not sure
# that that is implemented in BERI
.macro __get_counting_trap_handler_count dest
.ifndef COUNTING_TRAP_HANDLER_STORE_TO_MEM
	dmfc0	\dest, $4, 2
.else
	# In case we can't use the UserLocal register store to memory instead
	dla $k0, trap_count
	ld \dest, 0($k0)
.endif
.endm

.macro __set_counting_trap_handler_count src
.ifndef COUNTING_TRAP_HANDLER_STORE_TO_MEM
	dmtc0	\src, $4, 2
.else
	# In case we can't use the UserLocal register store to memory instead
	dla $k0, trap_count
	sd \src, 0($k0)
.endif
.endm

.macro DO_ERET
	# Ensure there are enough nops before the eret to update CP0 state.
	# XXXRW: How many are actually required here?
	# XXXAR: 4 seems to be enough (?)
	ssnop
	ssnop
	ssnop
	ssnop
	eret
.endm


# Collect information on the last trap and store it as follows:
# arg1: compressed_info_reg (should be set to $k1 so that save_counting_exception_handler_cause)
# is the compressed trap info:
#    Bits 0-7 are capcause.reg, 8-15 are capcause.cause
#    Bits 16-31 are the low 16 bits of CP0_Cause (i.e. the cause is bits 18-22)
#    Bits 32-63 are the exception count
# arg2: tmp_reg (default=$k0)
# arg3: trap_count_reg (default=$v0) will be set to number of traps that have been handled
.macro collect_compressed_trap_info compressed_info_reg=$k1, tmp_reg=$k0, trap_count_reg=$v0
	dmfc0	\tmp_reg, $13		# k0 = Cause
	# Clear the high 32 bits of \tmp_reg (CPO_Cause) into \compressed_info_reg and shift by 16
	dsll	\tmp_reg, \tmp_reg, 32
	dsrl	\compressed_info_reg, \tmp_reg, 16			# Bits 16-47 set
	# Move the bdelay

	# Check if CP2 is enabled
	mfc0	\tmp_reg, $12	# Get status
	dli	\trap_count_reg, (1 << 30)	# CP2 enabled bit
	and	\tmp_reg, \tmp_reg, \trap_count_reg	# check if zero
	beqz	\tmp_reg, .Lcp2_disabled_skip_capcause
	nop
.Lset_capcause:
	# Set bits 0-16 of k1 to CapCause
	cgetcause \trap_count_reg
	andi	\trap_count_reg, \trap_count_reg, 0xffff	# Ensure the high bits of capcause are empty (they should be anyway)
	or	\compressed_info_reg, \compressed_info_reg, \trap_count_reg		# Add capcause in bits 0-16
.Lcp2_disabled_skip_capcause:
	# TODO: (save STATUS)?
	# dmfc0   $v1, $12			# a6 = status

	# increment trap_count and keep result in v0
	__get_counting_trap_handler_count \trap_count_reg	# get old exception count
	daddiu \trap_count_reg, \trap_count_reg, 1		# v0 = new exception count
	__set_counting_trap_handler_count \trap_count_reg	# save exception count value

	# Shift exception count to the high 16 bits
	# Strictly speaking might modify \trap_count_reg but more than 2^16 exceptions should
	# be impossible in any of the tests
	dsll	\trap_count_reg, \trap_count_reg, 48
	or	\compressed_info_reg, \compressed_info_reg, \trap_count_reg		# Add count in bits 31-63
	dsrl	\trap_count_reg, \trap_count_reg, 48		# restore expection count \trap_count_reg
.endm

# define a trap handler function that sets the following:
# v0 = number of traps that have been handled
# k0 = BadVaddr
# k1 = compressed trap info:
#    Bits 0-7 are capcause.reg, 8-15 are capcause.cause
#    Bits 16-31 are the low 16 bits of CP0_Cause (i.e. the cause is bits 18-22)
#    Bits 32-63 are the exception count
# This trap handler correctly handles traps in branches/jumps and jumps to either +4/+8
# This handler also allows exiting from usermode by treating sycall as a request to exit
.macro DEFINE_COUNTING_CHERI_TRAP_HANDLER name=counting_trap_handler, trap_count_reg=$v0
.text
.global \name
.ent \name
\name:
	.set push
	.set noat
	ori $0, $0, 0xdead	# turn off QEMU tracing

	# Check if this is a syscall and exit if it is (don't update trap count!)
	dmfc0 	$k0, $13		# k0 = Cause
	andi	$k1, $k0, (0x1f << 2)	# Extract the cause bits
	daddiu	$k1, -(8 << 2)		# Syscall is cause 8
	beqz	$k1, .Lsyscall
	nop
	# Otherwise skip the instruction and return from the handler
.Lnot_syscall:
	# save the trap info in $k1+$v0, using $k0 as the scratch reg
	collect_compressed_trap_info trap_count_reg=\trap_count_reg

	# Check for bdelay flag (bit 47 of compressed trap info:
	dsrl	$k0, $k1, 47
	andi	$k0, $k0, 1
	# incrementing by 4 or 8 needs to be done by branching and duplicating
	# code since we don't have a spare register
	bne	$k0, $zero, .Lskip_branch_and_delay_slot
	nop
.Lskip_one_instr:
	dmfc0	$k0, $14		# load EPC
	daddiu	$k0, $k0, 4		# EPC += 4 to bump PC forward on ERET
	dmtc0	$k0, $14
	b .Ldo_eret
	nop

.Lskip_branch_and_delay_slot:
	dmfc0	$k0, $14		# load EPC
	daddiu	$k0, $k0, 8		# EPC += 8 to bump PC forward on ERET (over the delay slot)
	dmtc0	$k0, $14

.Ldo_eret:
	dmfc0	$k0, $8			# k0 = BadVaddr
	ori $0, $0, 0xbeef	# turn on QEMU tracing again
	DO_ERET
.Lsyscall:
	# For now just exit the test on any syscall trap
	# TODO: should we check for code == 42?
	# dmfc0 	$k1, $8, 1	# Get BadInstr
	# On exit store total exception count in v0
	__get_counting_trap_handler_count $v0	# get exception count in $v0
	ori $0, $0, 0xbeef	# turn on QEMU tracing again
	# This needs to be a jr with the real address since a branch or j will
	# jump to unmapped memory just after the trap handler
	dla	$ra, finish
	jr	$ra
	nop
	.set pop
.end \name
.global end_of_\name
end_of_\name\():
	nop
.ifdef COUNTING_TRAP_HANDLER_STORE_TO_MEM
.data
.balign 8
trap_count:
		.8byte 0
.size trap_count, 8
.text
.endif

.endm


.macro clear_counting_exception_handler_regs
	dli $k0, 0
	dli $k1, 0
.endm

# Store CP0 Cause and capcause and the exception count as an integer value in
# capreg \capreg.
# Bits 0-7 are capcause.reg, 8-15 are capcause.cause
# Bits 16-31 are the low 16 bits of CP0_Cause (i.e. the cause is bits 18-22)
# Bits 32-63 are the exception count
# This assumes the value has been set by the trap handler:
# See DEFINE_COUNTING_CHERI_TRAP_HANDLER
.macro save_counting_exception_handler_cause capreg
	CFromInt	\capreg, $k1	# store result in capreg
.endm

.macro check_instruction_traps compressed_info, insn:vararg
	dli \compressed_info, 0
	clear_counting_exception_handler_regs
	\insn
	move \compressed_info, $k1
	clear_counting_exception_handler_regs
.endm

.macro check_instruction_traps_info_in_creg compressed_info, insn:vararg
	cgetnull \compressed_info
	clear_counting_exception_handler_regs
	\insn
	CFromInt	\compressed_info, $k1
	clear_counting_exception_handler_regs
.endm

# Invokes the special syscall trap that will instruct the
# DEFINE_COUNTING_CHERI_TRAP_HANDLER to jump to finish instred of returning
# to EPC + 4
.macro EXIT_TEST_WITH_COUNTING_CHERI_TRAP_HANDLER
	syscall 42
	nop
.endm


.macro __SET_DEFAULT_TEST_ASM_OPTS
	.set mips64
	.set noreorder
	.set nobopt
.endm

# Define the test function. Optional argument 1 can be used to declare
# extra stack space used by the function.
.macro BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER extra_stack_space=0
	__SET_DEFAULT_TEST_ASM_OPTS
	.text
	.global test
	.ent test
	test:
		mips_function_entry \extra_stack_space
.endm

.macro BEGIN_CUSTOM_TRAP_HANDLER
	.global default_trap_handler
	.ent default_trap_handler
	default_trap_handler:
.endm

.macro END_CUSTOM_TRAP_HANDLER
	.end default_trap_handler
.endm


# End of the test function. Optional argument 1 can be used to declare
# extra stack space used by the function (must match BEGIN_TEST value).
.macro END_TEST extra_stack_space=0
	mips_function_return \extra_stack_space
	.end test
.endm


# Start a test that installs the default counting trap handler
# See DEFINE_COUNTING_CHERI_TRAP_HANDLER for the registers it sets on traps
# Using the macro save_counting_exception_handler_cause can shorten the test even more
#
# Optional argument 1 can be used to declare extra stack space used by the function.
.macro BEGIN_TEST extra_stack_space=0, trap_count_reg=$v0
.text
	__SET_DEFAULT_TEST_ASM_OPTS
	DEFINE_COUNTING_CHERI_TRAP_HANDLER default_trap_handler, trap_count_reg=\trap_count_reg

	BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER \extra_stack_space
		dli $v0, 0	# trap handler sets $v0 to exception count on error
		dli $k1, 0	# trap handler sets $k1 to trap info on error (which will be preserved until exit)

.endm

# Optional argument 1 can be used to declare extra stack space used by the function.
.macro BEGIN_TEST_WITH_OLD_EXCEPTION_HANDLER extra_stack_space=0
.text
	__SET_DEFAULT_TEST_ASM_OPTS
	# Set the old exception_count_handler as the default handler until the
	# tests are updated to check different registers
	BEGIN_CUSTOM_TRAP_HANDLER
		dla $k0, exception_count_handler
		jr $k0
		nop
	END_CUSTOM_TRAP_HANDLER

	BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER \extra_stack_space
.endm

.macro remove_cap_perms capreg, perms, tmpgpr=$at
	dli		\tmpgpr, ~(\perms)
	candperm	\capreg, \capreg, \tmpgpr
.endm

.macro remove_pcc_perms_jump capreg, perms, label, tmpgpr=$at
	.set push
	.set noat
	cgetpcc		\capreg
	remove_cap_perms \capreg, \perms, tmpgpr=\tmpgpr
	dla		\tmpgpr, \label
	csetaddr	\capreg, \capreg, \tmpgpr
	cjr		\capreg
	nop		# branch delay slot
	.set pop
.endm

.macro cap_from_label capreg, label, tmpgpr=$at
	.set push
	.set noat
	cgetpcc		\capreg
	dla		\tmpgpr, \label
	csetoffset	\capreg, \capreg, \tmpgpr
	.set pop
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

.macro CFromInt dest, src
	cgetnull \dest
	cincoffset \dest, \dest, \src
.endm

.macro CFromIntImm dest, value, tmpreg=at
	dli $\tmpreg, \value
	CFromInt \dest, $\tmpreg
.endm


# Workaround for binutils:
.ifdef _GNU_AS_
.macro cgetnull dest
	cfromptr	\dest, $c1, $zero
.endm

.macro cfromddc dest, src
	cfromptr	\dest, $c0, \src
.endm

# compat with LLVM
.set $chwr_ddc, $0
.set $chwr_kr1c, $22
.set $chwr_kr2c, $23
.set $chwr_kcc, $29
.set $chwr_kdc, $30
.set $chwr_epcc, $31
.endif  # _GNU_AS_


# Does a CSetOffset with an immediate value on a special capability register
# E.g. `SetCapHwrOffset ddc, 0x123` or `SetCapHwrOffset epcc, 0x123`
.macro SetCapHwrOffset reg, imm
	CReadHwr	$c1, $chwr_\()\reg
	dli		$at, \imm
	CSetOffset	$c1, $c1, $at
	CWriteHwr	$c1, $chwr_\()\reg
.endm

# Performs a fast (and still vaguely unsafe, but matching Linux and FreeBSD)
# initialization of the TLB.  If this ever proves problematic, we should go
# adopt the full algorithm from the MIPS manual.
#
# All entries installed into ASID 0.
#
# If this platform supports the Extended TLB (configN magic), this does not
# initialize those entries.  (They default disabled, thankfully, so this should
# be fine.)
#
# Clobbers t0, t1, t2
.macro init_tlb
		dmtc0   $zero,  $5      # Page Mask = 0
		dmtc0   $zero,  $2      # EntryLo0; valid bit notably off
		dmtc0   $zero,  $3      # EntryLo1; valid bit notably off

		dmfc0   $t0, $16, 1     # read config1
		dsrl    $t0, $t0, 25    # extract maximum TLB index
		andi    $t0, $t0, 0x3F

		dli     $t1, 0x3fffffff80000000 # MIPS_KSEG0_START, "region" bits clear
1:
		dsll    $t2, $t0, 13    # TLB index -> page offset; two pages (even/odd)
		dadd    $t2, $t1, $t2

		# Nominally there are other fields in EntryHi, but they're all tucked
		# around the VPN2 field, and we just want them to be zero anyway.

		dmtc0   $t2, $10        # EntryHi
		dmtc0   $t0, $0         # Index
		ssnop                   # Take a guess at the hazard required
		ssnop
		ssnop
		ssnop
		tlbwi

		dsub    $t0, $t0, 1     # Next index, unless this was 0
		bgez    $t0, 1b
		nop

		ssnop                   # One more hazard for good measure
		ssnop
		ssnop
		ssnop
.endm

# Installs a TLB entry; clobbers t0; assumes EntryHi and TLB Index valid on
# entry.  Clobbers t0 and t1 (well, for callback's use, but pretend).
#
# The "preproc" argument is a macro of two arguments, both register names:
# the tlb entry itself and a scratch register.  If one tries being very
# fancy and desires to pass state to the callback, it must not be in
# registers clobbered by install_tlb_entry itself.
.macro install_tlb_entry physaddr, preproc=install_tlb_entry_stub
	.set push
	.set at
		dla	$t0, \physaddr		# Load address
		and	$t0, $t0, 0xffffffe000	# Get physical page (PFN: 40 bits less 13 low order bits)
		dsrl	$t0, $t0, 6		# Put PFN in correct position for EntryLow
		ori	$t0, $t0, 0x13		# Set valid and global bits, uncached

		\preproc $t0, $t1

		dmtc0	$t0, $2			# TLB EntryLow0
		daddu	$t0, $t0, 0x40		# Add one to PFN for EntryLow1
		dmtc0	$t0, $3			# TLB EntryLow1
		tlbwi				# Write Indexed TLB Entry
	.set pop
.endm

.macro install_tlb_entry_stub tlbentryreg, tempreg
.endm

# Clobbers $at, $t0, $t1 and $t2
.macro jump_to_usermode function, tlb_preproc=install_tlb_entry_stub
	.set push
	.set at
		# To test user code we must set up a TLB entry.
		dmtc0	$zero, $5		# Write 0 to page mask i.e. 4k pages
		dmtc0	$zero, $0		# TLB index
		dmtc0	$zero, $10		# TLB entryHi

		install_tlb_entry \function, \tlb_preproc

		dla	$t0, \function
		and	$t0, $t0, 0x1fff	# Get offset of function within page.
		dmtc0	$t0, $14		# Put EPC

		dmfc0	$t2, $12		# Read status
		ori	$t2, 0x12		# Set user mode, exl
		and	$t2, 0xffffffffefffffff	# Clear cu0 bit
		dmtc0	$t2, $12		# Write status
		DO_ERET				# Jump to test code
		nop
	.set pop
.endm

.macro branch_if_is_qemu target_label, tmpreg=$at
	.set push
	.set noat
	# Check for QEMU: https://github.com/CTSRD-CHERI/qemu/issues/56
	mfc0 \tmpreg, $15		# PrId
	dsrl \tmpreg, \tmpreg, 8	# PrId >> 8
	andi \tmpreg, \tmpreg, 0xffff
	# QEMU ID from https://github.com/CTSRD-CHERI/qemu/commit/12b39eaa9a3c17c7b0438b1536d8b6b9849cc1fc
	# 0x0f05XX with the lower 8 bits being the version@
	xor \tmpreg, 0x0f04
	beqz \tmpreg, \target_label
	nop
	.set pop
.endm


# These macros names are so long to match the names used in clang
.set __CHERI_CAP_PERMISSION_GLOBAL__, 1
.set __CHERI_CAP_PERMISSION_PERMIT_EXECUTE__, 2
.set __CHERI_CAP_PERMISSION_PERMIT_LOAD__, 4
.set __CHERI_CAP_PERMISSION_PERMIT_STORE__, 8
.set __CHERI_CAP_PERMISSION_PERMIT_LOAD_CAPABILITY__, 16
.set __CHERI_CAP_PERMISSION_PERMIT_STORE_CAPABILITY__, 32
.set __CHERI_CAP_PERMISSION_PERMIT_STORE_LOCAL__, 64
.set __CHERI_CAP_PERMISSION_PERMIT_SEAL__, 128
.set __CHERI_CAP_PERMISSION_PERMIT_CCALL__, 256
.set __CHERI_CAP_PERMISSION_PERMIT_UNSEAL__, 512
.set __CHERI_CAP_PERMISSION_ACCESS_SYSTEM_REGISTERS__, 1024
.set __CHERI_CAP_PERMISSION_PERMIT_SET_CID__, 2048

# Add shorter names for use in the tests (matches the CheriBSD names)
.set CHERI_PERM_GLOBAL, 1
.set CHERI_PERM_EXECUTE, 2
.set CHERI_PERM_LOAD, 4
.set CHERI_PERM_STORE, 8
.set CHERI_PERM_LOAD_CAP, 16
.set CHERI_PERM_STORE_CAP, 32
.set CHERI_PERM_STORE_LOCAL_CAP, 64
.set CHERI_PERM_SEAL, 128
.set CHERI_PERM_CCALL, 256
.set CHERI_PERM_UNSEAL, 512
.set CHERI_PERM_SYSTEM_REGS, 1024
.set CHERI_PERM_SET_CID, 2048
