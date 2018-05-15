#-
# Copyright (c) 2018 Michael Roe
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
# Test the representation of capabilities when the tag bit is not set
#

BEGIN_TEST
		cgetnull $c1
		dli	$t0, 42
		cincoffset $c1, $c1, $t0

		dla	$t0, cap
		cgetdefault $c2
		csetoffset $c2, $c2, $t0
		dli	$t0, 32
		csetbounds $c2, $c2, $t0

L1:		cllc	$c3, $c2
		cscc	$t0, $c1, $c2
		beqz	$t0, L1
		nop

		cld	$a0, $zero, 0($c2)
		cld	$a1, $zero, 8($c2)
		cld	$a2, $zero, 16($c2)
		cld	$a3, $zero, 24($c2)

END_TEST

		.data
		.align 5
cap:		.dword 0
		.dword 0
		.dword 0
		.dword 0