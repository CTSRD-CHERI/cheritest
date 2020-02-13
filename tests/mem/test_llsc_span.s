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
# load linked and store conditional. In MIPS 32 and MIP 64, it is unpredictable
# whether the SC succeeds or fails. In BERI, a store will cause the SC to fail
# but a load will not.
#

BEGIN_TEST
		# t1 holds the address of word
		dla	$t1, word
		#
		# Load the word into another register between ll and sc; this
		# shouldn't cause the store to fail.
		#
		ll	$a2, ($t1)
		lwu	$t0, ($t1)
		sc	$a2, ($t1)

		#
		# Store to word between ll and sc; check to make sure that
		# the sc not only returns failure, but doesn't store.
		#
		li	$t0, 1
		ll	$a5, ($t1)
		sw	$a5, ($t1)
		sc	$t0, ($t1)
		lwu	$a6, ($t1)

END_TEST




		.data
word:		.word	0xffffffff
