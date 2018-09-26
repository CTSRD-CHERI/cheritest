#-
# Copyright (c) 2017 Michael Roe
# Copyright (c) 2018 Alex Richardson
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
# Test that CClearReg no longer raises an exception for c27-c31 due to not having Access_System_Registers permission.
#

sandbox:
		cclearhi 0x18ff	# This used to raise a C2E exception but should no longer!

		cjr     $c9
		nop			# branch delay slot

BEGIN_TEST
		#
		# Set up exception handler
		#

		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		# $a2 will be set to 1 if the exception handler is called
		dli	$a2, 0

		cgetdefault $c1
		dli	$t0, 0x1234
		csetoffset $c1, $c1, $t0
		cmove	$c16, $c1
		cmove	$c17, $c1
		cmove	$c18, $c1
		cmove	$c19, $c1
		cmove	$c20, $c1
		cmove	$c21, $c1
		cmove	$c22, $c1
		cmove	$c23, $c1
		cmove	$c24, $c1
		cmove	$c25, $c1
		cmove	$c26, $c1

		# Run sandbox with restricted permissions
		dli     $t0, 0x1ff
		cgetdefault $c2
		candperm $c2, $c2, $t0
		dla     $t0, sandbox
		csetoffset $c2, $c2, $t0
		cjalr   $c2, $c9
		nop			# Branch delay slot

		cmove	$c16, $c16
		cmove	$c17, $c17
		cmove	$c18, $c18
		cmove	$c19, $c19
		cmove	$c20, $c20
		cmove	$c21, $c21
		cmove	$c22, $c22
		cmove	$c23, $c23
		cmove	$c24, $c24
		cmove	$c25, $c25
		cmove	$c26, $c26
		cmove	$c27, $c27
		cmove	$c28, $c28
		cmove	$c29, $c29
		cmove	$c30, $c30
		cmove	$c31, $c31
		
		dli	$t0, 0x1234
		cgetoffset $a0, $c16
		bne	$a0, $t0, fail
		nop
		cgetoffset $a0, $c17
		bne	$a0, $t0, fail
		nop
		cgetoffset $a0, $c18
		bne	$a0, $t0, fail
		nop
		cgetoffset $a0, $c19
		bne	$a0, $t0, fail
		nop
		cgetoffset $a0, $c20
		bne	$a0, $t0, fail
		nop
		cgetoffset $a0, $c21
		bne	$a0, $t0, fail
		nop
		cgetoffset $a0, $c22
		bne	$a0, $t0, fail
		nop
		cgetoffset $a0, $c23

fail:

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

		.data

		.align 5
cap1:		.dword	0x0123456789abcdef	# uperms/reserved
		.dword	0x0123456789abcdef	# otype/eaddr
		.dword	0x0123456789abcdef	# base
		.dword	0x0123456789abcdef	# length

		.align	3
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef

