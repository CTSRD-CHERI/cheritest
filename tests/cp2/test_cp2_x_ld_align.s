#-
# Copyright (c) 2012, 2015 Michael Roe
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
# Test that ld raises an exception if C0.base + offset is incorrectly aligned,
# even if the offset itself is aligned.
#
BEGIN_TEST
		# $a2 will be set to 1 if the exception handler is called
		dli	$a2, 0

		#
		# Save $ddc
		#

		cgetdefault   $c1

		#
		# Make $c2 a capability for part of 'data', base unaligned
		#

		dla	$t0, data
		daddiu	$t0, $t0, 127
		csetoffset $c2, $c1, $t0
		dli	$t1, 32
		csetbounds $c2, $c2, $t1
		

		#
		# Move $c2 into the default data capability
		#

		csetdefault $c2

		dli	$t1, 0
		dli     $a0, 1
		check_instruction_traps $s0, ld $a0, 0($zero) # This should raise a C2E exception

		#
		# Restore $ddc
		#

		csetdefault $c1

END_TEST

		.data
		.align	5
data:
		.rept 160
		.byte 0
		.endr

