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
# Test cld (load double word via capability) with an unaligned capability,
# crossing a page boundary. This was causing QEMU to assert.

BEGIN_TEST
		#
		# Set up $c1 to point at data
		# We want $c1.length to be 8.
		#
		cgetdefault $c1
		dli	$t0, 0xabcdef
		cincoffset	$c3, $c1, $a0
		dla	$t0, unaligned_data
		csetoffset $c1, $c1, $t0  # $c1 -> data
		dla	$t0, cap_aligned
		csetoffset $c2, $c1, $t0  # $c2 -> cap_aligned

		cgettag	$t0, $c3
		teq	$t0, $zero

		# store the marker capability $c3 before and after
		csc	$c3, $zero, -((2 * CAP_SIZE) / 8)($c2)
		csc	$c3, $zero, -(CAP_SIZE / 8)($c2)
		csc	$c3, $zero, 0($c2)
		csc	$c3, $zero, (CAP_SIZE / 8)($c2)

		clc	$c5, $zero, -((2 * CAP_SIZE) / 8)($c2)
		clc	$c6, $zero, -(CAP_SIZE / 8)($c2)
		clc	$c7, $zero, 0($c2)
		clc	$c8, $zero, (CAP_SIZE / 8)($c2)

		# 64-bit unaligned, crosses page boundary (should clear two tag bits if unaligned stores are supported)
		dli	$a0, 0x1122334455667788
		dli	$s0, 0xdead
		check_instruction_traps $s3, csd $a0, $zero, 0($c1)
		check_instruction_traps $s4, cld $s0, $zero, 0($c1)


		nop
		nop


		# Check that the correct tag bits were cleared
		clc	$c9, $zero, -((2 * CAP_SIZE) / 8)($c2)
		clc	$c10, $zero, -(CAP_SIZE / 8)($c2)
		clc	$c11, $zero, 0($c2)
		clc	$c12, $zero, (CAP_SIZE / 8)($c2)

END_TEST

		.data
.balign 4096
	.fill 4095, 1, 0xaa
unaligned_data:
	.byte 0x1
cap_aligned:
	.fill 128, 1, 0xaa
