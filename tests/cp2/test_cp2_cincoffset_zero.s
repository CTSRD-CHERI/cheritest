#-
# Copyright (c) 2014-2015 Michael Roe
# Copyright (c) 2019 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
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

.include "macros.s"
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test that cincoffset with an offset of zero will work as a move instruction
# on a sealed capability.
#

BEGIN_TEST
		dli	$a0, 0		# Set to 1 if test completes
		dli	$a1, 0

		#
		# Create a sealed capability
		#

		dli	$t0, 1
		cgetdefault $c1
		csetoffset $c1, $c1, $t0
		dli	$t0, 0x7
		cgetdefault $c2
		candperm $c2, $c2, $t0
		cseal	$c2, $c2, $c1


		cgetnull $c3
		cgetnull $c4
		cgetnull $c5
		cgetnull $c6
		# CMove should never trap even with sealed caps
		check_instruction_traps $s0, cmove $c3, $c2

		# Same for CIncOffset with register zero (since we used to encode CMove that way before we had a dedicated instruction)
		check_instruction_traps $s1, cincoffset $c4, $c2, $zero

		# However, CIncOffsetImmediate does not have the special case and should always trap
		check_instruction_traps $s2, cincoffsetimm $c5, $c2, 0

		# Additionally, a CIncOffset where the value happens to be zero should trap:
		dli	$t1, 0
		check_instruction_traps $s3, cincoffset $c6, $c2, $t1


		cgetperm $a1, $c3

		dli	$a0, 1

END_TEST

		.data
		.align 5
cap:		.dword 0
		.dword 0
		.dword 0
		.dword 0
