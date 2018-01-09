#-
# Copyright (c) 2018 Alex Richardson
# All rights reserved.
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

# Test that rdhwr counter register is not accessible from user mode when the coprocessor
# enable bit is not set.

.set mips64
.set noreorder
.set nobopt

.include "macros.s"

.global test
.ent    test
test:
		mips_function_entry

		jal     bev_clear
		nop
		
		#
		# Install exception handler
		#

		dla	$a0, exception_handler
		jal 	bev0_handler_install
		nop

		#
		# Set CP0.HWREna to zero, so that user-mode programs do not
		# have access to hardware registers via rdhwr.
		#
		li	$t0, 1 << 4
		dmtc0	$t0, $7  # allow only statcounters icount

		jump_to_usermode usermode

usermode:
		# Check that reading the icount statcounter increments as expected
		.set push
		.set mips64r2
		rdhwr	$a1, $4
		nop
		rdhwr	$a2, $4
		dsubu	$a3, $a2, $a1

		# check that reading any other rdhwr causes a trap
		rdhwr	$t9, $5

		j end  # should never reach this
		nop
		.set pop
the_end:
		mips_function_return



exception_handler:
		dmfc0   $a4, $7                 # fetch HWREna to check it was cleared
		li	$a5, 1
		dmfc0   $a6, $12                # Read status
		dmfc0   $a7, $13                # Read cause
		dla	$t0, the_end
		jr	$t0
		nop
