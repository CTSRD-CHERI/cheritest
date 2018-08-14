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
.set noreorder

# CCallFast should not be allowed in a delay slot!

BEGIN_TEST
	#
	# Make $c4 a template capability for user-defined type
	# number 0x1234.
	#
	dli		$t0, 0x1234
	cgetdefault	$c4
	csetoffset	$c4, $c4, $t0
	# Make $c3 a data capability for address 0x10000
	dli		$t0, 0x10000
	cgetdefault	$c3
	cincoffset	$c3, $c3, $t0
	dli		$t0, 0x1000
	csetbounds	$c3, $c3, $t0
	dli		$t0, ~CHERI_PERM_EXECUTE
	candperm	$c3, $c3, $t0

	#
	# Seal data capability $c3 to the offset of $c4, and store
	# result in $c2.
	#
	cseal		$c2, $c3, $c4

	#
	# Make $c1 a code capability for sandbox
	#
	dla		$t0, sandbox
	cgetpcc		$c1
	csetoffset	$c1, $c1, $t0
	cseal		$c1, $c1, $c4

	li		$v0, 0	# clear $t1, a change in $v0 means failure.

	# Create a return capability
	cgetpcc		$c3
	dla		$t0, restored_ra
	csetoffset	$c3, $c3, $t0
	# do the ccallfast and write $c4 in the instruction after. This instruction
	# should no longer be executed since
	# If CCall still has a branch delay slot this should read NULL, this
	# should read an untagged 0x0de1a1 (which will be set by the sandbox)
	dli	$a1, 0x1234	# should have this value!
	b restored_ra
	ccall		$c1, $c2, 1	# This should trap (since it's in the delay slot)
	nop
	nop
restored_ra:
	save_counting_exception_handler_cause $c5
END_TEST

        .ent sandbox
sandbox:
	# Should not exeute!
	dli	$a1, 0x42
	cjr	$c3
	nop
.end sandbox
