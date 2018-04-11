#-
# Copyright (c) 2012 Robert M. Norton
# Copyright (c) 2014, 2016 Michael Roe
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

		jump_to_usermode testcode

the_end:
END_TEST

.balign 4096	# ensure all the userspace testcode is on one page
testcode:
		nop

		#
		# These should raise an exception
		#

		mfc0	$a0, $30 		# EPC
		dmfc0	$a0, $30
		mtc0	$a0, $30
		dmtc0	$a0, $30
		eret			
		tlbwi
		tlbwr
		tlbp
		tlbr


		#
		# Return to kernel mode
		#

		syscall 0

		.ent exception_handler
exception_handler:
		mfc0	$k0, $13		# Cause
		srl	$k0, $k0, 2
		andi	$k0, $k0, 0x1f
		xori	$k0, $k0, 0x8		# Syscall
		beqz	$k0, the_end
		nop				# Branch delay
	
		daddiu	$a5, $a5, 1

		dmfc0	$k0, $14		# EPC
		daddiu	$k0, $k0, 4
		dmtc0	$k0, $14
		nop
		nop
		nop
		nop
		nop
		eret
		.end exception_handler
