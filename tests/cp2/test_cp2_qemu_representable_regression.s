#-
# Copyright (c) 2019 Alex Richardson
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

#
# QEMU previously reported this CIncOffset as being unrepresentable:

BEGIN_TEST
	# $c01: v:1 s:0 p:0007817d b:00000000000b7fcc l:00000000000000e1 o:0 t:-1
	dli $t0, 0x00000000000b7fcc
	dli $t1, 0x00000000000000e1
	cgetdefault $c1
	cincoffset $c1, $c1, $t0
	csetboundsexact $c1, $c1, $t1
	# This was reported as unrepresentable in QEMU!
	dli	$a0, 0x34
	cincoffset	$c2, $c1, $a0

	cgettag $a1, $c2
END_TEST


