#-
# Copyright (c) 2018 (holder)
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
# Short block comment describing the test: what instruction/behaviour are we
# investigating; what properties are we testing, what properties are deferred
# to other tests?  What might we want to test as well in the future?
#

BEGIN_TEST
	# Test itself goes here
	nop
END_TEST

# If the test needs a trap handler use the code inside the ifdef instead:
.ifdef THIS_TEST_NEEDS_A_TRAP_HANDLER

DEFINE_COUNTING_CHERI_TRAP_HANDLER

BEGIN_TEST
	# Set up exception handler
	set_mips_bev0_handler counting_trap_handler
	# Test itself goes here
	nop

	# Clear the registers used by the trap handler so that saving them
	# doesn't yield the previous exception values
	clear_counting_exception_handler_regs
	teq $zero, $zero	# or any other code that causes a trap
	# Save exception details in a capreg (test the value in python using self.assertCompressedTrapInfo())
	save_counting_exception_handler_cause $c3


END_TEST

.endif # THIS_TEST_NEEDS_A_TRAP_HANDLER
