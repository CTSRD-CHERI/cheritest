#-
# Copyright (c) 2017 Alfredo Mazzinghi
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
.set nobopt
.set noat
.include "macros.s"
# Regression test for qemu bug that caused some capabilities
# to be flagged as unrepresentable even when within bounds.
# The bug was triggered when the representable region underflows below 0.
#
# Expected values to check
# a0 - must be 1, incoffset with positive increment works
# a1 - must be 1, incoffset with negative increment works
BEGIN_TEST
	
		cgetdefault $c1
		cgetdefault $c18
		dla $a1, cap
		dli $t0, 0x130000000
		csetbounds $c1, $c1, $t0
		li $t0, 0x1000
		csetoffset $c1, $c1, $t0
		li $t0, 0x1010
		csetoffset $c3, $c1, $t0
		dli	$t0, 16
		cincoffset $c2, $c1, $t0
		csc	$c2, $a1, 0($c18)
		csc	$c3, $a1, 32($c18)
		cexeq $a0, $c2, $c3
	
		li $t0, 0xff0
		csetoffset $c3, $c1, $t0
		dli	$t0, -16
		cincoffset $c2, $c1, $t0
		csc	$c2, $a1, 64($c18)
		csc	$c3, $a1, 96($c18)
		cexeq $a1, $c2, $c3
	
END_TEST


.data
.align 6
cap:
	.space 128
