#-
# Copyright (c) 2012, 2014 Robert M. Norton
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

.include "macros.s"

# Test multiple CSC instructions in a loop

BEGIN_TEST
.set at
		cgetdefault $c1
		cincoffset $c1, $c1, 0x123
		cgetdefault $c2
		dla $t0, cap
		csetoffset $c2, $c2, $t0


		dli $t0, 500

		cgetnull $c8
		b .Lcheck_trap
		csc $c1, $zero, 0($c8) # delay slot
		nop
.Lcheck_trap:
		move $s0, $k1

		ori $0, $0, 0xdead	# stop tracing on QEMU


.Lloop_start:
		csc $c1, $zero, 0($c2)
		bne $t0, $zero, .Lloop_start
		daddiu	$t0, $t0, -1	# delay slot
.Lend:
		ori $0, $0, 0xbeef	# turn on tracing on QEMU again
		nop
		nop

		clc $c3, $zero, 0($c2)

END_TEST

		.data
		.align 5
cap:
		.dword 0x0123
		.dword 0x4567
		.dword 0x89ab
		.dword 0xcdef
