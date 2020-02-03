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
# Check that various operations interrupt load linked + store conditional.
#

BEGIN_TEST
		dla $t0, word

		#
		# Uninterrupted access; check to make sure the right value
		# comes back.
		#
		ll	$a0, 0($t0)
		sc	$a0, 0($t0)
		lwu	$a1, 0($t0)

		#
		# Check to make sure we are allowed to increment the loaded
		# number, so we can do atomic arithmetic.
		#
		ll	$a3, 0($t0)
		addiu	$a3, $a3, 1
		sc	$a3, 0($t0)
		lwu	$a4, 0($t0)

		#
		# Trap between ll and sc; check to make sure that the sc not
		# only returns failure, but doesn't store.
		#
		ll	$a5, 0($t0)
		addiu	$a5, $a5, 1
		tnei	$zero, 1
		sc	$a5, 0($t0)
		lwu $a6, 0($t0)

END_TEST


		.data
word:		.word	0xffffffff
