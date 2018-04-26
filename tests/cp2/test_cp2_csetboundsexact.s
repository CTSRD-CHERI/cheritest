#-
# Copyright (c) 2015, 2017 Michael Roe
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer
# Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
# project, funded by EPSRC grant EP/K008528/1.
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
# Test the CSetBoundsExact instruction.
#

BEGIN_TEST
		#
		# Make $c1 a capability for array 'data'
		#

		cgetdefault $c1
		dla	$t0, data
		csetoffset $c1, $c1, $t0
		dli	$t1, 8
		csetbounds $c1, $c1, $t1

		#
		# Make $c3 something we can detect if it's been overwritten
		#

		cgetdefault $c3
		dli	$t0, 5
		csetoffset $c3, $c3, $t0

		#
		# Use CSetBoundsExact to make $c2's bounds the same as $c1
		#

		cgetdefault $c2
		cgetbase $t0, $c1
		csetoffset $c2, $c2, $t0
		cgetlen $t0, $c1
		csetboundsexact $c3, $c2, $t0

		#
		# The length should be 8 bytes.
		#

		cgetlen	$a0, $c3

		#
		# The offset should point to the array 'data'
		#

		cgetbase $a1, $c3
		cgetoffset $t1, $c3
		daddu	$a1, $a1, $t1
		dla	$t0, data
		dsubu	$a1, $a1, $t0

		#
		# The offset should be zero.
		#

		cgetoffset $a2, $c3
		
END_TEST

		.data
		.align 3
data:
		.dword 0
