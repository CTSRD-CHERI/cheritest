#-
# Copyright (c) 2012 Robert M. Norton
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

.include "macros.s"

# Test that the rdhwr instruction can be used in userspace when the right
# bit in CP0.HWREna is set.

BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER
		#
		# Set CP0.HWREna.userlocal, enabling access to the userlocal
		# register from userspace.
		#

		dli	$t0, 1 << 29
		or      $t0, 4
		dmtc0	$t0, $7

		# UserLocal is readable as hardware register 29
		# and writable as CP0 register 4, select 2.

		lui 	$t0, 0x1234
		ori	$t0, $t0, 0x5678
		dsll	$t0, $t0, 16
		ori	$t0, $t0, 0x9abc
		dsll	$t0, $t0, 16
		ori	$t0, 0xdef0
		dmtc0	$t0, $4, 2

		dli	$a1, 0

		jump_to_usermode testcode

the_end:
END_TEST

.balign 4096	# ensure all the userspace testcode is on one page
testcode:
		nop
		add	$a5, 1			# Set the test flag
		.set push
		.set mips32r2
		li      $t0, 1
		# a bug in cheri2 meant the rdhwr didn't get forwarded properly so run this twice to make sure it is in cache.
1:
		nop
		nop
		rdhwr   $t1, $29
		or      $a1, $t1, 0             # move to check forwarding
		bnez    $t0, 1b
		li      $t0, 0
		# test that the user count register is accessible
		rdhwr	$a2, $2
		
		.set pop
		syscall 0			# Return to kernel mode

BEGIN_CUSTOM_TRAP_HANDLER
		# fetch CP0 count for comparison
		dmfc0   $a3, $9
		dmfc0   $a6, $12                # Read status
		dmfc0   $a7, $13                # Read cause
		__set_counting_trap_handler_count $zero
		collect_compressed_trap_info $a0
		dla	$t0, the_end
		jr	$t0
		nop
END_CUSTOM_TRAP_HANDLER
