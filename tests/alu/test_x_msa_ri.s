#-
# Copyright (c) 2017 Alex Richardson
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
# Test that the MDMX/MSA major opcode raises a reserved instruction exception.
# We reuse this instruction for the large immediate CSC and therefore it
# should cause a trap when used without COP2 enabled
#

BEGIN_TEST
		# Turn off CP2 (to ensure this faults even with experimental CSC)
		mfc0	$t0, $12
		move	$a3, $t0
		dli	$t1, 1 << 30
		not	$t1
		and	$t0, $t0, $t1
		mtc0	$t0, $12


		# From LLVM test:
		# CHECK:        andi.b  $w2, $w29, 48           # encoding: [0x78,0x30,0xe8,0x80]
		# andi.b  $w2, $w29, 48
		# .word 0x7830e880
		check_instruction_traps $s1, .word 0x78000000

		#
		# Re-enable CP2
		#

		mtc0	$a3, $12
END_TEST

