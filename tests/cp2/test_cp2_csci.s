#-
# Copyright (c) 2011, 2016 Michael Roe
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
# Test that we can store a capability to memory, using an immediate offset.
#

BEGIN_TEST
		#
		# Tweak capability offset field so that we can tell if base and
		# offset are in the right order.
		#

		dli	$t0, 0x5
		cgetdefault $c2
		csetoffset $c2, $c2, $t0

		#
		# Set the permissions field so we can tell if it is stored
		# at the right place in memory. The permissions are
		# Non_Ephemeral, Permit_Execute, Permit_Load, Permit_Store,
		# Permit_Store_Capability, Permit_Load_Capability,
		# Permit_Store_Ephemeral.
		#

		dli $t0, 0x7f
		candperm $c2, $c2, $t0

		#
		# Make $c1 a data capability starting at 32 bytes before cap1
		#

		cgetdefault $c1
		dla $t0, underflow
		csetoffset $c1, $c1, $t0
		dli	$t0, 96
		csetbounds $c1, $c1, $t0

		#
		# Store at cap1 in memory.
		#

		csc	$c2, $zero, 32($c1)

		#
		# Load back in as general-purpose registers to check values
		#

		dla	$t0, cap1
		# $a0 will be the perms field (0x7f) shifted left one bit,
		# plus the u bit (0x1) giving 0xff.
		ld	$a0, 0($t0)
		ld	$a1, 8($t0)
		ld	$a2, 16($t0)
		ld	$a3, 24($t0) # this relies on teh in memory representation of the length field to be the same as in registers...

		# Check that underflow or overflow didn't occur
		dla	$t1, underflow
		ld	$a4, 0($t1)
		dla	$t1, overflow
		ld	$a5, 0($t1)

END_TEST

		.data
		.align	5		# Must 256-bit align capabilities
underflow:	.dword	0x0123456789abcdef
		.dword	0x0
		.dword	0x0
		.dword	0x0
cap1:		.dword	0x0123456789abcdef	# uperms/reserved
		.dword	0x0123456789abcdef	# otype/eaddr
		.dword	0x0123456789abcdef	# base
		.dword	0x0123456789abcdef	# length
overflow:	.dword	0x0123456789abcdef	# check for overflow
		.dword	0x0
		.dword	0x0
		.dword	0x0
