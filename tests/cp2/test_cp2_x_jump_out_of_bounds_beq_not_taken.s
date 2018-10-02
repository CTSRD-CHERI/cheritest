#-
# Copyright (c) 2018 Alex Richardson
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

# Test that no exception is raised if an not-taken unconditional branch goes
# outside the range of PCC (before the delay slot).
.macro branch_out_of_bounds bad_addr_gpr
	cgetpcc	$c12
	cgetpcc	$c13
	ceq	$t0, $c12, $c13	# always 0, but QEMU can't optimize this
	li	$t1, 1
	beq	$t0, $t1, out_of_bounds
	nop
	# cause a tag violation instead of the length violation to check that
	# we didn't use the out-of-bounds target in the not-taken branch
	cgetnull	$c13
	csetbounds	$c13, $c13, 0
.endm

.include "tests/cp2/common_code_mips_branch_out_of_bounds.s"
