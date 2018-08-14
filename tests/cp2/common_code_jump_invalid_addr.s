#-
# Copyright (c) 2018 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
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

# must define the invalid_address_pcc_setup macro

#
# Check that the badinstr register is implemented
#

BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER
		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a1, -1
		dli	$a2, -1
		dli	$a3, -1
		dli	$a4, -1
		cgetnull $c1
		cgetpcc $c25	# save full permissions cap for returning
		dla	$k0, return
		csetoffset	$c25, $c25, $k0

		jump_to_usermode testcode
		nop
return:
		nop
		nop
END_TEST

# TODO: add a variant of this without restricted pcc

.balign 4096	# ensure all the userspace testcode is on one page
testcode:
		invalid_address_pcc_setup $c3	# defined in the individual tests
		cincoffset $c3, $c3, 40		#  should jump to one of the nops
		cjr $c3
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		b .Lprepare_jump
		nop
		# Add some padding to avoid jumping too far
		teq $zero, $zero
		teq $zero, $zero
		teq $zero, $zero
		teq $zero, $zero
		teq $zero, $zero
		# jump here:
.Lprepare_jump:
		dli	$t9, BAD_ADDR

.balign 0x80	# ensure that the jr is at address 0x80 (will be padded with nops)
		jr	$t9
		cgetpcc $c3
		syscall # in case we didn't trap

.global default_trap_handler
.ent default_trap_handler
default_trap_handler:
		li	$v1, 42
		dmfc0	$a4, $14	# EPC
		cgetepcc	$c1
		dmtc0	$k0, $14	# EPC = return
		dmfc0	$a1, $8, 1	# BadInstr register
		dmfc0	$a2, $8, 2	# BadInstrP register
		dmfc0	$a3, $13	# Cause register
		cgetcause	$a5

		cjr	$c25	# jump to end of test


.end default_trap_handler
