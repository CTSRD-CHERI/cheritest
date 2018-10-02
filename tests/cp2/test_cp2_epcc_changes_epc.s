#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2017 Robert M. Norton
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
# Test to check that writing EPCC also changes CP0_EPC
#
BEGIN_TEST
		cgetpcc $c1
		dli	$t0, 0x12345
		csetoffset $c2, $c1, $t0


		dmfc0	$a0, $12	# Get initial status
		csetepcc	$c2
		# Load EPCC and EPC for inspection
		cgetepcc	$c3
		dmfc0	$s0, $14	# s0 = EPC
		dmfc0	$s1, $30	# s1 = ErrorEPC
END_TEST
