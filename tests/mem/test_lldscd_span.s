#-
# Copyright (c) 2011 Robert N. M. Watson
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

.set mips64
.set noreorder
.set nobopt
.include "macros.s"

#
# Test what happens when there is a normal load or store operation between
# lld and scd. Whether the SC succeeds or fails is "unpredictable" in the
# MIPS32 and MIPS64 spec. In BERI, a store will cause the SC to fail but a
# load will not.
#

BEGIN_TEST
		dla	$t1, dword
		#
		# Load the double word into another register between lld and
		# scd; this shouldn't cause the store to fail.
		#
		lld	$a2, 0($t1)
		ld	$t0, 0($t1)
		scd	$a2, 0($t1)

		#
		# Store to unaligned byte between lld and scd; check to make
		# sure that the scd not only returns failure, but doesn't
		# store.
		#
		li	$t0, 2
		lld	$t2, 0($t1)
		sb	$t2, 1($t1)
		scd	$t0, 0($t1)
		ld	$a3, 0($t1)

		#
		# Store to double word between lld and scd; check to make
		# sure that the scd not only returns failure, but doesn't
		# store.
		#
		li	$t0, 1
		lld	$t2, 0($t1)
		sd	$t2, 0($t1)
		scd	$t0, 0($t1)
		ld	$a6, 0($t1)

END_TEST




		.data
dword:		.dword	0xffffffffffffffff
