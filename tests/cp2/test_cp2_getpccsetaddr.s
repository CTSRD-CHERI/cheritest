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
.include "macros_extra.s"
.set noreorder

# Allow building this test without compiler support
.ifdef COMPILER_UPDATED
.macro cgetpccsetaddr_compat out, offset
	cgetpccincoffset $c\out, $\offset
.endm
.else
.macro cgetpccsetaddr_compat out, offset
	cheri_2arg_insn 0x14, \out, \offset
.endm
.endif


BEGIN_TEST
		# Make $c1-4 differemt from $pcc
		cgetnull $c1
		cgetnull $c2
		cgetnull $c3
		cgetnull $c4
.Lfirst_getpcc:
		cgetpccsetaddr_compat  1, 0  # equivalent to getpcc

		b .Lcontinue
.Lsecond_getpcc:
		cgetpccsetaddr_compat 2, 0 # equivalent to getpcc in brach delay slot
.Lcontinue:
		dli $4, 0x123456
.Lthird_getpcc:
		cgetpccsetaddr_compat 3, 4

		b .Lcontinue2
.Lfourth_getpcc:
		cgetpccsetaddr_compat 4, 4  # branch delay slot
.Lcontinue2:

END_TEST

