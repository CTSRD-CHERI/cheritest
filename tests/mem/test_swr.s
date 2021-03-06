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
# Test the SWR instruction for addresses with different alignments.
#

BEGIN_TEST
		dli	$a5, 0

		dla	$t0, data
		lui	$t1, 0x0102
		ori	$t1, $t1, 0x0304

		sw	$zero, 0($t0)
		swr	$t1, 0($t0)
		lw	$a0, 0($t0)

		sw	$zero, 0($t0)	# address for SW must be aligned
		swr	$t1, 1($t0)
		lw	$a1, 0($t0)	# address for LW must be aligned

		sw	$zero, 0($t0)
		swr	$t1, 2($t0)
		lw	$a2, 0($t0)

		sw	$zero, 0($t0)
		swr	$t1, 3($t0)
		lw	$a3, 0($t0)

		sw	$zero, 4($t0)
		swr	$t1, 4($t0)
		lw	$a4, 4($t0)
		bne	$a0, $a4, fail
		nop

		sw	$zero, 4($t0)
		swr	$t1, 5($t0)
		lw	$a4, 4($t0)
		bne	$a1, $a4, fail
		nop

		sw	$zero, 4($t0)
		swr	$t1, 6($t0)
		lw	$a4, 4($t0)
		bne	$a2, $a4, fail
		nop

		sw	$zero, 4($t0)
		swr	$t1, 7($t0)
		lw	$a4, 4($t0)
		bne	$a3, $a4, fail
		nop

		b	pass
		nop
fail:

		dli	$a5, 1
pass:
END_TEST

		.data
		.align 3
data:		.word 0
		.word 0
