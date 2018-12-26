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

.macro call_memmove dst, src, len
	dli	$v1, 5		# selector for QEMU magic function
	dli	$v0, 0		# not a continuation (0 bytes copied)
	dla	$a0, \dst
	dla	$a1, \src
	dla	$a2, \len
	ori	$zero, $zero, 0xC0DE	# call the magic helper
.endm

.macro call_memmove_cont dst, src, len, already_copied
	dli	$v1, 5		# selector for QEMU magic function
	dli	$v0, (0xbadc0de << 32) | \already_copied
	dla	$a0, \dst
	dla	$a1, \src
	dla	$a2, \len
	ori	$zero, $zero, 0xC0DE	# call the magic helper
.endm


BEGIN_TEST
		dla	$t0, begin_data
		lbu	$s0, 0($t0)
		dla	$t0, end_data
		lbu	$s1, -1($t0)
		# call qemu_memmove()
		# Same src and destination previously crashed QEMU:
		call_memmove begin_data, begin_data, 1
		call_memmove begin_data, end_data, 0

		li $s0, 0x1122
END_TEST

	.data
	.balign 4096
	.8byte 8	# ensure it crosses a 4k boundary
begin_data:
	.fill 4096, 1, 0xaa
end_data:
	# This should not be changed
	.byte 0xff

