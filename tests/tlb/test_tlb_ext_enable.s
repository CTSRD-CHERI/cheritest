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

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"
#
# Test that we can enable the BERI extended TLB
#

BEGIN_TEST
		dli	$a0, 0
		#
		# Check Config5 to see if the BERI extended TLB is supported
		#

		mfc0	$t0, $16, 5
		andi	$t0, $t0, 0x1
		beqz	$t0, not_beri
		nop

		#
		# Enable the extended TLB
		#

		mfc0	$t0, $16, 6
		ori	$t0, $t0, 0x4	# Enable BERI TLB
		mtc0	$t0, $16, 6

		#
		# Check that it has been enabled
		#

		mfc0	$a0, $16, 6
		andi	$a0, $a0, 0x4

not_beri:

END_TEST
