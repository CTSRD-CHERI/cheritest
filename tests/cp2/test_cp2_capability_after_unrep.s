#-
# Copyright (c) 2018 Alex Richardson
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
#
# Test the value of the capability fields when a capability becomes unrepresentable
# See https://github.com/CTSRD-CHERI/cheri-isa/issues/19
#
BEGIN_TEST
this_test:
		cgetdefault	$c1
		csetbounds	$c1, $c1, 20
		dli		$t0, 0x0007
		candperm	$c1, $c1, $t0

		# Load an unrepresentable offset and create $c2 with it
		dli		$a1, 0x10000000
		csetaddr	$c2, $c1, $a1

		cgetlen		$s0, $c2
		cgetaddr	$s1, $c2
		cgetbase	$s2, $c2
		cgetperm	$s3, $c2
		cgetoffset	$s4, $c2
END_TEST
