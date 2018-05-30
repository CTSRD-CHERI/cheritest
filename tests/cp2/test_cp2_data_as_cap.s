#-
# Copyright (c) 2016 Michael Roe
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
# Test using the capability registers to copy non-capability registers.
#
# memcpy() relies on this to be able to copy a struct without knowing whether it
# contains capabilities or non-capability data.
#

BEGIN_TEST
		dla	$t0, x
		clc 	$c1, $t0, 0($ddc)
		dla	$t0, y
		csc 	$c1, $t0, 0($ddc)
		ld	$a0, 0($t0)
		ld	$a1, 8($t0)
		ld	$a2, 16($t0)
		ld	$a3, 24($t0)

END_TEST

		.data
		.align 5
x:
		.dword 0xffffffffffffffff
		.dword 0xffffffffffffffff
		.dword 0xffffffffffffffff
		.dword 0xffffffffffffffff

		.align 5
y:
		.dword 0
		.dword 0
		.dword 0
		.dword 0
