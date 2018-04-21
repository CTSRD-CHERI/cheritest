#-
# Copyright (c) 2017 Alfredo Mazzinghi
# Copyright (c) 2017 Michael Roe
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

.set mips64
.set noreorder
.set noat

#
# Test CLC when the cb does not have Permit_Load_Capability permission.
# The capability loaded should have its tag cleared.
#
# Expected values to check:
# a0 - tag bit of the capability
#


	.global test
test:	.ent test
	daddu 	$sp, $sp, -32
	sd	$ra, 24($sp)
	sd	$fp, 16($sp)
	daddu	$fp, $sp, 32
	
	cgetdefault $c2
	dli	$t0, 5		# Permit_Load and Global
	candperm $c2, $c2, $t0
	
	#
	# Store the test capability
	#

	cgetdefault $c1
	dla	$t0, cap
	csc	$c1, $t0, 0($c0)

	#
	# Load it back, it should have its tag cleared
	#

	clc 	$c1, $t0, 0($c2)
	cgettag $a0, $c1
	
	ld	$fp, 16($sp)
	ld	$ra, 24($sp)
	daddu	$sp, $sp, 32
	jr	$ra
	nop			# branch-delay slot
	.end	test
	
	.data
	.align 5
cap:
	.dword 0
	.dword 0
	.dword 0
	.dword 0
