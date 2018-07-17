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
# Regression test for QEMU to check that we have the BDELAY flag set in CP0_Cause
# when running a faulting CHERI instruction in a branch delay slot
#

BEGIN_TEST

		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a1, -1
		dli	$a2, -2
		dli	$a3, -3

		dli	$t1, 1
		# QEMU was not setting the bdelay flag when we ran a CHERI instruction in the branch delay slot

		cgetnull $c1

		# Check that MIPS instructions trap and set the BDELAY flag:
		teq	$zero, $zero		# trap #1 (not in delay slot)
		save_counting_exception_handler_cause $c4

		beq	$zero, $t1, return
		teq	$zero, $zero		# trap #2 (in delay slot)
		save_counting_exception_handler_cause $c5



		# Now check various CHERI isntructions (at least one for each major opcode)
		csetbounds $c1, $c1, $t1	# trap #3 (not in delay slot)
		save_counting_exception_handler_cause $c6

		beq	$zero, $t1, return
		csetbounds $c1, $c1, $t1	# trap #4 (in delay slot)
		save_counting_exception_handler_cause $c7

		beq	$zero, $t1, return
		cfromptr $c1, $c1, $t1		# trap #5 (in delay slot)
		save_counting_exception_handler_cause $c8

		beq	$zero, $t1, return
		clc	$c1, $zero, 0($c1)	# trap #6 (in delay slot)
		save_counting_exception_handler_cause $c9

		beq	$zero, $t1, return
		csc	$c1, $zero, 0($c1)	# trap #7 (in delay slot)
		save_counting_exception_handler_cause $c10

		beq	$zero, $t1, return
		clcbi	$c1, 0($c1)		# trap #8 (in delay slot)
		save_counting_exception_handler_cause $c11

return:
END_TEST

