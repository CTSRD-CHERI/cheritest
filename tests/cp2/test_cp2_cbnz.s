#-
# Copyright (c) 2013 Michael Roe
# Copyright (c) 2017 Jonathan Woodruff
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
# Test CBNZ (capability branch if not NULL).
#

BEGIN_TEST
		dli	$a0, 0
		dli	$a2, 0
		cmove	$c22, $c0
		cbnz	$c22, L1	# This branch should be taken
		dli	$a2, 1  # Branch delay slot is executed even if branch
		dli     $a0, 1
		nop
		nop
L1:
		nop
		dli	$a1, 0
		cgetnull $c22
		cbnz	$c22, L2	# This branch should not be taken
		nop 		# Branch delay slot
		dli	$a1, 1
		nop
		nop

L2:
END_TEST

