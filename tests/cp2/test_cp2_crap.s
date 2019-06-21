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
	dli $t1, 0xaaaa5555aaaa5555	# invert the value -> length
	cgetdefault $c1
	
	# derive representable base without using CRAM
	csetaddr $c2, $c1, $t0
	csetbounds $c2, $c2, $t1
	cgetbase $t0, $c2
	
	# try again with representable base
	csetaddr $c2, $c1, $t0
	csetbounds $c2, $c2, $t1
	# get the representable length for 0x5555aaaa5555aaaa
	crap $a0, $t1
	# and check that it matches the resulting length of $c2
	cgetlen $a1, $c2
END_TEST


