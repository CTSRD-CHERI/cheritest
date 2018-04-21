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

.include "macros.s"

#
# This tests that we can relocate code to the exception handler address in
# RAM, jump to it manually, and jump back.  This must work for our later
# exception handling tests to work.
#

BEGIN_TEST
		#
		# Set up 'handler' as the RAM exception handler.
		#
		dla	$a0, handler
		jal	bev0_handler_install
		nop

		#
		# Jump to handler address
		#
		li	$t0, 1
		dli	$a0, 0xffffffff80000180
		jr	$a0
		nop			# branch-delay slot

back:
		li	$t2, 3

return:
END_TEST

handler:
		dla	$a0, back
		j	$a0
		li	$t1, 2		# branch-delay slot
