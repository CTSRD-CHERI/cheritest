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
.set noreorder
.set nomacro
.include "macros.s"
#
# Check a basic loop works as expected (and statcounters icount is valid)
#

		.global start
		.ent start
start:
		# Initial icount:
		rdhwr	$s0, $4

		# icount after one instr (should be s0+1):
		rdhwr	$s1, $4

		# Run a loop three times
		li	$t0, 2
.Lloop:
		bgt	$t0, $zero, .Lloop
		daddiu	$t0, $t0, -1

		# icount after three loop interations (should be s0+2+(3*2)):
		rdhwr	$s2, $4


		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		# Dump capability registers in the simulator
		mtc2 $v0, $0, 6
		nop

		# Terminate the simulator
		mtc0 $v0, $23
		.end start
end:
		b end
		nop
