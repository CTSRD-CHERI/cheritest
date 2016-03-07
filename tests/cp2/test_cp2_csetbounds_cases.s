#-
# Copyright (c) 2015 Michael Roe
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer
# Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
# project, funded by EPSRC grant EP/K008528/1.
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
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test the CSetBounds instruction with cases discovered in the wild.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32
		
		# $a0 will be non-zero if any test fails.
		move $a0, $0

		#
		# Case one, found by Robert Watson.
		#
		# Stage 1 setting up the initial capability.
		dli	$t0, 0x1600f4000
		csetoffset $c1, $c0, $t0
		dli	$t1, 0x20000
		csetbounds $c1, $c1, $t1
		# Get and assert that the base and length are what we set.
		cgetbase $v0, $c1
		bne $v0, $t0, error
		cgetlen $v1, $c1
		bne $v1, $t1, error
		nop
		# Stage 2 attempt the failing csetbounds.
		dli	$t3, 0x1ffe0
		daddu $t0, $t0, $t3 # Add this offset to the previous base to get new base.
		csetoffset $c1, $c1, $t3
		dli	$t1, 0x10
		csetbounds $c1, $c1, $t1
		# Get and assert that the base and length are what we set.
		cgetbase $v0, $c1
		bne $v0, $t0, error
		cgetlen $v1, $c1
		bne $v1, $t1, error
		nop

		
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
		
error:
		jr $ra
		li $a0, 1			# branch-delay slot

		.data
		.align 3
data:
		.dword 0
