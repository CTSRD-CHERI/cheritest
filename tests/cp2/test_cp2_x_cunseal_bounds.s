#-
# Copyright (c) 2013-2015 Michael Roe
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
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
.include "macros.s"
#
# Test that cunseal checks that the otype is within the range of ct
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

		#
		# $a2 will be set to 1 if the exception handler is called
		#

		dli	$a2, 0

		#
		# $a3 will be set to the capability cause if there is an
		# exception.
		#

		dli	$a3, 0

		#
		# Choose 0x1234 as the otype for sealing capabilities
		#

		dli	$t0, 0x1234
		cgetdefault $c1
		csetoffset $c1, $c1, $t0

		#
		# Make $c2 a sealed data capability for 'data'
		#

		dla	$t0, data
		cgetdefault $c2
		csetoffset $c2, $c2, $t0
		dli	$t0, 0x1000
		csetbounds	$c2, $c2, $t0
		dli	$t0, 3
		candperm $c2, $c2, $t0
		cseal	$c2, $c2, $c1

		#
		# Make $c3 a capability for a restricted range of otypes
		# (not including 0x1234)
		#

		csetoffset $c3, $c1, $0
		dli	$t0, 0x10
		csetbounds	$c3, $c3, $t0
		dli	$t0, 0x1234
		csetoffset $c3, $c3, $t0

		#
		# Clear $c4 so we can tell if the following cunseal succeeds
		#

		cgetdefault	$c4

		#
		# Try to unseal $c2 with a capability that does not have
		# permission for its otype
		#

		cunseal $c4, $c2, $c3

		cgetbase $a0, $c4

END_TEST

		.ent bev0_handler
bev0_handler:
		li	$a2, 1
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


		.data
		.align 12
data:		.dword 0
