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

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"
#
# Test that CP2 instructions raise an exception if CP2 is disabled
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

		#
		# Before we disable CP2, make $c3 a suitable target for
		# CJALR.
		#

		cgetdefault $c3
		dla $t0, L3
		csetoffset $c3, $c3, $t0

		#
		# .. and $c4 a suitable target for CJR.
		#

		cgetdefault $c4
		dla $t0, L4
		csetoffset $c4, $c4, $t0

		#
		# Disable CP2
		#

		mfc0	$t0, $12	# Status register
		dli	$t1, 1
		sll	$t1, 30		# Coprocessor 2 usable bit
		nor	$t1, $t1, $t1
		and	$t0, $t1
		mtc0	$t0, $12

		#
		# Possible pipeline hazard here
		#

		nop
		nop
		nop
		nop
		nop
		
		#
		# Try some CP2 instructions
		#

		candperm $c2, $c1, $zero
		ccheckperm $c1, $zero
		# cchecktype expects a sealed capability, so don't test
		# it here
		ccleartag $c2, $c1
		cfromptr $c2, $c1, $zero
		cgetbase $t0, $c1
		cgetcause $t0
		cgetlen	$t0, $c1
		cgetoffset $t0, $c1
		cgetpcc $c2
		cgetpccsetoffset $c2, $zero
		cgetperm $t0, $c1
		cgetsealed $t0, $c1
		cgettag $t0, $c1
		cgettype $t0, $c1
		cincoffset $c2, $c1, $zero
		cseal $c2, $c1, $c1
		csetbounds $c2, $c1, $zero
		csetboundsexact $c2, $c1, $zero
		csetcause $zero
		csetoffset $c2, $c1, $zero
		csub $t0, $c1, $c1
		ctoptr $t0, $c1, $c1
		# cunseal requires a sealed capability, so don't test
		# it here

		#
		# Capability comparisons
		#

		ceq $t0, $c1, $c1
		cne $t0, $c1, $c1
		clt $t0, $c1, $c1
		cle $t0, $c1, $c1
		cltu $t0, $c1, $c1
		cleu $t0, $c1, $c1
		ctestsubset $t0, $c1, $c1

		#
		# Branches
		#

		cbts	$c1, L1
		nop
L1:
		cbtu	$c1, L2
		nop
L2:
		cjalr	$c3, $c24
		nop
L3:
		cjr	$c4
		nop
L4:
		cbez	$c1, L5
		nop
L5:
		cbnz	$c1, L6
		nop
L6:

		#
		# Loads and stores
		#

		dla	$t1, data
		clc 	$c2, $t1, 0($c1)
		csc 	$c1, $t1, 0($c1)
		clb 	$t0, $t1, 0($c1)
		csb 	$t0, $t1, 0($c1)
		clh 	$t0, $t1, 0($c1)
		csh 	$t0, $t1, 0($c1)
		clw 	$t0, $t1, 0($c1)
		csw 	$t0, $t1, 0($c1)
		cld 	$t0, $t1, 0($c1)
		csd 	$t0, $t1, 0($c1)
		csetoffset $c1, $c1, $t1
		cllc	$c2, $c1
		cscc	$t0, $c1, $c1
		cllb	$t0, $c1
		cscb	$t0, $t3, $c1
		cllh	$t0, $c1
		csch	$t0, $t3, $c1
		cllw	$t0, $c1
		cscw	$t0, $t3, $c1
		clld	$t0, $c1
		cscd	$t0, $t3, $c1
		

		#
		# Register clear instructions
		#

		cclearlo 0x4
		cclearhi 0x1

		#
		# Capability register move instructions
		#

		cmove	$c2, $c1
		cmovz	$c2, $c1, $zero
		cmovn	$c2, $c1, $zero

		#
		# Enable CP2
		#

		mfc0	$t0, $12	# Status register
		dli	$t1, 1
		sll	$t1, 30		# Coprocessor 2 usable bit
		or	$t1, $t1, $t0
		mtc0	$t1, $12

END_TEST

		.ent bev0_handler
bev0_handler:
		daddiu	$a2, $a2, 1
		# CP2 is disabled at this point, so don't try to read the
		# cause register
		# cgetcause $a3

		mfc0	$k0, $13	# Cause register
		srl	$k0, $k0, 2
		andi	$k0, $k0, 0x1f
		addi	$k0, $k0, -11	# Coprocessor unusable exception
		beqz	$k0, expected_exception
		nop			# Branch delay slot

		#
		# If we get an exception we didn't expected, mark the
		# test as failed by setting $a1
		#

		dli	$a1, 1

expected_exception:
		dmfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14
		DO_ERET
		.end bev0_handler


		.data
		.align	5
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef


