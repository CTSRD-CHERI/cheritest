#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2013 Michael Roe
# Copyright (c) 2015 SRI International
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

#
# Check that various operations interrupt the capability versions of
# load linked + store conditional double word.
#

BEGIN_TEST
		#
		# Uninterrupted access; check to make sure the right value
		# comes back.
		#

		dla	$t1, hword
		cgetdefault $c1
		csetoffset $c1, $c1, $t1
		cllh	$a0, $c1
		csch	$a0, $a0, $c1
		clh	$a1, $zero, 0($c1)

		#
		# Check to make sure we are allowed to increment the loaded
		# number, so we can do atomic arithmetic.
		#

		cllh	$a2, $c1
		daddiu	$a2, $a2, 1
		csch	$a2, $a2, $c1
		lh	$a3, 0($t1)

		#
		# Trap between cllh and csch; check to make sure that the
		# cschr not only returns failure, but doesn't store.
		# XXX : Where does it check that?
		#

		cllh	$a4, $c1
		tnei	$zero, 1
		csch	$a4, $a4, $c1

		# Load a half-word from double word storage
		dla	$t0, dword
		cgetdefault $c2
		csetoffset $c2, $c2, $t0
		cllh	$s0, $c2

		# Load words with sign extension
		dla	$t0, positive
		cgetdefault $c3
		csetoffset $c3, $c3, $t0
		cllh	$s1, $c3
		dla	$t0, negative
		cgetdefault $c4
		csetoffset $c4, $c4, $t0
		cllh	$s2, $c4

		# Load words unsigned
		cllhu	$s3, $c3
		cllhu	$s4, $c4

END_TEST

		.data
dword:		.dword	0xfedcba9876543210
positive:	.hword	0x7fff
negative:	.hword	0xffff
hword:		.hword	0xffff
