#-
# Copyright (c) 2018 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
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
# Regression test for a QEMU sign-extension bug that caused QtWebkit JS tests
# to fail
#

BEGIN_TEST
	# Here are the before and after capabilities:
	# (before add) t3: v:1 s:0 p:0007817d b:0000000165200000 l:0000000000004000 o:5d0 t:-1
	# t3 = t3 + __intcap_t(-1536)
	# (after add) t3: v:1 s:0 p:0007817d b:0000000165100000 l:0000000000004000 o:fffd0 t:-1
	# The offset after the add should be properly sign extended and also the base shouldn't have changed.

	cgetdefault $c1
	dli	$t0, 0x7817d
	candperm $c1, $c1, $t0
	dli	$t0, 0x165200000
	cincoffset $c1, $c1, $t0
	dli	$t0, 0x4000
	csetbounds $c1, $c1, $t0
	dli	$t0, 0x5d0
	cincoffset $c1, $c1, $t0

	# Increment using a single cincoffset
	dli $t1, -1536
	cincoffset $c2, $c1, $t1

	# Also increment using the getoffset + add + setoffset that the compiler might use for __intcap_t
	cgetoffset $a0, $c1
	daddiu	$a1, $a0, -1536
	csetoffset $c3, $c1, $a1

	# make $c20 a pointer to store_in_mem:
	cgetdefault $c20
	dla $t0, store_in_mem
	csetoffset $c20, $c20, $t0

	# store and load back $c2 to $c4 (This is what was broken in QEMU128)
	csc $c2, $zero, 0($c20)
	clc $c4, $zero, 0($c20)
END_TEST

.data
.balign 32
store_in_mem:
.space 32
