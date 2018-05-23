#-
# Copyright (c) 2011 Robert N. M. Watson
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

.include "macros.s"
.set mips64
.set noreorder
.set nobopt
.set noat

# The same as test_cp2_reg_init.s but for pure ABI programs

		.global test
test:		.ent test
		# "read" all the capability registers again to make sure the cclear
		# instruction's effect is seen in the debug register file.
		cmove $c1,  $c1
		cmove $c2,  $c2
		cmove $c3,  $c3
		cmove	$c4,  $c4
		cmove $c5,  $c5
		cmove $c6,  $c6
		cmove $c7,  $c7
		cmove	$c8,  $c8
		cmove $c9,  $c9
		cmove	$c10, $c10
		cmove $c11, $c11
		cmove $c12, $c12
		cmove $c13, $c13
		cmove	$c14, $c14
		cmove $c15, $c15
		cmove $c16, $c16
		cmove $c17, $c17
		cmove	$c18, $c18
		cmove $c19, $c19
		cmove	$c20, $c20
		cmove $c21, $c21
		cmove $c22, $c22
		cmove $c23, $c23
		cmove	$c24, $c24
		cmove $c25, $c25
		cmove $c26, $c26
		cmove $c27, $c27
		cmove	$c28, $c28
		cmove $c29, $c29
		cmove	$c30, $c30
		# TODO: reenable once c31 is no longer reserved
		# cmove $c31, $c31

		jr	$ra
		nop			# branch-delay slot
		.end	test
