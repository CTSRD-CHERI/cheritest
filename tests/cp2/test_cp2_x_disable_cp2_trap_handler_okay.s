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
# Test that the default trap handler is okay with CP2 being disabled (and doesn't use cgetcause in that case)
#

BEGIN_TEST
	cgetcause $t0	# Should not trap
	nop
	nop
	# Turn off CP2 (to ensure the next cgetcause faults)
	mfc0	$t0, $12
	dli	$t1, ~(1 << 30)
	and	$t0, $t0, $t1
	mtc0	$t0, $12
	# This should trap now:
	dli	$t0, 12345678
	check_instruction_traps $s1, cgetcause $t0		# should trap
	nop
	# Reenable CP2 for the "finish" sequence.
	mfc0	$t2, $12
	dli	$t3, (1 << 30)
	or	$t2, $t2, $t3
	mtc0	$t2, $12
END_TEST
