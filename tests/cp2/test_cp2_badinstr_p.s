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
#

.include "macros.s"

#
# Check that the BadInstrP register is updated for CHERI instructions.
# This is a regression test for QEMU where it was only updated for MIPS instructions
#
BEGIN_TEST
		#
		# Set up exception handler.
		#
		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a1, -1
		dli	$s1, -2
		dli	$a2, -1
		dli	$s2, -2
		dli	$a3, -1
		dli	$s3, -2

		# create a capability that will always trap when used
		cgetnull	$c7


		# First branch not taken:
		li	$a1, 1
		cbnz	$c7, btarget # branch not taken:
		csetbounds	$c1, $c7, $t0 # trap in branch delay slot
		nop
		nop
		nop
btarget:
		move	$s1, $a1
		move	$s2, $a2
		move	$s3, $a3
		move	$s4, $a4
		move	$s5, $a5


		# Now try with branch taken
		cbtu	$c7, return # branch taken:
		csetbounds	$c1, $c7, $t1 # trap in branch delay slot
		nop
		nop
return:

		# load config3 register
		dmfc0	$t1, $16, 3
END_TEST

.ent bev0_handler
bev0_handler:
		li	$v1, 42
		dmfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 8	# EPC += 8 to bump PC forward on ERET (into the nop)
		dmtc0	$k0, $14
		dmfc0	$a1, $8, 1	# BadInstr register
		mfc0	$a2, $8, 1	# BadInstr register (mfc)
		dmfc0	$a3, $8, 2	# BadInstrP register
		mfc0	$a4, $8, 2	# BadInstrP register (mfc)
		dmfc0	$a5, $13	# Cause register
		ssnop			# NOPs to avoid hazard with ERET
		ssnop			# XXXRW: How many are actually
		ssnop			# required here?
		ssnop
		eret
.end bev0_handler
