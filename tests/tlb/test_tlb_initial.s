#-
# Copyright (c) 2016 Michael Roe
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
# Read a TLB entry that has not yet been initialized. The result is UNPREDICTABLE
# in the MIPS ISA.
#

BEGIN_TEST
		dli	$a4, 0

		mtc0	$zero, $0	# Index
		tlbr
		mfc0	$a0, $2		# EntryLo0
		mfc0	$a1, $3		# EntryLo1
		mfc0	$a2, $5		# PageMask
		mfc0	$a3, $10	# EntryHi

		#
		# Set $a4 to 1 to show the test ran to completion
		#

		dli	$a4, 1

END_TEST
