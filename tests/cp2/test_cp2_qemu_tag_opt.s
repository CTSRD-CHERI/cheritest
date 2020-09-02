#-
# Copyright (c) 2020 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory (Department of Computer Science and
# Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
# DARPA SSITH research programme.
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
# Test that QEMU tag storage optimization correctly clears the TCG tlb for *all*
# affect tag locations when allocating a new tag block.
# This was broken when I initially added new optimizations (https://github.com/CTSRD-CHERI/qemu/pull/123).
#

.macro clear_caps
	#
	# Write untagged capabilities to all locations
	#
	.irp n,1,2,3,4,5,6,7,8
		dla	$t0, .Lcaps_start-.Lcap\n
		cincoffset	$c2, $cnull, \n
		csc	$c2, $t0, 0($c1)
	.endr
.endm

.macro check_cap n
	# Store a tagged value to the capability
	dla	$t0, .Lcaps_start-.Lcap\n
	cgetdefault	$c2
	cincoffset	$c2, $c2, \n
	csc	$c2, $t0, 0($c1)
	clc	$c1\n, $t0, 0($c1)
	# Write data to the same address (using csd and not csc) to
	# trigger the invalidate logic instead of the store_cap logic.
	dli	$t1, (\n + 1)
	csd	$t1, $t0, 8($c1)
	# read back the value
	clc	$c2\n, $t0, 0($c1)
.endm

BEGIN_TEST
		# Make $c1 a data capability pointing to 'caps_start'
		cgetdefault $c1
		dla     $t0, .Lcaps_start
		csetaddr $c1, $c1, $t0

		.irp n,1,2,3,4,5,6,7,8
			clear_caps
			check_cap \n
		.endr
END_TEST

		.data
.Lcaps_start:
.balign 8192
.Lcap1:		.chericap	0x0
.Lcap2:		.chericap	0x0
.balign 4096
.Lcap3:		.chericap	0x0
.Lcap4:		.chericap	0x0
.balign 4096
.Lcap5:		.chericap	0x0
.Lcap6:		.chericap	0x0
.balign 4096
.Lcap7:		.chericap	0x0
.Lcap8:		.chericap	0x0
