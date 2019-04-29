#-
# Copyright (c) 2011 Robert N. M. Watson
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
# Test cloadtags (load cacheline of tag bigs) through a restricted
# capability.  Depends on csc working, as we litter memory with capabilities
# to create a tag bit pattern to check against.
#

BEGIN_TEST
		# Point $c2 at the data block below
		cgetdefault $c2
		dla	$t0, data
		csetoffset $c2, $c2, $t0

		# Initially, there should be no tags; record that fact.
		cloadtags $a0, $c2

		# Figure out how wide our reach is, up to 64 caps: write
		# all ones to the tags through DDC+offset.  While 64 is
		# almost surely overkill, it's permitted and could happen if
		# we ever get a very clever cache fabric.
		#
		# When/if we port this test to RISC-V, 64 should become XLEN
		cgetdefault $c1
		dla	$t0, data
		dli     $t1, 64
floop:
		csc		$c1, $t0, 0($c1)
		daddiu	$t0, $t0, CAP_SIZE/8
		bnez    $t1, floop
		daddi   $t1, $t1, -1

		# Write our reach bit pattern to a1
		cloadtags $a1, $c2

		# Now write a more interesting pattern to the tags
		dla	$t0, data

		csc		$c1, $t0, 0($c1)   # [0] 1  \
		daddiu	$t0, $t0, CAP_SIZE/8 
		csw		$t0, $t0, 0($c1)   # [1] 0  |  0x5
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # [2] 1  |
		daddiu	$t0, $t0, CAP_SIZE/8
		csw		$t0, $t0, 0($c1)   # [3] 0  /
		daddiu	$t0, $t0, CAP_SIZE/8

		csw		$t0, $t0, 0($c1)   # [4] 0  \
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # [5] 1  |  0xA
		daddiu	$t0, $t0, CAP_SIZE/8
		csw		$t0, $t0, 0($c1)   # [6] 0  |
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # [7] 1  /
		daddiu	$t0, $t0, CAP_SIZE/8

		csc		$c1, $t0, 0($c1)   # [8] 1  \
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # [9] 1  |  0x7
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # [a] 1  |
		daddiu	$t0, $t0, CAP_SIZE/8
		csw		$t0, $t0, 0($c1)   # [b] 0  /
		daddiu	$t0, $t0, CAP_SIZE/8

		csw		$t0, $t0, 0($c1)   # [c] 0  \
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # [d] 1  |  0xE
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # [e] 1  |
		daddiu	$t0, $t0, CAP_SIZE/8
		csc		$c1, $t0, 0($c1)   # [f] 1 /
		# In the end the pattern is 0xf..fe7a5.

		# read back through unrestricted capability
		cloadtags $a2, $c2

		# read back through restricted capability
		#
		# Set up $c2 to point at data
		# We want $c2.length to be enough to cover the cloadtags
		# stride.
		dli     $t1, 0
		daddiu  $a3, $a1, 0
cloop:
		dsrl    $a3, $a3, 1
		bnez    $a3, cloop
		daddiu  $t1, $t1, CAP_SIZE/8

		csetbounds $c3, $c2, $t1

		cloadtags $a3, $c3

END_TEST

		.data
		.p2align 12
data:
		.space 64*CAP_SIZE
