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
# load linked + store conditional half word.
#

BEGIN_TEST
		dla	$t1, hword
		cgetdefault $c1
		csetoffset $c1, $c1, $t1

		#
		# Load the half word into another register between cllh and
		# csch; this shouldn't cause the store to fail.
		#

		cllh	$a0, $c1
		lh	$t0, 0($t1)
		csch	$a0, $a4, $c1

		#
		# Store to half word between cllh and csch; check to make
		# sure that the csch not only returns failure, but doesn't
		# store.
		#

		li	$t0, 1
		li	$a3, 1
		cllh	$a1, $c1
		sh	$a1, 0($t1)
		csch	$t0, $a3, $c1
		lh	$a2, 0($t1)

END_TEST

		.data
hword:		.hword	0xffff
