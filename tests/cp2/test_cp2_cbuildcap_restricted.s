#-
# Copyright (c) 2018 Michael Roe
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

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"
#
# Test CBuildCap with a capability that has restricted bounds
#

BEGIN_TEST
		dli	$a0, 2

		#
		# Make $c1 a capability for 32 bytes starting at 'data'
		#

		cgetdefault $c1
		dla	$t0, data
		csetoffset $c1, $c1, $t0
		dli	$t0, 32
		csetbounds $c1, $c1, $t0

		#
		# Make $c2 a capability for 8 bytes of the array 'data', starting
		# 8 bytes in.
		#

		dli	$t0, 8
		cincoffset $c2, $c1, $t0
		csetbounds $c2, $c2, $t0

		#
		# Clear the tag on $c2 to simulate it being swapped out and the
		# swapped back in.
		#

		ccleartag $c3, $c2

		#
		# Recontruct $c2 using a master capability that contains it
		# as a subset.
		#

		cbuildcap $c4, $c1, $c3

		cexeq	$a0, $c2, $c4

		ccleartag $c5, $c4	# create an untagged version and compare to c3

END_TEST

		.data
data:		.dword 0
		.dword 0
		.dword 0
		.dword 0
