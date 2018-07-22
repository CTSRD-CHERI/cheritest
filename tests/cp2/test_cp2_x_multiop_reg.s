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
#
# Test that CP2 instructions no longer raise an exception if one of the operands
# is a previously reserved register and PCC does not grant permission to access it.
#

sandbox:
		#
		# Try some CP2 instructions
		#
		cgetdefault $c29
		cgetdefault $c1
		cgetdefault $c2

		candperm $c2, $c29, $zero
		candperm $c29, $c1, $zero
		ccheckperm $c29, $zero
		# cchecktype expects a sealed capability, so don't test
		# it here
		ccleartag $c2, $c29
		ccleartag $c29, $c1
		dli $t0, 1
		cgetdefault $c29
		cfromptr $c2, $c29, $t0
		cfromptr $c29, $c1, $t0
		cgetbase $t0, $c29
		cgetlen	$t0, $c29
		cgetoffset $t0, $c29
		cgetperm $t0, $c29
		cgetsealed $t0, $c29
		cgettag $t0, $c29
		cgettype $t0, $c29
		cincoffset $c2, $c29, $zero
		cincoffset $c29, $c1, $zero
		cseal $c2, $c1, $c29
		cseal $c2, $c29, $c1
		cseal $c29, $c1, $c1
		cgetdefault $c29
		csetbounds $c2, $c29, $zero
		csetbounds $c29, $c1, $zero
		csetboundsexact $c2, $c29, $zero
		csetboundsexact $c29, $c1, $zero
		csetoffset $c2, $c29, $zero
		csetoffset $c29, $c1, $zero
		csub $t0, $c2, $c29
		csub $t0, $c29, $c2
		ctoptr $t0, $c2, $c29
		ctoptr $t0, $c29, $c1
		# cunseal requires a sealed capability, so don't test
		# it here

		#
		# Comparison operations
		#

		ceq	$t0, $c1, $c29
		ceq	$t0, $c29, $c1
		cne	$t0, $c1, $c29
		cne	$t0, $c29, $c1
		clt	$t0, $c1, $c29
		clt	$t0, $c29, $c1
		cle	$t0, $c1, $c29
		cle	$t0, $c29, $c1
		cltu	$t0, $c1, $c29
		cltu	$t0, $c29, $c1
		cleu	$t0, $c1, $c29
		cleu	$t0, $c29, $c1
		ctestsubset $t0, $c1, $c29
		ctestsubset $t0, $c29, $c1
		
		#
		# Register moves
		#

		cmove	$c29, $c1
		cmove	$c1, $c29
		cmovz	$c29, $c1, $zero
		cmovz	$c1, $c29, $zero
		dli	$t1, 1
		cmovn	$c29, $c1, $t1
		cmovn	$c1, $c29, $t1

		#
		# Loads and stores
		#

		dla	$t1, data
		cgetdefault $c29
		clc 	$c2, $t1, 0($c29)
		clc 	$c29, $t1, 0($c1)
		cgetdefault $c29
		csc 	$c2, $t1, 0($c29)
		csc 	$c29, $t1, 0($c1)
		cgetdefault $c29
		clb 	$t0, $t1, 0($c29)
		csb 	$t0, $t1, 0($c29)
		clh 	$t0, $t1, 0($c29)
		csh 	$t0, $t1, 0($c29)
		clw 	$t0, $t1, 0($c29)
		csw 	$t0, $t1, 0($c29)
		cld 	$t0, $t1, 0($c29)
		csd 	$t0, $t1, 0($c29)

		#
		# Clear $c29 with cclearhi
		#

		cclearhi 0x2000

		#
		# Branches
		#

		cbez	$c29, L1
		nop
L1:
		cbnz	$c29, L2
		nop
L2:
		cbts	$c29, L3
		nop
L3:
		cbtu	$c29, L4
		nop
L4:
		cjr	$c24
		nop		# Branch delay slot

BEGIN_TEST
		li	$v0, 0	# No exceptions yet

		#
		# Run sandbox with restricted permissions
		#

		dli     $t0, 0x1ff
		cgetdefault $c4
		candperm $c4, $c4, $t0
		dla     $t0, sandbox
		csetoffset $c4, $c4, $t0
		cjalr   $c4, $c24
		nop			# Branch delay slot

END_TEST

		.data
		.align	5
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef


