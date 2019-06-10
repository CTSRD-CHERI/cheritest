#-
# Copyright (c) 2019 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory (Department of Computer Science and
# Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
# DARPA SSITH research programme.
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
# Test that CRoundRepresentableLength (a.k.a. "crap") correctly rounds to a
# representable length
#

BEGIN_TEST
	# Create a capability with a base address with lots of interleaved 1/0
	dli $t0, 0x5555aaaa5555aaaa
	cgetdefault $c1
	csetaddr $c1, $c1, $t0
	dli $t1, 0x7aaa5555aaaa5555	# invert the value -> length
	csetbounds $c2, $c1, $t1
	# get the representable mask for 0x5555aaaa5555aaaa
	cram $a0, $t1
	# and check that masking the base and length results in a precisely
	# representable capability

	# get precise length by rounding up (add mask, and with mask+1)
	not $s0, $a0		# negate the mask
	daddu $s1, $t1, $s0	# ensure we go over the next alignment boundary by adding negated mask
	and $s2, $s1, $a0	# s2 = round up to precise length
	# apply mask to base address
	and $s3, $t0, $a0	# s3 = round down to precise base
	cgetdefault $c3
	csetaddr $c3, $c3, $s3

	# This should work now that base and length have been rounded:
	# Try a imprecise setbounds and ensure the value is correct
	csetbounds $c4, $c3, $s2
	nop
	check_instruction_traps $a1, csetboundsexact $c5, $c3, $s2
END_TEST


