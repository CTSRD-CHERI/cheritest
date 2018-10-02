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

# Check that

.include "macros.s"

#
# Test that ERET returns to ErrorEPC (not EPC) if CP0.Status.ERL is set
#

BEGIN_TEST
		dli	$t0, 0xE8808E9C
		dmtc0	$t0, $30	# ErrorEPC
		dla	$t0, 0xE9C
		dmtc0	$t0, $14	# EPC

		dmfc0	$s0, $14	# s0 = EPC
		dmfc0	$s1, $30	# s1 = ErrorEPC


		cgetepcc	$c1	# epcc without ERL should return EPC

		dmfc0	$t0, $12
		ori	$t0, $t0, 0x4
		dmtc0	$t0, $12

		cgetepcc	$c2	# getepcc with ERL should return ErrorEPC

		# Turn off ERL bit and fetch again:
		dmfc0	$t0, $12
		dli	$t1, ~0x4
		and	$t0, $t0, $t1
		dmtc0	$t0, $12
		cgetepcc	$c3	# ERL off again -> should return EPC

		# finally turn it on again to check that the register dump contains ErrorEPC
		dmfc0	$t0, $12
		ori	$t0, $t0, 0x4
		dmtc0	$t0, $12
		cgetepcc	$c4	# ERL on again -> should return ErrorEPC
END_TEST	# When dumping registers epcc.offset should now print ErrorEPC
