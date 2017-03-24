#-
# Copyright (c) 2012, 2017 Michael Roe
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
# Test that PCC is set if an exception occurs while EXL is true (i.e. we're
# already in an exception handler).
#

sandbox:
		#
		# Try to use KR1C ($c27) as a capability, without having
		# the required permission in PCC.
		#
		dli     $a0, 0
		dli     $t0, 0
		clbur   $a0, $t0($c27) # This should raise a C2E exception

		cjr     $c24
		# branch delay slot
		nop

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

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

		#
		# Make $c1 a data capability for the array 'data'
		#

		cgetdefault $c1
		dla     $t0, data
		csetoffset $c1, $c1, $t0
		dli     $t0, 8
                csetbounds $c1, $c1, $t0
		dli     $t0, 0x7
		candperm $c1, $c1, $t0
		
		#
		# Move $c1 into KR1C
		#

		cmove $c27, $c1

		#
		# Set EPC and EPCC; these will not be set if an exception
		# occurs while EXL is true.
		#

		dla	$t0, catch
		dmtc0	$t0, $14	# EPC
		cgetdefault $c1
		csetoffset $c1, $c1, $t0
		cmove	$c31, $c1	# Should use csetepcc

		#
		# Set EXL
		#

		mfc0	$t0, $12	# Status
		ori	$t0, $t0, 0x2
		mtc0	$t0, $12	# Status
		nop
		nop
		nop
		nop
		nop

		# Run sandbox with restricted permissions
		dli     $t0, 0x1ff
		candperm $c2, $c0, $t0
		dla     $t0, sandbox
		csetoffset $c2, $c2, $t0
		cjalr   $c2, $c24
		nop			# Branch delay slot

catch:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# Branch delay slot
		.end	test

		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		mfc0	$a3, $12		# Status
		andi	$a3, $a3, 0x7
		cgetpcc $c1
		cgetperm $a1, $c1
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
