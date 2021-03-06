#-
# Copyright (c) 2015 Michael Roe
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
# Test the LWR instruction with addresses at different alignments.
#

BEGIN_TEST
		dli	$a5, 0

		dla	$t0, data
		dli	$t1, -1
		daddiu	$a0, $t1, 0
		lwr	$a0, 0($t0)
		daddiu	$a1, $t1, 0
		lwr	$a1, 1($t0)
		daddiu	$a2, $t1, 0
		lwr	$a2, 2($t0)
		daddiu	$a3, $t1, 0
		lwr	$a3, 3($t0)

		#
		# LWR at offsets 4 .. 7 should give the same result as for
		# offsets 0 .. 3, but it exercizes different code paths in
		# the L3 formal model because the memory is modelled as
		# 64-bit dwords. It might exercize different code paths in
		# a hardware implementation, too.
		#

                daddiu  $a4, $t1, 0
		lwr     $a4, 4($t0)
		bne     $a4, $a0, fail
		nop     # branch delay slot

                daddiu  $a4, $t1, 0
		lwr     $a4, 5($t0)
		bne     $a4, $a1, fail
		nop     # branch delay slot

                daddiu  $a4, $t1, 0
		lwr     $a4, 6($t0)
		bne     $a4, $a2, fail
		nop     # branch delay slot

                daddiu  $a4, $t1, 0
		lwr     $a4, 7($t0)
		bne     $a4, $a3, fail
		nop     # branch delay slot

		b	pass
		nop

fail:		
		dli	$a5, 1
pass:
END_TEST

		.data
		.align 3
data:		.word 0x01020304
		.word 0x01020304
