#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2014-2015 Michael Roe
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
# Test candperm with one of the user-defined permission bit set.
#

BEGIN_TEST
		dli	$a0, 1
		dli	$a1, 2
		dli	$a3, 3
		cgetdefault	$c1
		cgetperm	$a0, $c1

		lui	$t0, 0x4000
		or	$t0, 0x01
		cgetdefault $c1
		candperm $c1, $c1, $t0
		cgetperm $a1, $c1

		lui	$t0, 0x40
		or	$t0, 0x01
		cgetdefault $c2
		candperm $c2, $c2, $t0
		cgetperm $a2, $c2
		
		lui	$t0, 0x4
		or	$t0, 0x01
		cgetdefault $c2
		candperm $c2, $c2, $t0
		cgetperm $a3, $c2

		# clear all hardware perms and check that user perms start at bit 15
		.set ALL_HW_PERMS, (2 * CHERI_PERM_SYSTEM_REGS) - 1
		dli $t0, ~ALL_HW_PERMS
		cgetdefault $c3
		candperm $c3, $c3, $t0
		cgetperm $a4, $c3
END_TEST
