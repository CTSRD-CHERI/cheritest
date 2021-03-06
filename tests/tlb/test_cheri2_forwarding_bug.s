#-
# Copyright (c) 2012 Robert N. M. Watson
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

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"
#
# Test derived from test_tlb_exception_fill which demonstrates a forwarding
# bug once observed on cheri2.
#

BEGIN_TEST

                # Set up a TLB entry
                dli     $a0, 0x1017
                dli     $a1, 0x1057        
        
                dmtc0   $zero, $10                                      # TLB EntryHigh
		dmtc0   $a0, $2						# TLB EntryLow0
		dmtc0   $a1, $3						# TLB EntryLow1
		nop
		nop
		nop
		nop
		tlbwr							# Write Random

        
		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0
		dli	$a6, 0
		
		#
		# Do a loop that will write pages of virtual address space,
		# Then read those back and count the number of non-matches.
		#
		dli $a3, 64
		dli $a4, 0
write_loop:
		sd $a4, 0($a4)
		daddi $a4, $a4, 64
		bnez $a3, write_loop
		daddi $a3, $a3, -64
		
		dli $a3, 64
read_loop:
		daddi $a4, $a4, -64
		ld $a5, 0($a4)
		beq $a5, $a4, skip_add  # <-- This branch experiences forwarding bug from load
		nop
		addi $a6, $a6, 1
skip_add:
		bnez $a3, read_loop
		daddi $a3, -64
	
return:
END_TEST
