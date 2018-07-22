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
# Test that (some) CP2 instructions raise an exception if one of the operands
# is a reserved register and PCC does not grant permission to access it.
#

sandbox:
		cllc	$c2, $c29
		cscc	$t0, $c1, $c29
		cscc	$t0, $c29, $c1
		cllb	$t0, $c29
		cscb	$t0, $t2, $c29
		cllh	$t0, $c29
		csch	$t0, $t2, $c29
		cllw	$t0, $c29
		cscw	$t0, $t2, $c29
		clld	$t0, $c29
		cscd	$t0, $t2, $c29

		# Do this one last since it clobbers c29
		cllc	$c29, $c1

		cjr	$c24
		nop		# Branch delay slot

BEGIN_TEST
		#
		# v0 will be set non-zero if get an unexpected exception
		#
		dli	$v0, 0

		#
		# Set the offsets of $c1 and $c29 to point at the array 'data'.
		# $c29.offset must be set here, because the sandbox does not
		# have permission to set it.
		#

		dla	$t1, data
		cgetdefault $c1
		csetoffset $c1, $c1, $t1
		cgetdefault $c29
		csetoffset $c29, $c29, $t1

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


