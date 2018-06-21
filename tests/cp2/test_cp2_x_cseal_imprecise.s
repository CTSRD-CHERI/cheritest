#-
# Copyright (c) 2013-2016 Michael Roe
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
# Test that cseal in a case where 128-bit capabilities cannot represent the
# bounds exactly.
#

BEGIN_TEST
		cgetdefault $c1
		# cseal allows a precision of at most 8 bits for sealed capabilities,
		# so try to seal with a base and length that requires more.
		dli $t0, 0x101
		csetoffset $c1, $c1, $t0
		csetbounds $c1, $c1, $t0

		dli	$t0, 0x11
		cgetdefault $c2
		csetoffset $c2, $c2, $t0

		cgetnull $c3

		clear_counting_exception_handler_regs
		cseal $c3, $c1, $c2	# Should raise an exception
		save_counting_exception_handler_cause $c4

		# Now try a value that's always unrepresentable
		dli $t0, 0x77777
		cgetdefault $c1
		csetoffset $c1, $c1, $t0
		csetbounds $c1, $c1, $t0

		dli	$t0, 0x12
		cgetdefault $c2
		csetoffset $c2, $c2, $t0

		cgetnull $c6
		clear_counting_exception_handler_regs
		cseal $c6, $c1, $c2	# Should raise an exception
		save_counting_exception_handler_cause $c7

END_TEST
