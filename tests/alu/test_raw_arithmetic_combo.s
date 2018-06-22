#-
# Copyright (c) 2011 Jonathan Woodruff
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

		.global start
		.ent start
start:
		move $a0, $0                    # a0 = 0
		move $a1, $0                    # a1 = 0
		addi $a0, $a0, -10              # a0 = -10
		addiu $a1, $a0, 30              # a1 = 20
		add  $a0, $a0, $a1              # a0 = 10
		addu $a1, $a1, $a0              # a1 = 30
		and $a1, $a1, $a0               # a1 = 0x01010 & 0x11110 = 0x01010 = 10
		andi $a0, $a1, 2                # a0 = 2
		sll $a0, $a0, 4                 # a0 = 0b10 << 4 = 0b100000 = 0x20 = 32
		dsllv $a1, $a1, $a0             # a1 = 10 << 32 = 0xa00000000
		dadd $a1, $a1, $a1              # a1 = 0x1400000000
		daddi $a1, $a1, 20              # a1 = 0x1400000014
		daddiu $a1, $a1, -10            # a1 = 0x140000000a
		daddu $s0, $a1, $a1		# s0 = 0x2800000014 Stage 1
		sra $a0, $a0, 3                 # a0 = 32 >> 3 = 4
		ori $a0, $a0, 16                # a0 = 0x10100 = 20
		ddiv $0, $s0, $a0               # 0x2800000014 / 20 = 0x200000001 rem 0
		mflo $a1                        # a1 = 0x200000001
		srl $a0, $a0, 4                 # a0 = 0x10100 >> 4 = 1
		ddivu $0, $a1, $a0              # 0x200000001 rem 0
		mflo $a1                        # a1 = 0x200000001
		sll $a1, $a1, 0                 # a1 = 0x1
		div $0, $a1, $a0                # 1 / 1 = 1 rem 0
		mflo $a1                        # a1 = 1
		xori $a1, $a1, 40971            # a1 = 1 ^ 0xa00b = 0xa00a
		xor $a0, $a0, $a1               #
		divu $0, $a0, $a1               #
		mflo $s1			# s1 = 0x0000000001 Stage 2
		dsll $a0, $s1, 20
		mult $a0, $a1
		mfhi $a0
		dsll32 $a0, $a0, 20
		dmult $a0, $a1
		mfhi $a0
		sub $a0, $a0, $a1
		dmultu $a0, $a1
		mflo $s2			# s2 = 0xffffffff9c320384
		sub $a0, $0, $s2
		dsra $a1, $a1, 14
		dsll32 $a0, $a0, 1
		dsrav $a0, $a0, $a1
		dsra32 $a0, $a0, 4
		dsrl $a0, $a0, 4
		mul $a1, $a1, $a1
		dsrlv $s3, $a0, $a1		# s3 = 0x00FFFFFFFFFF1E6F
		dsll32 $a0, $s3, 4
		dsrl32 $a0, $a0, 4
		dsub $a1, $a0, $a1
		multu $a0, $a1
		mflo $a1
		mfhi $a0
		nor $a0, $a0, $a1
		or $s4, $a0, $a1		# s4 = 0xF..FFC3BE75
		dsubu $a0, $s4, $a1
		andi $a1, $a1, 4
		sllv $a0, $a0, $a1
		srav $a0, $a0, $a1
		srlv $a0, $a0, $a1
		subu $a0, $a0, $a1
		lui $a1, 3984
		addi $a1, $a1, 61
		subu $s5, $a0, $a1		# s5 = 0x0
		move $v0, $s5
		
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
