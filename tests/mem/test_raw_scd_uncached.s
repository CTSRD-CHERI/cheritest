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
.set noat

#
# Test SCD to an uncached address. The behaviour is undefined in the MIPS
# ISA. This is a regression test for a bug in BERI in which it deadlocked
# the CPU. Even though behaviour is unpredicatable, it should not deadlock.
#

		.text
		.global start
start:
                # Avoid a race in multithreaded mode by only continuing
                # with a single thread
                dmfc0   $k0, $15
                srl     $k0, 24
                and     $k0, 0xff  # get thread ID
thread_spin:    bnez    $k0, thread_spin # spin if not thread 0
                nop

		dla	$gp, dword
		dli	$at, 0x00000000FFFFFFFF
		and $gp, $gp, $at
		dli	$t0, 0x9000000000000000		# Cached, non-coherent
		daddu	$gp, $gp, $t0
		
		# Initialize link register to the store address.
		lld 	$k0, 0($gp)
		
		# Store and load a double word into double word storage, uncached
		dli	$s4, 0xfedcba9876543210
		scd	$s4, 0($gp)			# @dword
		ld	$s5, 0($gp)

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
		nop

		.data
dword:		.dword	0x0000000000000000
