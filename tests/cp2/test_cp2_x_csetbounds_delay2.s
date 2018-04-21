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

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"
#
# Test that cause register is set correctly if csetbounds raises an exception
# in a branch delay slot.
#

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

		#
		# Make $c1 a data capability for the array 'data'
		#

		dla     $t0, data
		csetoffset $c1, $c0, $t0
		dli     $t0, 0x1000
		csetbounds $c1, $c1, $t0
		dli     $t0, 0x5
		candperm $c1, $c1, $t0

		#
		# Make $c2 a capability for otype 1
		#

		dli	$t0, 1
		csetoffset $c2, $c0, $t0

		#
		# Seal $c1 with $c2 so that an attempt to CSetBounds $c1 will
		# fail.
		#

		cseal	$c1, $c1, $c2

		dli	$t1, 1
		j	L1
		# The exception happens in the branch delay slot
		csetbounds $c1, $c1, $t1 # This should raise a C2E exception
		nop
		nop
L1:
		cgetbase $a0, $c1	# XXX: FIXME : This is wrong.
		dla	$t0, data
		dsubu   $a0, $a0, $t0

END_TEST

		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		mfc0    $a3, $13 	# Cause register
		#
		# The exception should be in a branch delay slot, so can't
		# just increment EPC. Instead, load EPC with L1, the address
		# of the end of the test.
		#
		dla     $k0, L1
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

		.align	12
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef

