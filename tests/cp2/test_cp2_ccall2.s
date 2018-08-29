#-
# Copyright (c) 2012 Michael Roe
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
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test ccall followed by creturn
#

sandbox:
		csetdefault $c26
		dli	$a2, 42
		csd	$a2, $zero, 0($c26)
		creturn
		nop	# branch delay slot

BEGIN_TEST
		# load a full permissions cap into $kdc
		cgetdefault	$c1
		csetkdc	$c1
		#
		# Set up exception handler
		#

		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		#
		# Set up trap handler for CCall/CReturn
		#

		dli	$a0, 0xffffffff80000280
		dla	$a1, bev0_ccall_handler_stub
		dli	$a2, 9 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal	memcpy_nocap
		nop			# branch-delay slot

		#
		# Create a capability for the trusted system stack
		#

		cgetdefault $c1
		dla     $t0, trusted_system_stack
		csetoffset $c1, $c1, $t0
		dli     $t0, 96
		csetbounds $c1, $c1, $t0
		dla     $t0, tsscap
		csc     $c1, $t0, 0($ddc)

		#
		# Initialize the pointer into the trusted system stack
		#

		dla     $t0, tssptr
		dli     $t1, 0
		csd     $t1, $t0, 0($ddc)

		#
		# Remove the permission to access reserved registers from
		# PCC. (CCall should work even if the caller does not have
		# permission to access reserved registers).
		#

		cgetpcc $c1
		dli	$t0, 0x1ff
		candperm $c1, $c1, $t0
		dla	$t0, L1
		csetoffset $c1, $c1, $t0
		cjr	$c1
		nop		# branch delay slot
L1:
		#
		# Make $c4 a template capability for user-defined type
		# number 0x1234.
		#

		dli	$t0, 0x1234
		cgetdefault $c4
		csetoffset $c4, $c4, $t0

		#
		# Make $c3 a data capability for the array at address data
		#

		dla        $t0, data
		cgetdefault $c3
		cincoffset $c3, $c3, $t0
		dli        $t0, 0x1000
		csetbounds $c3, $c3, $t0
		# Permissions Non_Ephemeral, Permit_Load, Permit_Store,
		# Permit_Store.
		# NB: Permit_Execute must not be included in the set of
		# permissions used here.
		dli      $t0, 0xd
		candperm $c3, $c3, $t0

		#
		# Seal data capability $c3 to the offset of $c4, and store
		# result in $c2.
		#

		cseal	 $c2, $c3, $c4

		#
		# Make $c1 a code capability for sandbox
		# $c1 already has restricted permissions so the sandboxed
		# code can't escape the sandbox using reserved registers.
		#

		dla	$t0, sandbox
		csetoffset $c1, $c1, $t0
		cseal	$c1, $c1, $c4

		#
		# Move $ddc into IDC ($c26) so that it will be saved onto
		# the trusted system stack by ccall
		#

		cgetdefault $c26

		#
		# Clear $ddc so that the sandbox doesn't have access to it
		#

		cgetnull $c3
		csetdefault $c3

		#
		# Invoke the sandbox
		#

		ccall   $c1, $c2, 0
		nop			# branch delay slot

		#
		# Restore $ddc from the IDC ($c26) that has been popped off
		# the trusted system stack by creturn
		#

		csetdefault $c26

END_TEST

		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		cgetcause $a3
		dmfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14
		nop
		nop
		nop
		nop
		eret
		.end bev0_handler

		.ent bev0_ccall_handler
bev0_ccall_handler:
		cgetcause $k0
		srl	$k0, $k0, 8
		addi	$k0, $k0, -5
		beq	$k0, $zero, do_ccall
		addi	$k0, $k0, -1
		beq	$k0, $zero, do_creturn

		#
		# The opcode wasn't recognized
		#

		dmfc0   $k0, $14
		daddiu  $k0, $k0, 4 # Bump EPC forward one instruction
		dmtc0   $k0, $14
		nop
		nop
		nop
		nop
		eret

do_ccall:
		#
		# Load a capability for the trusted system stack into
		# kernel reserved capability register 2 ($c28)
		#
		cgetkdc	$c27
		dla     $k0, tsscap
		clc     $c28, $k0, 0($c27)

		#
		# Make $k0 the current offset into the trusted system stack
		#

		dla     $k0, tssptr
		cld     $k0, $k0, 0($c27)

		#
		# Push the IDC on to the trusted system stack
		#

		csc	$c26, $k0, 0($c28)


		# We can now use $idc as a temp register

		#
		# Bump the EPCC.offset (user's PC) by 1 instruction (4 bytes)
		# XXXAR: ccall has a branch delay slot so it's actually 8
		cgetepcc	$c26
		cincoffsetimm	$c26, $c26, 8
		csetepcc	$c26
		#
		# Push EPCC (the user's PCC) on to the trusted system stack
		#
		csc	$c26, $k0, 32($c28)

		#
		# Check that $c1 and $c2 are valid capabilities (tag set)
		#

		cgettag $k1, $c1
		beq	$k1, $zero, ccall_fails

		cgettag	$k1, $c2
		beq	$k1, $zero, ccall_fails

		#
		# Check that $c1 and $c2 are sealed
		#

		cgetsealed $k1, $c1
		beqz	$k1, ccall_fails

		cgetsealed $k1, $c2
		beqz	$k1, ccall_fails

		#
		# Set the offset of the Kernel Data Capability ($c27) to
		# the type of the code capability the user is trying to
		# invoke. KDC has access to everything, so is permitted to
		# do this. XXX: should we use a different reserved register
		# for this?
		#

		cgettype $k1, $c1
		csetoffset $c27, $c27, $k1

		#
		# Check that the data capability passed to the kernel by the
		# user has the same otype as the code capability. It's a
		# security error if they don't match.
		#

		cgettype $t0, $c2	# XXX: corrupts $t0
		
		bne	$t0, $k1, ccall_fails

		#
		# Unseal the code capability into EPCC (which will become
		# the user's PCC after eret)
		#
		# XXX: We ought to have done more checks that $c1 is valid.
		# The user can make the kernel die horribly by passing a
		# bad $c1.
		#

		cunseal $c26, $c1, $c27
		csetepcc $c26

		#
		# Unseal the data capability into IDC ($c26)
		#

		cunseal $c26, $c2, $c27

		#
		# Restore the offset on KDC
		#

		csetoffset $c27, $c27, $zero

		#
		# Move $c1.offset into EPC, so that when we return 
		# PC will be set to the entry point of the invoked sandbox
		#

		cgetoffset $k1, $c1
		dmtc0   $k1, $14
		nop
		nop
		nop
		nop
		eret

do_creturn:
		#
		# Load a capability for the trusted system stack into
		# kernel reserved capability register 2 ($c28)
		#
		cgetkdc	$c27	# Get capability for the kernel data segment

		dla     $k0, tsscap
		clc     $c28, $k0, 0($c27)

		#
		# Make $k0 the current offset into the trusted system stack.
		#

		dla     $k0, tssptr
		cld     $k0, $k0, 0($c27)

		#
		# Pop the EPCC off the trusted system stack, so it will
		# restored to the user's PCC when this exception handler
		# returns to user space.
		# XXXAR: Use $c26 as a tempreg since it will be loaded next

		clc	$c26, $k0, 32($c28)
		csetepcc	$c26
		#
		# Set the return address (EPC) to the offset in the EPCC
		# that was restored from the trusted system stack.
		#
		cgetoffset $k1, $c26  # Don't clobber k0, it is used later!
		dmtc0   $k1, $14

		#
		# Pop the IDC ($c26) off the trusted system stack
		#

		clc	$c26, $k0, 0($c28)

		nop
		nop
		nop
		nop
		eret
		nop

		#
		# Die horribly if there's a security error. XXX: This ought
		# to do more to return cleanly to user space.
		#
ccall_fails:
		eret
		nop

		.end bev0_ccall_handler

		.ent bev0_ccall_handler_stub
bev0_ccall_handler_stub:
		dla     $k0, bev0_ccall_handler
		jr      $k0
		nop
		.end bev0_ccall_handler_stub

		.data
		.align 3
tssptr:
		.dword 0

		.align 5
tsscap:
		.dword 0
		.dword 0
		.dword 0
		.dword 0

		.align 5
trusted_system_stack:
		.dword 0
		.dword 0
		.dword 0
		.dword 0
		.dword 0
		.dword 0
		.dword 0
		.dword 0
		.dword 0
		.dword 0
		.dword 0
		.dword 0

		.align 12
data:		.dword	0xfedcba9876543210
