#-
# Copyright (c) 2014 Jonathan Woodruff
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

.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test capability pointer compare less than
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Copy C0 into C1 and C2, compare them.
		cmove $c1, $c0
		cmove $c2, $c0
		clt	$a0, $c1, $c2
		# Result should be 0, !<

		# Set different offsets for C1 & C2, and compare them
		li	$t0, 0x1
		csetoffset	$c1, $c0, $t0
		li	$t0, 0x2
		csetoffset	$c2, $c0, $t0
		clt	$a1, $c1, $c2
		# Result should be 1, <
		
		# Set different bases for C1 & C2, and compare them
		li	$t0, 0x1
		cincbase	$c1, $c0, $t0
		li	$t0, 0x2
		cincbase	$c2, $c0, $t0
		clt	$a2, $c1, $c2
		# Result should be 1, <
		
		# Clear the tag of C3 and C4 to make them NULL, and compare them
		cmove	$c3, $c1
		ccleartag	$c4, $c2
		clt	$a3, $c3, $c4
		# Result should be 0, !<, despite different base+offset being less than.
		
		# Set complementary offsets for C1 & C2 so that effective addresses
		# are equal
		li	$t0, 0x2
		csetoffset	$c1, $c1, $t0
		li	$t0, 0x1
		csetoffset	$c2, $c2, $t0
		clt	$a4, $c1, $c2
		# Result should be 0, !< (They are equal)
		
		# Set zero length for C1 to make it NULL, and compare
		ccleartag	$c1, $c1
		clt	$a5, $c1, $c2
		# Result should be 1, <, despite identical base + offset.
		
		# end test
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

		.data
		.align	5                  # Must 256-bit align capabilities
cap1:		.dword	0x0123456789abcdef # uperms/reserved
		.dword	0x0123456789abcdef # otype/eaddr
		.dword	0x0123456789abcdef # base
		.dword	0x0123456789abcdef # length

