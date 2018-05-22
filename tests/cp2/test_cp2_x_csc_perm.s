#-
# Copyright (c) 2012 Michael Roe
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
# Test that CSCR raises an exception if it does not have
# Permit_Store_Capability permission.
#

BEGIN_TEST
		#
		# Set up exception handler
		#

		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		# $a2 will be set to 1 if the exception handler is called
		dli	$a2, 0

		#
		# Make $c1 a data capability for the array 'data'
		#

		cgetdefault $c1
		dla     $t0, data
		csetoffset $c1, $c1, $t0
		dli     $t0, 8
                csetbounds $c1, $c1, $t0
		dli     $t0, 0x7f
		candperm $c1, $c1, $t0

		#
		# Remove Permit_Store_Capability from $c2
		#

		dli $t0, 0x1df
		cgetdefault $c2
		candperm $c2, $c2, $t0


		# Try to store the capability via a capability
		# that doesn't permit this.

		dla	$t0, cap1
		clc	$c3, $t0, 0($c0) # load the original value into $c3
		csc	$c1, $t0, 0($c2) # This should raise an exception
		# Check that the store didn't happen.
		clc	$c4, $t0, 0($c0)


		# Now check that it also doesn't happen when Permit_Store is missing
		# Store 1 to second_check so that the trap handler fills in the
		# other two registers
		dla $t0, second_check
		dli $t1, 1
		csd $t1, $t0, 0($c0)

		# $a5 will be set to 1 if the exception handler is called
		dli	$a5, 0
		# Remove Permit_Store
		dli	$t0, ~__CHERI_CAP_PERMISSION_PERMIT_STORE__
		cgetdefault $c2
		candperm $c2, $c2, $t0

		# Try to store the capability via a capability
		# that doesn't permit this.
		dla	$t0, cap1
		csc	$c1, $t0, 0($c2) # This should raise an exception
		# Check that the store didn't happen.
		clc	$c5, $t0, 0($c0)

		# load the first 16 bytes:
		cld	$a0, $t0, 0($c0)
		cld	$a1, $t0, 8($c0)

END_TEST

		.ent bev0_handler
bev0_handler:
		dla $k0, second_check
		cld $k0, $k0, 0($c0)
		bne $k0, $zero, .Lsecond_check
		nop
.Lfirst_check:
		li	$a2, 1
		cgetcause $a3
		b .Lreturn_from_trap
		nop
.Lsecond_check:
		li	$a5, 1
		cgetcause $a6

.Lreturn_from_trap:
		dmfc0	$k1, $14	# EPC
		daddiu	$k0, $k1, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14
		nop
		nop
		nop
		nop
		eret
		.end bev0_handler

		.data
		.align	3
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef

second_check:
		.8byte 0

		.align 5
cap1:		.dword 0x0 
		.dword 0x0 
		.dword 0x0
		.dword 0x0
