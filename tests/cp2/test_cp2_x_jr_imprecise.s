#-
# Copyright (c) 2012, 2015 Michael Roe
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
# Test that an exception is raised if a jump register instruction goes
# outside the range of PCC, and (in the 128-bit capability case) this causes
# PCC to lose precision.
#

sandbox:
		jr	$a0
		nop
		nop
		cjr	$c24
		nop
		nop
limit:
		nop

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
		dla     $t0, sandbox 
		cincoffset $c1, $c1, $t0
		dla     $t1, limit
		dsubu	$t2, $t1, $t0
		csetbounds $c1, $c1, $t2

		#
		# Make $a0 so far outside the sandbox that it will cause
		# PCC to lose precision with 128-bit capabilities.
		#

		dli	$a0, 1
		dsll	$a0, $a0, 32

		cjalr   $c1, $c24
		nop			# Branch delay slot
finally:

		dla	$t0, sandbox
		dsubu	$a0, $a1, $t0

END_TEST

		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		cgetepcc $c27
		cgetoffset $a1, $c27
		cgettag $a4, $c27
		cgetcause $a3
		dla	$k0, finally
		cgetdefault $c27
		csetoffset $c27, $c27, $k0
		csetepcc $c27
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

