#-
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

.include "macros.s"
#
# Test the CSetBoundsImmediate instruction.
# This is a regression test for QEMU which treated the Immediate operand as signed
# and allowed expanding the bounds with csetbounds
#
BEGIN_TEST
		# Check that csetboundsimmediate operand is treated as unsigned
		cgetdefault	$c1
		dli	$t0, 4096
		csetbounds	$c1, $c1, $t0

		csetbounds	$c2, $c1, 0
		csetbounds	$c3, $c1, 2047
		csetbounds	$c4, $c1, 1023
		csetbounds	$c5, $c1, 1024
		csetbounds	$c6, $c1, 1

		# Check that the non-immediate version sets correct bounds
		dli	$t0, 0
		csetbounds	$c12, $c1, $t0
		dli	$t0, 2047
		csetbounds	$c13, $c1, $t0
		dli	$t0, 1023
		csetbounds	$c14, $c1, $t0
		dli	$t0, 1024
		csetbounds	$c15, $c1, $t0
		dli	$t0, 1
		csetbounds	$c16, $c1, $t0

		# negative bounds should trap
		dli	$t0, -1
		check_instruction_traps $s0, csetbounds	$c14, $c1, $t0
END_TEST
