#-
# Copyright (c) 2012 Robert M. Norton
# Copyright (c) 2014 Michael Roe
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

.include "macros.s"

# Test that eret is not permitted in user mode when the coprocessor
# enable bit is not set.

BEGIN_TEST

		# Install exception handler
		dla	$a0, exception_handler
		jal 	bev0_handler_install
		nop
		li      $a5, 0
		jump_to_usermode testcode
the_end:
END_TEST

.balign 4096	# ensure all the userspace testcode is on one page
testcode:
		nop
		add	$a5, 1			# Set the test flag
		eret				# Should raise an exception
		syscall 0

exception_handler:
                dmfc0   $a6, $12                # Read status
                dmfc0   $a7, $13                # Read cause
		dla	$t0, the_end
		jr	$t0
		nop
