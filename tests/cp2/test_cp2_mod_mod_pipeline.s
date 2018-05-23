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

.include "macros.s"
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test for a pipeline bug: do an operation that checks the tag bit
# immediately after capability has been moved between registers.
#
# This is a regression test - the _cached version of the test failed.
#

BEGIN_TEST
		dli	$a0, 1
		dla	$t0, cap1
		cgetdefault $c1
		csc	$c1, $t0, 0($c0)
		dli	$t1, 0
		sd	$t1, 8($t0)
		clc	$c1, $t0, 0($c0)
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		cgetdefault  $c1
		candperm $c1, $c1, $zero
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		cgetperm $a0, $c1

END_TEST

		.data
		.align	5		# Must 256-bit align capabilities
cap1:		.dword	0x0123456789abcdef	# uperms/reserved
		.dword	0x0123456789abcdef	# otype/eaddr
		.dword	0x0123456789abcdef	# base
		.dword	0x0123456789abcdef	# length

