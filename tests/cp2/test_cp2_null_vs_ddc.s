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
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test that some instructions use reg0 as $ddc and other as $cnull
#
BEGIN_TEST
		#
		# Save c0
		#
		cgetdefault   $c2

		# Make $ddc a full-perms capability pointing to data
		dla	$t0, data
		csetoffset $c3, $c2, $t0
		csetdefault $c3

		# cmove should use NULL (or $ddc on older simulators)
		cmove	$c4, $cnull

		# This should be a valid capability even if $c0 is null
		cfromptr $c5, $ddc, $t0
		# This should be a valid pointer even if $c0 is null
		ctoptr	$t1, $c3, $ddc
		# This should should return NULL and not trap
		ctoptr	$t2, $cnull, $ddc

		# cbuildcap should also refer to $ddc
		ccleartag $c6, $c3
		cbuildcap $c7, $ddc, $c6

		# csetoffset/cincoffset should work as cfromint
		cincoffsetimm $c8, $cnull, 42
		dli	$v0, 43
		cincoffset $c9, $cnull, $v0
		dli	$v0, 44
		csetoffset $c10, $cnull, $v0

		# TODO: what should $c0 be in csetbounds?
		# TODO: should cclearregs clear $ddc?

		# Now write to $c0 and check that none of these change $c0
		cgetpccsetoffset $cnull, $t0
		cgetpcc $cnull
		cmove $cnull, $c2
		cincoffsetimm $cnull, $c2, 0
		cincoffset $cnull, $c2, $v0
		csetboundsimm $cnull, $c2, 8
		ccleartag $cnull, $c2

		# For read/writehwr reg0 should be null
		creadhwr $cnull, $1
		# Write $ddc to usertlscap
		cwritehwr $c2, $1
		cwritehwr $cnull, $1

		# TODO: CUnseal, CSeal

		# ensure $ddc points to data
		csetdefault $c3


		# Now do some loads (stores are tested in a separate test
		clbu	$a0, $zero, 0($ddc)
		clhu	$a1, $zero, 0($ddc)
		clw	$a2, $zero, 0($ddc)
		cld	$a3, $zero, 0($ddc)
		clc	$c11, $zero, 0($ddc)
		# load-linked
		cllbu	$a4, $ddc
		cllhu	$a5, $ddc
		cllw	$a6, $ddc
		clld	$a7, $ddc
		cllc	$c12, $ddc

		# set $ddc offset back to zero so that the return works
		csetdefault $c2
END_TEST

		.data
		.balign	64
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef
