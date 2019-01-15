#-
# Copyright (c) 2016 Michael Roe
# Copyright (c) 2019 Alex Richardson
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
# Test the CSub instruction
#

BEGIN_TEST
		cgetdefault $c1
		dla	$t0, data
		csetoffset $c1, $c1, $t0
		dli	$t0, 8
		csetbounds $c1, $c1, $t0

		dli	$t0, 5
		cincoffset $c2, $c1, $t0
		dli	$t0, 1
		cincoffset $c1, $c1, $t0

		csub	$a0, $c2, $c1

		# subtract two untagged values
		CFromIntImm $c3, 0x1234
		CFromIntImm $c4, 0x1001
		csub $a1, $c3, $c4

		# subtract an untagged value from a tagged one:
		cgetdefault $c5
		dli $t0, 0x2345
		cincoffset $c5, $c5, $t0
		csub $a2, $c5, $c3

		# subtract a tagged value from an untagged one:
		CFromIntImm $c6, 0x7777
		csub $a3, $c6, $c5

		# subtract two capabilities with different bounds:
		csetbounds $c7, $c5, 8  # addr 0x2345
		cgetdefault $c8
		dli $t0, 0x9999
		cincoffset $c8, $c8, $t0
		csetbounds $c8, $c8, 1 # addr 0x9999
		csub $a4, $c8, $c7

		csub $a5, $c7, $cnull  # $c7 addr is 0x2345

		cgetdefault $c9
		csetoffset $c9, $c9, $zero
		csetbounds $c9, $c9, 8
		csub $a6, $cnull, $c9  # $c9 addr is 0x0 -> diff should be 0




END_TEST

		.data
data:		.dword 0


