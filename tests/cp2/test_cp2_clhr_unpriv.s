#-
# Copyright (c) 2011 Robert N. M. Watson
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
# Test clhr (load half word via capability, offset by register) using a
# capability restricted to a specific portion of the global address space.
#

BEGIN_TEST
		#
		# Set up $c1 to point at data
		# We want $c1.length to be 8.
		#
		cgetdefault $c1
		dla	$t0, data
		csetoffset $c1, $c1, $t0
		dli	$t1, 8
		csetbounds $c1, $c1, $t1

		dli	$t0, 0
		dli	$t1, 4
		dli	$t2, 6

		clh	$a0, $t0, 0($c1)		# 64-bit aligned
		clh	$a1, $t1, 0($c1)		# 32-bit aligned
		clh	$a2, $t2, 0($c1)		# 16-bit aligned

END_TEST

		.data
		.align 3
data:		.dword	0x0011223344556677
		.dword	0x8899aabbccddeeff
