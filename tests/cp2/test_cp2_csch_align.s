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
# Test that CSCH works correctly with different alignments.
#

BEGIN_TEST
		dla	$t0, x
		cgetdefault $c1
		csetoffset $c1, $c1, $t0

		#
		# Read the first half-word of x, change it to 0xfedc,
		# then read it back.
		#
L1:
		cllh	$a0, $c1
		dli	$t1, 0xfedc
		csch	$t2, $t1, $c1
		beqz	$t2, L1

		cllh	$a1, $c1

		#
		# Read the second half-word of x, change it to 0xba98,
		# then read it back.
		#

		dli	$t0, 2
		cincoffset $c1, $c1, $t0

L2:
		cllh	$a2, $c1
		dli	$t1, 0xba98
		csch	$t2, $t1, $c1
		beqz	$t2, L2

		cllh	$a3, $c1

END_TEST

		.data
		.align 4
x:		.dword 0x0123456789abcdef
