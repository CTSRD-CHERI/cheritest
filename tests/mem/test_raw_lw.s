#-
# Copyright (c) 2011 Robert N. M. Watson
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
# Unit test that loads words from memory
#
		.text
		.global start
		.ent start
start:
		# Load a word from double word storage
		dla $a0, dword
		lwu	$a0, 0($a0)

		# Load words with sign extension
		dla $a1, positive
		lw	$a1, 0($a1)
		dla $a2, negative
		lw	$a2, 0($a2)

		# Load words without sign extension
		dla $a3, positive
		lwu	$a3, 0($a3)
		dla $a4, negative
		lwu	$a4, 0($a4)

		# Load words at non-zero offsets
		dla	$t0, val1
		lw	$a5, 4($t0)
		dla	$t1, val2
		lw	$a6, -4($t1)

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
		mtc0 $v0, $23
		.end start
end:
		b end
		nop

		.data
dword:		.dword	0xfedcba9876543210
positive:	.word	0x7fffffff
negative:	.word	0xffffffff
val1:		.word	0x00000001
val2:		.word	0x00000002
