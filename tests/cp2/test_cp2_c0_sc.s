#-
# Copyright (c) 2016 Michael Roe
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

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"
#
# Test store conditional when $ddc has an unaligned offset.
#

BEGIN_TEST
		#
		# Make a capability for the array 'data'
		#

		cgetdefault $c1
		dla	$t0, data
		csetoffset $c1, $c1, $t0
		dli	$t0, 8
		csetbounds $c1, $c1, $t0

		#
		# Save the default data capability
		#

		cgetdefault $c2

		dli	$a0, 0

		#
		# Make $c3 point to an unaligned address within 'data'
		#

		dli	$t0, 1
		cincoffset $c3, $c1, $t0

		dli $t1, 10	# max ten failures
loop:
		beqz	$t1, on_error
		csetdefault $c1
		ll	$t0, 4($zero)
		csetdefault $c3
		check_instruction_traps $s0, sc	$a0, 3($zero)
		beqz	$a0, loop
		daddiu	$t1, $t1, -1	# delay slot

on_error:
		csetdefault $c2


END_TEST

		.data
data:		.dword 0
