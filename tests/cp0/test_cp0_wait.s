#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2012 Jonathan Woodruff
# Copyright (c) 2013 Robert M. Norton
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

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"
#
# Test the wait instruction.
#

BEGIN_TEST
		#
		# Set up exception handler.
		#

		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		#
		# Set the CP0 compare register to CP0.count + 1000
		#

		mfc0	$a0, $9		# Read from CP0 count register
		branch_if_is_qemu LQEMU_wait, $t1
LSimulator_wait:
		# wait 1000 * 2 cycles on simulators
		daddiu	$a0, $a0, 1000	# += 1000
		b Lwrite_compare
		nop
LQEMU_wait:
		# QEMU doesn't increment the Count register based on cycles,
		# instead it uses time (50 increments per second).
		# With the current implementation in QEMU the small increment
		# used by the simulators will cause the implementation in
		# QEMU to underflow and wait for almost the maximum ~80 seconds
		dli $t1, (1000 * 1000) # wait for 20ms
		daddu	$a0, $a0, $t1

Lwrite_compare:
		mtc0	$a0, $11	# Write to CP0 compare register

		#
		# $a4 will be set to the cause if an exception occurs
		# Initialize value to 0xff, meaning no exception.
		#
		dli	$a4, 0xff

		#
		# Enable interrupts
		#

		mfc0	$t0, $12	# Read from CP0 status register
		ori	$t0, $t0, 0x80 << 8	# Enable timer interrupt
		ori	$t0, 0x1	# Enable interrupts generally
		mtc0	$t0, $12	# Write to CP0 status register

loop:
		dli	$a1, 1000
		wait
		addi	$a1, $a1, -1
		bnez	$a1, loop
		nop			# branch delay slot

return:
END_TEST

#
# The exception hander
#
		.ent bev0_handler
bev0_handler:
		#
		# Disable timer interrupts
		#

		mfc0	$t0, $12
		li	$t1, 0x8000
		nor	$t1, $t1, $t1
		and	$t0, $t0, $t1
		mtc0	$t0, $12
		
		mfc0	$a3, $12	# Status register
		mfc0	$a4, $13	# Cause register
		dmfc0	$a5, $14	# EPC
		dla	$k0, return
		dmtc0	$k0, $14
		DO_ERET
		.end bev0_handler
