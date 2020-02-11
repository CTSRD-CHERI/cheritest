#-
# Copyright (c) 2012 Michael Roe
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
# Test that lb raises an exception if C0 does not grant Permit_Load.
#

BEGIN_TEST
		# Save $ddc
		cgetdefault   $c1
		li $a0, 0xdead
		li $a1, 0xdead

		dla	$t1, data
		# An initial load should succeed:
		check_instruction_traps $s0, lbu $a0, 0($t1)

		# Make $ddc a write-only capability
		dli	$t0, (CHERI_PERM_GLOBAL | CHERI_PERM_EXECUTE | CHERI_PERM_STORE | CHERI_PERM_LOAD_CAP)
		candperm $c2, $c1, $t0

		csetdefault $c2
		check_instruction_traps $s1, lbu $a1, 0($t1) # This should raise a C2E exception

		# Restore $ddc
		csetdefault $c1

END_TEST

		.data
		.align	3
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef


