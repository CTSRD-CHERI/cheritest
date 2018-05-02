#-
# Copyright (c) 2018 Michael Roe
# Copyright (c) 2018 Alex Richardson
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
# Test CGetAddr
#

BEGIN_TEST

	cgetdefault $c1
	dla	$a0, data
	csetoffset $c1, $c1, $a0
	dli	$t0, 8
	csetbounds $c1, $c1, $t0

	# Create a capability for data + 1
	dli	$t0, 1
	cincoffset $c2, $c1, $t0
	cgetaddr $a1, $c2	# should be data + 1
	# $a2 now contains addr of $c1 (data + 1) minus addr of data -> 1
	dsubu	$a2, $a1, $a0

	# check that we still get a sensible value for out-of-bounds capabilities
	dli	$t0, 0x12345
	cincoffset $c2, $c1, $t0
	cgetaddr $a3, $c2	# should be data + 0x12345

	# check that negative offsets work
	dli	$t0, -1
	cincoffset $c3, $c1, $t0
	cgetaddr $a4, $c3	# should be data - 1

END_TEST

	.data
	.align 3
data:	.dword 0
