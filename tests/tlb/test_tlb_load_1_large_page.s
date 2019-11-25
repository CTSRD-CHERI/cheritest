#-
# Copyright (c) 2012 Robert M. Norton
# Copyright (c) 2012 David T. Chisnall
# Copyright (c) 2013 Jonathan Woodruff
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

# Simple TLB test which configures a TLB entry for the lowest virtual
# page in the xuseg and attempts a load via it.

BEGIN_TEST
		dadd    $s0, $zero, $ra          # Don't save existing s0, init.s doesn't expect it to be preserved

		addi    $a0, $zero, 0            # TLB entry 0
		dla     $a1, testdata            # Physical address testdata
		dla	$a2, __kernel_load_offset__	# load kernel base address and map a 4MB page
		li	$a3, 0x7FE000            # Page mask of 10 1s, 1024*4k = 4M page
		jal     install_tlb_entry
		nop

		# Load testdata via its virtual address into a4
		dla	$a1, testdata
		andi	$a1, $a1, 0xFFFF         # Keep the bottom 16 bits of the address
		dla	$a4, __kernel_load_offset__
		daddu	$a4, $a4, $a1		# Add to low bits to base address
		ld      $a6, 0($a4)              # Load testdata into a6 via full TLB lookup
		ld      $a7, 0($a4)              # Load testdata again via TLB cache

		# Load testdata2 via its virtual address into a4
		dla	$a1, testdata2
		andi	$a1, $a1, 0xFFFF         # Keep the bottom 16 bits of the address
		dla	$a4, __kernel_load_offset__
		daddu	$a4, $a4, $a1		# Add to low bits to base address
		ld      $a5, 0($a4)              # Load testdata2 via same page
		ld      $a4, 0($a4)              # Load testdata2 again to test any caching
END_TEST

	.data
	.align 12                            # Align on 4KB page boundary
testdata:
	.dword 0xfedcba9876543210            # Magic number for the test in page 1
	.space 4088
testdata2:
	.dword 0xba9876543210fead            # Magic number for the test in page 2
