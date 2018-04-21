#-
# Copyright (c) 2015 Michael Roe
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
# a0 - cnexeq of capability with itself, should be 0
# a1 - cnexeq of capabilities with different offset, should be 1	
# a2 - cnexeq of capabilities with different permissions, should be 1
# a3 - cnexeq of capabilities with different lengths, should be 1
# a4 - cnexeq of capabilities with different tags, should be 1
	

BEGIN_TEST
		cgetdefault $c1
		cmove	$c2, $c1
		cnexeq	$a0, $c1, $c2

		dli	$t0, 1
		cincoffset $c2, $c1, $t0
		cnexeq	$a1, $c1, $c2

		candperm $c2, $c1, $zero
		cnexeq	$a2, $c1, $c2

		dla	$t0, data
		csetoffset $c1, $c1, $t0
		dli	$t0, 8
		csetbounds $c1, $c1, $t0
		dli	$t0, 4
		csetbounds $c2, $c1, $t0
		cnexeq	$a3, $c1, $c2

		cgetdefault $c1
		cgetdefault $c2
		ccleartag $c2, $c2
		cnexeq	$a4, $c1, $c2

END_TEST

		.data
data:		.dword 0
