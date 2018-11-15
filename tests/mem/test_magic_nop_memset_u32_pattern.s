#-
# Copyright (c) 2018 Alex Richardson
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
# Test the QEMU magic nop instruction
#

BEGIN_TEST
		dla	$t0, begin_data
		lbu	$s0, 0($t0)
		dla	$t0, end_data
		lbu	$s1, -1($t0)
		# call qemu_memset()
		dli	$v1, 8		# selector for QEMU magic function
		dli	$v0, 0		# to check return value
		dla	$a0, begin_data	# dest = begin_data
		dli	$a1, 0xdeadc0de	# fill with 0xdeadc0de
		dli	$a2, (4096 - 4) / 4	# all but the last word
		ori	$zero, $zero, 0xC0DE	# call the magic helper

		move	$a4, $a0	# check that a0 wasn't changed
		move	$s2, $v0	# check return value
		move	$s3, $v1	# should be changed to 0xdec0ded by the helper
		dla	$a5, end_data
		dla	$a6, begin_data
		lwu	$s4, 0($a6)	# load first wrod after memset
		lwu	$s5, -8($a5)	# check that the second to last word changed
		lwu	$s6, -4($a5)	# but the last and the one after didn't
		lwu	$s7, 0($a5)	# also check first word
END_TEST

	.data
	.balign 4096
	.8byte 8	# ensure it crosses a 4k boundary
begin_data:
	.fill 4096, 1, 0xaa
end_data:
	# This should not be changed
	.4byte 0xffeeddcc

