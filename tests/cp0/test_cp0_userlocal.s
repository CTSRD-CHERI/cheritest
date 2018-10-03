#-
# Copyright (c) 2013 Michael Roe
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


# The trap handler uses the userlocal register to store the trap count by default
# This would conflict with this test. Store to memory instead.
COUNTING_TRAP_HANDLER_STORE_TO_MEM = 1
.include "macros.s"
#
# Test that the rdhwr instruction can be used to read the user local register.
# The C run time uses this register to hold the thread local pointer.
#

BEGIN_TEST
		# UserLocal is readable as hardware register 29
		# and writable as CP0 register 4, select 2.
		# Hardware register 29 can be accessed if CP0 is accessible
		# (which is the case here) or if bit 29 in CP0.HWREna is set.

		lui 	$t0, 0x1234
		ori	$t0, $t0, 0x5678
		dsll	$t0, $t0, 16
		ori	$t0, $t0, 0x9abc
		dsll	$t0, $t0, 16
		ori	$t0, 0xdef0

		dli	$a0, 0

		dmtc0	$t0, $4, 2
		
		# The rdhwr instruction is from MIP32r2, so this test is not
		# expected to work on earlier MIPS revisions.

		.set push
		.set mips32r2
		rdhwr	$a0, $29
		.set pop

		__get_counting_trap_handler_count $v0
		dmtc0	$v0, $4, 2
END_TEST
