#-
# Copyright (c) 2017 Michael Roe
# All rights reserved.
#
# This software was7developed by the University of Cambridge Computer
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
#
# IEEE 754 allows the check for underflow to happen either before or after
# rounding. In this test, we do a multiplication whose exact result is
# subnormal, but which gets rounded up to a normal value.
#

BEGIN_TEST
		#
		# Set the FCSR
		#  - Round upwards
		#  - Disable all floating point exceptions
		#  - Clear the status flags
		#

		dli 	$t0, 0x2
		ctc1	$t0, $31

		nop
		nop
		nop
		nop
		nop

		dli	$t0, 0x10842108421084
		dmtc1	$t0, $f0

		dli	$t0, 0x3fef000000000000
		dmtc1	$t0, $f1

		mul.d	$f0, $f0, $f1
		dmfc1	$a0, $f0

		nop
		nop
		nop
		nop
		nop
		nop
		nop

		#
		# Read the FCSR; the cause bits will indicate if the previous
		# floating point operation underflowed.
		#

		cfc1	$a1, $31

END_TEST
