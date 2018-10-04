#-
# Copyright (c) 2012 Michael Roe
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
# Test exception priority: C2E/length violation should have higher
# priority than an address error due to unaligned address.
#

sandbox:
		dli     $a0, 0

		dli     $t0, 7
		csetbounds $c3, $c1, $t0
		dli     $t0, 1			# This makes the offset unaligned
		cld     $a0, $t0, 0($c3)	# This should raise a C2E exception
		save_counting_exception_handler_cause $c8

		cjr     $c24
		# branch delay slot
		nop

BEGIN_TEST
		# $v0 will be set to 1 if the exception handler is called
		dli	$v0, 0
		clear_counting_exception_handler_regs

		#
		# Make $c1 a data capability for the array 'data'
		#

		cgetdefault $c1
		dla     $t0, data
		csetoffset $c1, $c1, $t0
		dli     $t0, 9
                csetbounds $c1, $c1, $t0
		dli     $t0, 0x7
		candperm $c1, $c1, $t0
		
		# Run sandbox with restricted permissions
		dli     $t0, 0x1ff
		cgetdefault $c2
		candperm $c2, $c2, $t0
		dla     $t0, sandbox
		csetoffset $c2, $c2, $t0
		cjalr   $c2, $c24
		nop			# Branch delay slot

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

		.data

		.align 5
cap1:		.dword	0x0123456789abcdef	# uperms/reserved
		.dword	0x0123456789abcdef	# otype/eaddr
		.dword	0x0123456789abcdef	# base
		.dword	0x0123456789abcdef	# length

		.align	3
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef

