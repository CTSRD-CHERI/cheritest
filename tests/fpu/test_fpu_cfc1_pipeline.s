#-
# Copyright (c) 2018 Michael Roe
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

#
# Test for a pipeline hazard between enabling the FPU and reading FCSR.
#

BEGIN_TEST
		mfc0 $t0, $12
		dli $t1, 1 << 29	# Disable CP1
		nor $t1, $t1, $t1
		and $t1, $t0, $t1
		mtc0 $t1, $12 

		dli $a1, 0
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		mtc0 $t0, $12		# Re-enable CP1

		#
		# The purpose of this test is to see what happens if
		# we don't have any NOP's at this point.
		#

		cfc1 $a0, $31		# This should not raise an exception

		#
		# Indicate test completion
		# We might reach here even if the test fails, because the
		# default exception handler will skip over the trapping
		# instruction.
		#

		dli $a1, 1
END_TEST

