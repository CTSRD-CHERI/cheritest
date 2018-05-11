#-
# Copyright (c) 2013 Michael Roe
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
# Test that a double precision floating point store raises an exception if
# C0 does not grant Permit_Load.
#

BEGIN_TEST
		#
		# If the floating point unit is not present, skip the test
		#

		dmfc0	$t0, $16, 1
		andi	$t0, $t0, 0x1
		beq	$t0, $zero, no_fpu
		nop	# Branch delay slot

                #
                # Enable the floating point unit
                #

                mfc0 $t0, $12           # Status Register
                li $t1, 1 << 29         # CP1 Usable
                or $t0, $t0, $t1
                mtc0 $t0, $12
                nop                     # Potential pipeline hazard
                nop
                nop
                nop

		#
		# Clear the BEV flag
		#

		jal bev_clear
		nop

		#
		# Set up exception handler
		#

		dli	$a0, 0xffffffff80000180
		dla	$a1, bev0_common_handler_stub
		dli	$a2, 12	# instruction count
		dsll	$a2, 2	# convert to byte count
		jal	memcpy_nocap
		nop		# branch delay slot	

		# $a2 will be set to 1 if the exception handler is called
		dli	$a2, 0

		#
		# Save c0
		#

		cmove   $c2, $c0

		#
		# Make $c0 a read-only capability
		#

		dli     $t0, 0x1f7 # Permit_Store not granted
		candperm $c0, $c0, $t0

		dla	$t1, data
		dli     $a0, 0
		dmtc1	$a0, $f1
		sdc1    $f1, 0($t1) # This should raise a C2E exception

		#
		# Restore c0
		#

		cmove   $c0, $c2

		#
		# Check that the store didn't happen
		#

		cld 	$a4, $t1, 0($c0)

no_fpu:
END_TEST

		.ent bev0_handler
bev0_handler:
		dli	$a2, 1
		cgetcause $a3
		dmfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14
		nop
		nop
		nop
		nop
		eret
		.end bev0_handler

		.ent bev0_common_handler_stub
bev0_common_handler_stub:
		dla	$k0, bev0_handler
		jr	$k0
		nop
		.end bev0_common_handler_stub

		.data
		.align	3
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef
