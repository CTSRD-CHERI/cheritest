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
# Test cloadtags (load cacheline of tag bits) using a fully privileged capability.
# Depends on csc working, as we litter memory with capabilities to create a
# tag bit pattern to check against.
#

BEGIN_TEST
		dla	$t0, data
		cgetdefault $c1

		csetoffset $c2, $c1, $t0
		cloadtags $a0, $c2

		csc		$c1, $t0, 0($c1)   # 1
		daddiu	$t0, $t0, CAP_SIZE/8
		csw		$t0, $t0, 0($c1)   # 0
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # 1
		daddiu	$t0, $t0, CAP_SIZE/8
		csw		$t0, $t0, 0($c1)   # 0
		daddiu	$t0, $t0, CAP_SIZE/8
		csw		$t0, $t0, 0($c1)   # 0
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # 1
		daddiu	$t0, $t0, CAP_SIZE/8
		csw		$t0, $t0, 0($c1)   # 0
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # 1
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # 1
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # 1
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # 1
		daddiu	$t0, $t0, CAP_SIZE/8
		csw		$t0, $t0, 0($c1)   # 0
		daddiu	$t0, $t0, CAP_SIZE/8
		csw		$t0, $t0, 0($c1)   # 0
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # 1
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # 1
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # 1
		# In the end the pattern is 0xe7a5.

		dla	$t0, data
		csetoffset $c2, $c1, $t0
		cloadtags $a1, $c2

END_TEST

		.data
		.p2align 12				# Certainly cache-line aligned
data:
		.space CAP_SIZE
