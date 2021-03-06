#-
# Copyright (c) 2017 Michael Roe
# Copyright (c) 2018 Alex Richardson
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer
# Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
# project, funded by EPSRC grant EP/K008528/1.
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
# Test CLC when the cb does not have Permit_Load_Capability permission,
# and the capability to be loaded does not have the tag bit set.
#

BEGIN_TEST
		cgetdefault $c2
		dli	$t0, 5		# Permit_Load and Global
		candperm $c2, $c2, $t0

		dla	$t0, cap1
		clc 	$c1, $t0, 0($c2)
		dla	$t0, cap2
		csc 	$c1, $t0, 0($ddc)

		ld	$a0, 0($t0)

		# Check that we don't mask any bits when loading/storing untagged values:
		dla	$t0, cap3
		clc	$c3, $t0, 0($ddc)
		csc	$c3, $t0, 0($ddc)
		clc	$c4, $t0, 0($ddc)
		# Load the raw bits:
		cld	$a2, $t0, 0($ddc)
		cld	$a3, $t0, 8($ddc)
		cld	$a4, $t0, 16($ddc)
		cld	$a5, $t0, 24($ddc)

END_TEST

		.data
		.align 5
cap1:		.dword 0x123456789abcdef0
		.dword 0
		.dword 0
		.dword 0
cap2:		.dword 0
		.dword 0
		.dword 0
		.dword 0
cap3:		.dword 0xffffffffffffffff
		.dword 0xffffffffffffffff
		.dword 0xffffffffffffffff
		.dword 0xffffffffffffffff
