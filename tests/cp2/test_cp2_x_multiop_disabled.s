#-
# Copyright (c) 2015 Michael Roe
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer
# Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
# project, funded by EPSRC grant EP/K008528/1.
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

#
# Test that CP2 instructions raise an exception if CP2 is disabled
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

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
		cgetperm $t0, $c1
		cgetsealed $t0, $c1
		cgettag $t0, $c1
		cgettype $t0, $c1
		cincoffset $c2, $c1, $zero
		cseal $c2, $c1, $c1
		csetbounds $c2, $c1, $zero
		csetcause $zero
		csetoffset $c2, $c1, $zero
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

		#
		# Branches
		#

		cbts $c1, L1
		nop
L1:
		cbtu	$c1, L2
		nop
L2:
		#
		# Loads and stores
		#

		dla	$t1, data
		clcr	$c2, $t1($c1)
		cscr	$c1, $t1($c1)
		clbr	$t0, $t1($c1)
		csbr	$t0, $t1($c1)
		clhr	$t0, $t1($c1)
		cshr	$t0, $t1($c1)
		clwr	$t0, $t1($c1)
		cswr	$t0, $t1($c1)
		cldr	$t0, $t1($c1)
		csdr	$t0, $t1($c1)
		clldr	$t0, $t1($c1)
		cscdr	$t0, $t1($c1)
		

		#
		# Enable CP2
		#

		mfc0	$t0, $12	# Status register
		dli	$t1, 1
		sll	$t1, 30		# Coprocessor 2 usable bit
		or	$t1, $t1, $t0
		mtc0	$t1, $12

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

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


