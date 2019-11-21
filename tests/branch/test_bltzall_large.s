#-
# Copyright (c) 2012 Robert M. Norton
# Copyright (c) 2013 Jonathan Woodruff
# Copyright (c) 2014 Michael Roe
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

#
# Test bltzall with an offset of 4- 131072.
# This is a regression test for a bug found by fuzz testing.
#

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"

BEGIN_TEST
		#
		# Copy the routine at 'target' to an address in RAM where
		# there is enough memory for the large jump offset.
		#

		dla	$a0, __end_of_elf_file__
		dla	$a1, target
		dli	$a2, 0x80
		jal	memcpy_nocap
		nop	# Branch delay slot

		#
		# Copy the routine 'branch' at the desired offset from 'branch'
		#

		dla	$a0, __end_of_elf_file__ + 131072 - 4
		dla	$a1, branch
		dli	$a2, 0x80
		jal	memcpy_nocap
		nop	# Branch delay slot

		sync # Ensure that instruction writes are propagated.
		
		#
		# Clear $a2 so we can tell if the branch ends up at the right
		# place.
		#

		dli	$a2, 0

		#
		# Load $a1 with a negative value, so the branch will be taken.
		#

		dli	$a1, -1

		#
		# Jump to the copy of 'branch'
		#

		dla	$a0, __end_of_elf_file__ + 131072 - 4
		jr	$a0
		nop

target:
		dli	$a2, 0x1234
		b	out
		nop			# Branch delay slot

branch:
		bltzall	$a1, .-131072+4
		nop			# Branch delay slot

out:
END_TEST

