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
# Test the QEMU magic nop instruction (in case the TLB translation fails
#

BEGIN_TEST trap_count_reg=$a7
		# TODO: this test should really check for the case where the first
		#       page is present in the TLB and we get a miss half-way through
		# For now using an invalid virtual address should also be fine.


		dli	$v1, 1 		# selector for QEMU magic function
		dli	$v0, 0		# to check return value (required by the function)
		# Check that a TLB miss due to a bad address returns sensible values
		dla	$a0, 0x0001000000100000	# dest = bad (too many virtual address bits used)
		# Check that loading the address traps
		check_instruction_traps $s0, sb	$zero, 0($a0)
		dli	$a1, 0x12	# fill with 0x12
		dli	$a2, 4095
		# Check that the magic nop crashes
		dli	$v0, 0	# return register must be zero on entry
		check_instruction_traps $s1, ori	$zero, $zero, 0xC0DE	# call the magic helper

		# save the register values used by the magic nop
		move	$s2, $v0
		move	$s3, $v1
		move	$s4, $a0
		move	$s5, $a1
		move	$s6, $a2

		# now pretend we are continuing
		nop
		nop
		dli	$a0, 0x0001000000100001	# pretend we were able to write one byte
		dli	$a2, 4094
		check_instruction_traps $s7, ori	$zero, $zero, 0xC0DE	# call the magic helper
		nop
		nop
		move	$a5, $v0
		move	$a6, $v1
END_TEST
