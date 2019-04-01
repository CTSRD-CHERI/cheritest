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

.set mips64
.set noreorder
.set nobopt
.include "macros.s"

#
# Check that the CP0 "lladdr" register is properly updated during load linked
# and store conditional operations.
#
BEGIN_TEST

		#Read config5 to determine if LLBit is supported
		dmfc0	$s7, $16, 5

		#
		# Save addresses that will be checked in test results;
		# convert to physical addresses as that is what lladdr will
		# report.
		#
		dli	$t0, 0x00ffffffffffff
		dla	$s0, word1
		and	$s0, $s0, $t0
		dla	$s1, word2
		and	$s1, $s1, $t0
		dla	$s2, word3
		and	$s2, $s2, $t0
		dla	$s3, dword1
		and	$s3, $s3, $t0
		dla	$s4, dword2
		and	$s4, $s4, $t0
		dla	$s5, dword3
		and	$s5, $s5, $t0

		#
		# Query value on reset
		#
		dmfc0	$a0, $17

		#
		# Simple load linked and store conditional
		#
		dla	$t1, word1
		ll	$t0, ($t1)
		nop
		nop
		nop
		dmfc0	$a1, $17
		sc	$t0, ($t1)
		nop
		nop
		nop
		dmfc0	$a2, $17

		#
		# Simple load linked and store conditional double word1
		#
		dla	$t1, dword1
		lld	$t0, ($t1)
		nop
		nop
		nop
		dmfc0	$a3, $17
		scd	$t0, ($t1)
		nop
		nop
		nop
		dmfc0	$a4, $17

		#
		# If we do two load linkeds in a row, we get the second one.
		#
		dla	$t1, word1
		dla	$t2, word3
		ll	$t0, ($t1)
		ll	$t0, ($t2)
		nop
		nop
		nop
		dmfc0	$a5, $17

		#
		# If we do two load linked double words in a row, we get the
		# second one.
		#
		dla	$t1, dword1
		dla	$t2, dword2
		lld	$t0, ($t1)
		lld	$t0, ($t2)
		nop
		nop
		nop
		dmfc0	$a6, $17

		#
		# If we interrupt the load linked, store conditional through
		# an operation that clears LLbit, we should still get the
		# same address.
		#
		dla	$t1, word3
		ll	$t0, ($t1)
		sw	$zero, ($t1)
		nop
		nop
		nop
		dmfc0	$a7, $17

		#
		# If we interrupt the load linked, store conditional double
		# word through an operation that clears LLbit, we should
		# still get the same address.
		#
		dla	$t1, dword3
		lld	$t0, ($t1)
		sd	$zero, ($t1)
		nop
		nop
		nop
		dmfc0	$s6, $17

END_TEST

		.data
word1:		.word	0xffffffff
word2:		.word	0xffffffff
word3:		.word	0xffffffff
fill:		.word	0x00000000		
dword1:		.dword	0xffffffffffffffff
dword2:		.dword	0xffffffffffffffff
dword3:		.dword	0xffffffffffffffff
