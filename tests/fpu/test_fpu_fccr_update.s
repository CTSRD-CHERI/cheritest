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
# Test that an update of a floating point condition code by a comparison
# instruction leaves the other floating point condition codes unchanged.
#

BEGIN_TEST
		mfc0 $at, $12
		dli $t1, 1 << 29	# Enable CP1
		or $at, $at, $t1
		dli $t1, 1 << 26	# Put FPU into 64 bit mode
		or $at, $at, $t1
		mtc0 $at, $12 

		#
		# Clear the floating point condition codes
		#

		lui	$t0, 0xfe80
		nor	$t0, $t0, $t0
		cfc1	$t1, $31
		and	$t1, $t1, $t0
		ctc1	$t1, $31

		#
		# Set condition codes and read them back through FCSR
		#

		mtc1	$zero, $f0
		c.eq.s	$fcc0, $f0, $f0
		cfc1	$a0, $31
		c.eq.s	$fcc1, $f0, $f0
		cfc1	$a1, $31
		c.eq.s	$fcc2, $f0, $f0
		cfc1	$a2, $31

END_TEST
