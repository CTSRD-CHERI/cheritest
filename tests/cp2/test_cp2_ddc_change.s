#-
# Copyright (c) 2020 Alex Richardson
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

BEGIN_TEST
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $a4, 0
	dla $t0, obj
	cgetdefault $c1
	# Full addr-space $ddc with address set in $c2
	csetaddr $c2, $c1, $t0

	csetdefault $c2
	check_instruction_traps $s1, lhu $a1, 0($zero)	# Should not trap and load 0x1234
	nop

	# Should return here from trap handler
	csetbounds $c3, $c2, 2	# 2 bytes
	csetdefault $c3
	check_instruction_traps $s2, lhu $a2, 0($zero)	# Should not trap

	csetbounds $c3, $c2, 1	# 1 bytes
	csetdefault $c3
	check_instruction_traps $s3, lhu $a3, 0($zero)	# Should trap and not load

	csetdefault $cnull
	check_instruction_traps $s4, lhu $a4, 0($zero)	# Should trap and not load


	# Restore $ddc so we can return
	csetdefault $c1
END_TEST

.data
obj:
.2byte 0x1234
