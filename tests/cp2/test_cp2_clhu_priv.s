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
# Test clhur (load half word via capability, offset by register) using a fully
# privileged capability.
#

BEGIN_TEST
		dla	$t0, data
		daddiu	$t1, $t0, 4
		daddiu	$t2, $t0, 6

		cgetdefault $c1
		clhu	$a0, $t0, 0($c1)		# 64-bit aligned
		clhu	$a1, $t1, 0($c1)		# 32-bit aligned
		clhu	$a2, $t2, 0($c1)		# 16-bit aligned

END_TEST

		.data
		.align 3
data:		.dword	0x0011223344556677
		.dword	0x8899aabbccddeeff
