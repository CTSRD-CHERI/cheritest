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

# Test that an exception is before executing the instruction after then end of $pcc
.macro branch_out_of_bounds bad_addr_gpr
	cgetpcc	$c12
	cincoffset $c12, $c12, 20	# getpcc + 4
	csetbounds $c12, $c12, 8	# getpcc + 8
	cjr	$c12			# getpcc + 12
	li	$a7, 1		# getpcc + 16
	nop				# getpcc + 20
	li	$a7, 0xf00d		# getpcc + 24
	# should trap now due to pcc bounds
.endm

.include "tests/cp2/common_code_mips_branch_out_of_bounds.s"
