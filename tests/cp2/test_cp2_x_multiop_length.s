#-
# Copyright (c) 2015 Michael Roe
# Copyright (c) 2015 SRI International
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer
# Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
# project, funded by EPSRC grant EP/K008528/1.
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
# Test that load/store via capability instructions raise an exception if
# the load or store goes beyond the length.
#

BEGIN_TEST
		#
		# Clear the BEV flag
		#

		jal	bev_clear
		nop

		#
		# Set up exception handler
		#

		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		#
		# $a1 will be set non-zero if get an unexpected exception
		#

		dli	$a1, 0

		#
		# Count of number of exceptions
		#

		dli	$a2, 0

		cgetdefault $c1
		dla	$t0, data
		csetoffset $c1, $c1, $t0
		dli	$t0, 32
		csetbounds $c1, $c1, $t0

		#
		# If capabilities are imprecise, then the bounds set by
		# CSetBounds might be wider than requested. With these
		# particular bounds and the current 128-bit compression
		# scheme, this won't happen.  But the ISA spec says
		# compresssion scheme are allowed to do this, so check
		# for it.
		#

		cgetbase $a3, $c1
		cgetlen	$a0, $c1
		daddu	$a0, $a0, $a3
		daddiu	$a0, $a0, -1

		#
		# $a0 will probably be 256-bit aligned, but in principle
		# it might not be, so force alignment.
		#
		
		dsrl	$a0, $a0, 5
		dsll	$a0, $a0, 5

		#
		# This address will definitely be outside the bounds.
		#

		daddiu	$a0, $a0, 32

		#
		# Convert it into an offset relative to the base.
		#

		dsubu	$a0, $a0, $a3

		csetoffset $c1, $c1, $zero

		#
		# Try some CP2 instructions
		#

		#
		# Loads and stores
		#

		clc 	$c2, $a0, 0($c1)
		csc 	$c1, $a0, 0($c1)
		clb 	$t0, $a0, 0($c1)
		csb 	$t0, $a0, 0($c1)
		clh 	$t0, $a0, 0($c1)
		csh 	$t0, $a0, 0($c1)
		clw 	$t0, $a0, 0($c1)
		csw 	$t0, $a0, 0($c1)
		cld 	$t0, $a0, 0($c1)
		csd 	$t0, $a0, 0($c1)

		clc	$c2, $zero, -32($c1)
		csc	$c1, $zero, -32($c1)
		clb	$t0, $zero, -1($c1)
		csb	$t0, $zero, -1($c1)
		clh	$t0, $zero, -2($c1)
		csh	$t0, $zero, -2($c1)
		clw	$t0, $zero, -4($c1)
		csw	$t0, $zero, -4($c1)
		cld	$t0, $zero, -8($c1)
		csd	$t0, $zero, -8($c1)

		csetoffset $c1, $c1, $a0
		cllb	$t0, $c1
		cscb	$t1, $t0, $c1
		cllh	$t0, $c1
		csch	$t1, $t0, $c1
		cllw	$t0, $c1
		cscw	$t1, $t0, $c1
		clld	$t0, $c1
		cscd	$t1, $t0, $c1
		cllc	$c2, $c1
		cscc	$t1, $c1, $c1

		dli	$t0, -32
		csetoffset $c1, $c1, $t0
		cllb	$t0, $c1
		cscb	$t1, $t0, $c1
		cllh	$t0, $c1
		csch	$t1, $t0, $c1
		cllw	$t0, $c1
		cscw	$t1, $t0, $c1
		clld	$t0, $c1
		cscd	$t1, $t0, $c1
		cllc	$c2, $c1
		cscc	$t1, $c1, $c1

END_TEST

		.ent bev0_handler
bev0_handler:
		daddiu	$a2, $a2, 1

		mfc0	$k0, $13	# Cause register
		srl	$k0, $k0, 2
		andi	$k0, $k0, 0x1f
		addi	$k0, $k0, -18	# Coprocessor 2 exception
		beqz	$k0, expected_exception
		nop			# Branch delay slot

		#
		# If we get an exception we didn't expected, mark the
		# test as failed by setting $a1
		#

		dli	$a1, 1

expected_exception:
		cgetcause $k0
		xori	$k0, $k0, 0x0101
		beqz	$k0, expected_cause
		nop

		#
		# If we get a cause code we didn't expect, mark the test
		# as failed by setting $a1
		#

		dli	$a1, 1

expected_cause:
		dmfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14
		nop
		nop
		nop
		nop
		eret
		.end bev0_handler


		.data
		.align	5
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef


