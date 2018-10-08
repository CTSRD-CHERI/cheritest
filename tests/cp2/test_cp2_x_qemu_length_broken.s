#-
# Copyright (c) 2018 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
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

.include "macros.s"
.set mips64
.set noreorder
.set nobopt
.set noat

#
# QEMU 128 would make accessing the last few bytes of an allocation cause a
# length violation due to wrong rounding down if the size was sufficiently
# large (e.g. for 0x10000000 at least the last 7 bytes are not addressable if
# we do an incoffset by 7. for 0x1000000 it is up to the last 3 bytes
#

BEGIN_TEST
	cgetdefault $c1
	cincoffset $c2, $c1, 3
	dli $a0, 0x1000000
	csetbounds $c2, $c2, $a0
	# All of these should generate a TLB exception but on QEMU128 it used to
	# generate a length violation instead
	check_instruction_traps_info_in_creg $c5, clb $t1, $zero, 0($c2)	# TLB trap #1

	check_instruction_traps_info_in_creg $c6, clb $t1, $a0, -1($c2)		# TLB trap #2

	check_instruction_traps_info_in_creg $c7, clb $t1, $a0, -2($c2)		# TLB trap #3

	check_instruction_traps_info_in_creg $c8, clb $t1, $a0, -3($c2)		# TLB trap #4

	check_instruction_traps_info_in_creg $c9, clb $t1, $a0, -4($c2)		# TLB trap #5

	# If use bounds 0x10000000 and we inc by 7 we use to no longer be able
	# to access the last 7 entries:
	cincoffset $c3, $c1, 7
	dli $a0, 0x10000000
	csetbounds $c3, $c3, $a0
	#clb $a1, $zero, 0($c2)
	# clb $a3, $a0, -1($c2)

	check_instruction_traps_info_in_creg $c10, clb $t1, $a0, -7($c3)	# TLB trap #6

	check_instruction_traps_info_in_creg $c11, clb $t1, $a0, -8($c3)	# TLB trap #7

	check_instruction_traps_info_in_creg $c12, clb $t1, $zero, 0($c3)	# TLB trap #8
END_TEST

