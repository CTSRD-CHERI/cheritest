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
		cgetdefault	$c1
		dli	$t1, 0x1234
		cincoffset $c2, $c1, $t1

		dla	$t0, cap_location
		csetoffset $c3, $c1, $t0	# create cap for cap1_location
		csc	$c2, $zero, 0($c3)
		clc	$c4, $zero, 0($c3)	# load back before memset

		# call qemu_memset()
		dli	$v1, 1		# selector for QEMU magic function
		dli	$v0, 0		# to check return value
		dla	$a0, begin_data	# dest = begin_data
		move	$a6, $a0	# save begin_data in $a6
		dli	$a1, 0x11	# fill with 0x11
		dla	$a2, end_data - begin_data	# whole buffer
		ori	$zero, $zero, 0xC0DE	# call the magic helper

		move	$s2, $v0	# check return value
		move	$s3, $v1	# should be changed to 0xdec0ded by the helper

		clc	$c5, $zero, 0($c3)	# load cap1 after memset

		dla	$a5, end_data
		lbu	$s4, 0($a5)	# load first byte after memset
		lbu	$s5, -1($a5)	# load last byte of memset (should be set)
END_TEST

	.data
	.balign 4096
	.fill 4088, 1, 0xaa
begin_data:
	.8byte 0x1234567887654321
cap_location:
	.chericap 0xabcde	# capability size element
end_data:
	.byte 0xab

