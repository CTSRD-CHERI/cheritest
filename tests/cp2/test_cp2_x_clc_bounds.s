#-
# Copyright (c) 2013 Michael Roe
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

# Test that clc raises an exception if an attempt is made to load from
# just after the end of the capability. This is a regression test for a
# bug found by the automatic test generator.

BEGIN_TEST
		cgetdefault $c1
		dla	$t0, cap1
		csetoffset $c1, $c1, $t0
		dli	$t0, 32
		csetbounds $c1, $c1, $t0
		dli	$t0, 0
		dli	$t1, 0

		dli	$a0, 0
		dli	$a2, 0 # $a2 will be set to 1 if an exception is raised
		dli	$a3, 0
		cgetdefault $c2
 		# Initialize length to 0 to test if load occured.
		csetoffset $c2, $c2, $zero
		check_instruction_traps $s1, clc $c2, $zero, 32($c1) # This should raise an exception
		cgetoffset $a0, $c2

END_TEST

		.data

		.align 5
cap1:		.dword 0
		.dword 0
		.dword 0
		.dword 0
		.dword 0x0123456789abcdef
		.dword 0x0123456789abcdef
		.dword 0x0123456789abcdef
		.dword 0x0123456789abcdef
