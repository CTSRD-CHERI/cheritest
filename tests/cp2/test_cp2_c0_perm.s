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
# Test can run instructions that load from memory if c0.perms.Permit_Store
# is not set.
#

BEGIN_TEST
		#
		# Save $ddc so we can restore it later
		#	

		cgetdefault   $c1

		#
		# Remove Permit_Store permission from $ddc
		#

		dli     $t0, 0x1f7
		candperm $c2, $c1, $t0
		csetdefault $c2


		#
		# Load a byte from the array 'data'. lb implicitly uses
		# c0, which grants Permit_Load, so this should work.
		#

		dla	$t0, data
		lb	$a0, 0($t0)

		#
		# Restore the original $ddc
		#

		csetdefault $c1

END_TEST

		.data
		.align 3
data:		.dword	0xfedcba9876543210
