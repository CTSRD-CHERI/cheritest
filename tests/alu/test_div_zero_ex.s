#-
# Copyright (c) 2018 (holder)
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
# Test division by zero.
#
# In the MIPS ISA, this is an unpredictable value, not unpredictable behaviour.
# While test_div_zero follows a common compiler idiom of dividing by zero
# and then not looking at the result, this test copies the unpredictable
# value into a general purpose register.
#
# There is a separate divide by zero test for each division instruction,
# rather than combining them all into one test, because the unpredictable
# value may cause a simulator to halt.
#

BEGIN_TEST
		dli	$a0, 1
		dli	$a1, 1

		dli	$t0, 0 
		dli	$t1, 0
		div	$zero, $t0, $t1
		mfhi	$a0
		mflo	$a1
	
END_TEST
