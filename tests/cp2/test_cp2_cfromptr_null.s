#-
# Copyright (c) 2014 Michael Roe
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
# Test that cfromptr creates a null capability when given a zero (i.e. NULL)
# pointer value as input.
#

BEGIN_TEST
		dli	$a0, 2
		dli	$a1, 2

		# Set the offset, base, and length to something non-zero so
		# we can tell when they've been set to zero.
		cgetdefault $c1
		dli $t0, 4
		cincoffset $c1, $c1, $t0
		csetbounds  $c1, $c1, $t0
		csetoffset $c1, $c1, $t0

		cgetnull $c1

		# Check the fields of a NULL capability
		cgetperm $a0, $c1
		cgetbase $a1, $c1
		cgetlen  $a2, $c1
		cgetoffset $a3, $c1
		cgettag  $a4, $c1
		cgetsealed $a5, $c1

		# Regression test for sail bug where cfromptr was checking whether
		# register was rt, not whether it's value was zero.
		li       $t0, 0
		cfromptr $c2, $c3, $t0
END_TEST
