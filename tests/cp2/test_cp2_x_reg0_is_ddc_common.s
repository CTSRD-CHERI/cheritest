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

# This file should be .included by test_cp2_x_reg0_is_ddc* with the following
#  macros defined: do_load_store kind, srcreg


BEGIN_TEST_WITH_COUNTING_TRAP_HANDLER
		# Save c0
		cgetdefault   $c1

		# Make $ddc a capability pointing to data without load/store
		dla	$t0, data
		csetoffset $c2, $c2, $t0	# $c2 = data
		dli	$t1, ~CHERI_PERM_STORE
		candperm $c3, $c2, $t1
		dli	$t1, ~CHERI_PERM_LOAD
		candperm $c3, $c3, $t1
		csetdefault $c3			# $c3 = data without load/store

		# Try loading + storing relative to null (should give tag violation)
		cgetnull $c4
		clear_counting_exception_handler_regs
		do_cap_load_store d, $v0, $c4
		save_counting_exception_handler_cause $c4  # trap # 1 tag violation


		# now check that all the capability load/stores die.
		# All these loads/stores should fail with
		# permit_store/permit_load violations and not tag violations

.macro check_cap_ddc_relative_ld_st width, store_cause_reg
	clear_counting_exception_handler_regs
	do_cap_load_store	\width, $t2, $ddc
	save_counting_exception_handler_cause \store_cause_reg
.endm
		check_cap_ddc_relative_ld_st b, $c5	# byte load/store #trap 2
		check_cap_ddc_relative_ld_st h, $c6	# short load/store #trap 3
		check_cap_ddc_relative_ld_st w, $c7	# word load/store #trap 4
		check_cap_ddc_relative_ld_st d, $c8	# dword load/store #trap 5

		# Check the unsigned variants:
.if TESTING_LOAD
		check_cap_ddc_relative_ld_st bu, $c9	# unsigned byte load/store #trap 6
		check_cap_ddc_relative_ld_st hu, $c10	# unsigned short load/store #trap 7
		check_cap_ddc_relative_ld_st wu, $c11	# unsigned word load/store #trap 8
.else
		# just increment trap count to keep load/store in sync
		teq $zero, $zero	# trap 6
		save_counting_exception_handler_cause $c9
		teq $zero, $zero	# trap 7
		save_counting_exception_handler_cause $c10
		teq $zero, $zero	# trap 8
		save_counting_exception_handler_cause $c11
.endif

		# finally cap load/store
		clear_counting_exception_handler_regs
		do_cap_load_store	c, $c3, $ddc	# cap load/store #trap 9
		save_counting_exception_handler_cause $c12

		# cap load/store relative to null should give tag violation
		clear_counting_exception_handler_regs
		cgetnull $c13
		do_cap_load_store	c, $c3, $c13	# null cap load/store #trap 10
		save_counting_exception_handler_cause $c13


		# Now the MIPS loads/stores (should also use $ddc not $cnull)
		dla	$t9, data
.macro check_mips_load_store width, store_cause_reg
	clear_counting_exception_handler_regs
	do_mips_load_store	\width, $t2, $t9
	save_counting_exception_handler_cause \store_cause_reg
.endm

.if TESTING_LLSC
		# MIPS ll/sc only has ll+lld/sc+scd
		check_mips_load_store , $c14	# byte load/store #trap 11
		check_mips_load_store d, $c15	# byte load/store #trap 12
.else
		check_mips_load_store b, $c14	# byte load/store #trap 11
		check_mips_load_store h, $c15	# short load/store #trap 12
		check_mips_load_store w, $c16	# word load/store #trap 13
		check_mips_load_store d, $c17	# dword load/store #trap 14

		# Check the unsigned variants:
.if TESTING_LOAD
		check_mips_load_store bu, $c18	# unsigned byte load/store #trap 15
		check_mips_load_store hu, $c19	# unsigned short load/store #trap 16
		check_mips_load_store wu, $c20	# unsigned word load/store #trap 17
.else
		# just increment trap count to keep load/store in sync
		teq $zero, $zero	# trap 15
		save_counting_exception_handler_cause $c18
		teq $zero, $zero	# trap 16
		save_counting_exception_handler_cause $c19
		teq $zero, $zero	# trap 17
		save_counting_exception_handler_cause $c20
.endif
.endif  # TESTING_LLC

.if TESTING_STORE
		# Check that data is still the same
		cld	$a0, $zero, 0($c2)
		cld	$a1, $zero, 8($c2)
		cld	$a2, $zero, 16($c2)
		cld	$a3, $zero, 24($c2)
.endif
		# set $ddc offset back to zero so that the END_TEST ld ra 8(sp) return works
		csetdefault $c1
END_TEST

		.data
		.balign	64
data:		.dword	0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef
		.dword  0x0123456789abcdef
