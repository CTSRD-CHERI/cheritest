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
# Check that the BadInstrP register is updated for CHERI instructions.
# This is a regression test for QEMU where it was only updated for MIPS instructions
#
BEGIN_TEST
		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a1, -1
		dli	$a2, -2
		dli	$a3, -3

		# QEMU was giving nonsense instructions as BadInst for a CHERI trap.
		# in this case the previous inst even though badreg was $c19:
		# 1200de3fc:      c8 95 08 03     cld     $4, $1, 0($c21)
		# 1200de400:      e8 93 08 03     csd     $4, $1, 0($c19)

		# c21 is a valid capability for data
		cgetdefault	$c21
		dla	$t1, data
		cincoffset	$c21, $c21, $t1
		# create a capability that will give a length violation
		csetbounds	$c19, $c21, $zero
		.set noat
		dla	$4, 0xaabbccdd
		li	$1, 0
		cld     $4, $1, 0($c21)		# This should succeed
		csd     $4, $1, 0($c19)		# This should trap
		nop
		save_counting_exception_handler_cause $c2
		dmfc0	$s1, $8, 1	# BadInstr register
		mfc0	$s2, $8, 1	# BadInstr register (with mfc instead of dmfc)
		nop
		# load back the value to verify that it wasn't stored
		cld	$s0, $zero, 0($c21)
		# load config3 register
		dmfc0	$s3, $16, 3


		# Get BadInstr for csc+clc:
		cgetnull	$c3
		csc	$c3, $zero, 0($c3)
		save_counting_exception_handler_cause $c4
		dmfc0	$s4, $8, 1	# BadInstr register

		cmove	$c1, $c19
		clc	$c3, $zero, 0($c1)
		save_counting_exception_handler_cause $c5
		dmfc0	$s5, $8, 1	# BadInstr register

		# unaligned cap load
		li	$at, 1
		clc	$c3, $at, 0($c21)
		save_counting_exception_handler_cause $c6
		dmfc0	$s6, $8, 1	# BadInstr register

return:
END_TEST

.data
data:
	.8byte 0x123456
	.8byte 0x2
	.8byte 0x0
	.8byte 0x0
