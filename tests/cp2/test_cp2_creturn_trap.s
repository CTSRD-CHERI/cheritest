#-
# Copyright (c) 2013 Michael Roe
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
# Test CReturn
#

sandbox:

		# $a2 will be set to 1 if the normal trap handler is called,
		# 2 if the ccall/creturn trap handler is called.
		dli	$a2, 0

		creturn
		nop 		# branch delay slot
		j	L1
		nop

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
		dla	$t0, trusted_system_stack
		csetoffset $c1, $c1, $t0
		dli     $t0, 96
		csetbounds $c1, $c1, $t0
		dla	$t0, tsscap
		csc     $c1, $t0, 0($ddc)

		#
		# Initialize the pointer into the trusted system stack
		#

		dla	$t0, tssptr
		dli	$t1, 0
		csd 	$t1, $t0, 0($ddc)

		#
		# Fake the effect of having done a CCall without using
		# the CCall instruction
		#

		dla	$t1, L1
		csd     $t1, $zero, 0($c1)
		cgetdefault $c2
		csc     $c2, $zero, 32($c1)
		csc	$c2, $zero, 64($c1)

		#
		# Discard the permissions to access the reserved registersm
		#

		dli     $t0, 0x1ff
		cgetdefault $c1
		candperm $c1, $c1, $t0

		#
		# Run 'sandbox' with restricted permissions
		#

		dla     $t0, sandbox
		csetoffset $c1, $c1, $t0
		cjr     $c1
		nop	# branch delay slot

L1:

		# The creturn should have restored all privileges to $pcc.
		# Check that it has.
		cgetpcc $c1
		# FIXME: new assembler syntax
		cgetperm $a6, $c1
		
		
END_TEST

		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		cgetcause $a3
		dmfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14
		DO_ERET
		.end bev0_handler

		.ent bev0_ccall_handler
bev0_ccall_handler:
		li      $a2, 2
		cgetcause $a3
		# When the exception happened, $kcc should have been copied
		# to $pcc.
		cgetpcc $c28
		cgetperm $a4, $c28

		#
		# Load a capability for the trusted system stack into
		# kernel reserved capability register 2 ($c28)
		#

		cgetkdc	$c27	# Get capability for the kernel data segment

		dla     $k0, tsscap
		clc 	$c28, $k0, 0($c27)

		#
		# Make $k0 the current offset into the trusted system stack.
		#

		dla	$k0, tssptr
		cld 	$k0, $k0, 0($c27)

		#
		# Pop the EPCC off the trusted system stack, so it will
		# restored to the user's PCC when this exception handler
		# returns to user space.
		#

		clc	$c26, $k0, 32($c28)
		csetepcc	$c26

		#
		# Pop the IDC ($c26) off the trusted system stack.
		#

		clc     $c26, $k0, 64($c28)

		#
		# Pop the return address off the trusted system stack into
		# EPC, so it will be returned to when this exception handler
		# returns to user space.
		#

		cld 	$k0, $k0, 0($c28)
		dmtc0	$k0, $14

		DO_ERET
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
