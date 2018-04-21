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

.include "macros.s"

#
# Test for 'HI' and 'LO' registers used with integer multiply and divide.  The
# goal of this test is to make sure that data flow in and out of the registers
# is working as intended, not to fully exercise multiply or divide.
#

BEGIN_TEST
		#
		# Check that we can load values into, and extract values out
		# of HI and LO for context switching purposes.
		#
		dli	$t0, 0xe624379d7daf6318
		mthi	$t0
		dli	$t1, 0x608467ffc8a78552
		mtlo	$t1

		# Mandated double-nop between reads and writes
		nop
		nop

		mfhi	$a2
		mflo	$a3

		#
		# Do a single multiply operation.  We are interested only in
		# whether an answer pops out in the registers.
		#
		dli	$t0, 0x4c1de53737a475d3
		dli	$t1, 0x0ed59e2102fc6a4e
		dmult	$t0, $t1

		# Mandated double-nop between reads and writes
		nop
		nop

		mfhi	$a4
		mflo	$a5

		#
		# And likewise, a single divide operation.
		#
		# XXXRW: SDE as for MIPS insists on including break/trap code
		# for divide by zero when ddiv is used.  It would be nice to
		# turn that off.  Until we figure out how, the .noat above
		# will cause this ddiv instruction to generate a warning.
		#
		dli	$t0, 0x5568a2865eb2ee3e
		dli	$t1, 0x2ac0abc68a41800e
		ddiv	$t0, $t1

		# Mandated double-nop between reads and writes
		nop
		nop

		mfhi	$a6
		mflo	$a7

END_TEST
