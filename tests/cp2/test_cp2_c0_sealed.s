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
# Test can run instructions that don't load or store if c0.sealed is set.
#

BEGIN_TEST
		#
		# Save $ddc so can restore it later
		#

		cgetdefault $c1

		#
		# Make $c2 a capability for a user-defined type whose id
		# is 0x1234.
		#

		dli $t0, 0x1234
		cgetdefault $c2
		csetoffset $c2, $c2, $t0

		#
		# Clear $a1 so we can tell if the cgetlen later on succeeds
		# in changing $a1.

		dli $a1, 0

		#
		# Seal $c1 with $c2
		#

		cseal $c3, $c1, $c2

		#
		# ... and copy it to $ddc
		#

		csetdefault $c3

		#
		# Try a capability operation that doesn't use the sealed $ddc
		#

		cgetlen $a1, $c1

		#
		# Restore the original $ddc
		#

		csetdefault $c1

END_TEST

		.data
		.align 3
data:		.dword	0xfedcba9876543210
