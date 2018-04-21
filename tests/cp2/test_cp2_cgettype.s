#-
# Copyright (c) 2017 Alfredo Mazzinghi
# All rights reserved.
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
# Test behaviour of cgettype with sealed and unsealed capabilities.
#
# Expected values to check:
# a0 - must be 0x01, type of the sealed capability
# a1 - must be 0xffffffffffffffff, type of the unsealed capability
BEGIN_TEST

	# prepare a sealed capability
	cgetdefault	$c1
	dli	$at, 0x01
	csetoffset	$c1, $c1, $at
	cgetdefault	$c2
	cseal	$c2, $c2, $c1

	# check the otype of the sealed capability
	cgettype	$a0, $c2

	# check the otype of an unsealed capability
	cgetdefault	$c2
	cgettype	$a1, $c2

END_TEST
