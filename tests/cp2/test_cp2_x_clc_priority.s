#-
# Copyright (c) 2013 Michael Roe
# Copyright (c) 2019 Alex Richardson
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
# Test exception priorities in clc
#
# This test case was originally discovered by running the SAL Automatic Test
# Generator on the formal model.
#

sandbox:
		creturn

BEGIN_TEST
		cgetdefault $c1
		dla	$t0, cap1
		csetoffset $c1, $c1, $t0
		dli	$t0, 32
		csetbounds $c1, $c1, $t0

		cgetnull $c2 # So we can tell if $c2 has changed

		# There are two possible exceptions that could be raised in
		# the next instruction: the address isn't 32-byte aligned
		# (AdEL exception) and it's outside the range of the capability
		# (C2E with cause=Length Violation). The CHERI spec says that
		# C2E has priority over AdEL. This priority order is sometimes
		# needed for security; it isn't security-relevant in this case,
		# but we keep the same priority order for simplicity.

		dli	$t0, 33
		check_instruction_traps $s1, clc	$c2, $t0, 0($c1)
		cgetlen $a0, $c2

END_TEST

		.data
		.align	5
cap1:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef

