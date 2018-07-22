#-
# Copyright (c) 2012, 2015 Michael Roe
# Copyright (c) 2018 Alex Richardson
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
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test that cjalr no longer raises an exception if it uses one of the previously
# reserved registers.
#

sandbox2:
		dli     $a0, 1	# Jump successful
		cjr     $c24
		nop			# Branch delay slot

sandbox1:
		cmove	$c3, $c24	# Save return capability
		cjalr	$c27, $c24	# Should raise an exception
		nop			# Branch delay slot
		cmove	$c24, $c3	# Restore return capability
		cjr	$c24		# Return from subroutine
		nop			# Branch delay slot

BEGIN_TEST
		#
		# $a0 will be set to 1 if sandbox is called
		#

		dli     $a0, 0

		#
		# $v0 will be set to 1 if the exception handler is called
		#
		dli	$v0, 0


		#
		# Make $c27 an executable capability for sandbox2
		
		cgetdefault $c27
		dla     $t0, sandbox2
		csetoffset $c27, $c27, $t0

		#
		# Make $c1 an executable capability for sandbox1
		# Discard permission for the reserved registers
		#

		cgetdefault $c1
		dla	$t0, 0x1ff
		candperm $c1, $c1, $t0
		dla	$t0, sandbox1
		csetoffset $c1, $c1, $t0
		
		cjalr   $c1, $c24 	# Call into sandbox1
		nop			# Branch delay slot

END_TEST

		.data
		.align	3
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef


