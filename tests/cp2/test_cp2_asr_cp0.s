#-
# Copyright (c) 2019 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory (Department of Computer Science and
# Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
# DARPA SSITH research programme.
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

#
# Test that jumping to usermode doesn't clear Access_System_Registers permission
#
BEGIN_TEST
	# clear all registers used for testing
	dli $a0, -1
	dli $a1, -1
	dli $a2, -1
	dli $a3, -1
	dli $a4, -1
	dli $a5, -1
	cgetnull $c1
	cgetnull $c2
	cgetnull $c3
	cgetnull $c10
	cgetnull $c11
with_access_sys_regs:
	cgetpcc $c1	# initial pcc in $c1
	# These two instructions should succeed:
	check_instruction_traps $s0, dmfc0 $a0, $15		# PrId
	check_instruction_traps $s1, tlbwi	# Write Indexed TLB Entry
	# Now remove ASR and try again (in kernel mode)
	remove_pcc_perms_jump $c12, __CHERI_CAP_PERMISSION_ACCESS_SYSTEM_REGISTERS__, without_access_sys_regs
without_access_sys_regs:
	cgetpcc $c2	# Check that $pcc doesn't have access system registers
	# These two should fail
	check_instruction_traps $s2, dmfc0 $a1, $15		# PrId (trap #1)
	check_instruction_traps $s3, tlbwi	# Write Indexed TLB Entry (trap #2)
	# restore ASR:
	dla $t0, with_access_sys_regs_again
	csetaddr $c12, $c1, $t0
	cjalr $c12, $cnull
	nop
with_access_sys_regs_again:
	cgetpcc $c3
	csetepcc $c3	# set an EPCC with ASR so that userspace gets ASR
	check_instruction_traps $a5, dmfc0 $a4, $15		# PrId
	jump_to_usermode userspace_test
END_TEST


# ensure that the userspace test code is page aligned and on an even page
.balign 8192
.ent userspace_test
userspace_test:
.Luserspace_getpcc:
	cgetpcc $c10			# Ensure we have access system registers permission in userspace
userspace_with_asr:
	check_instruction_traps $s4, dmfc0 $a2, $15		# PrId (trap #3)
	check_instruction_traps $s5, tlbwi	# Write Indexed TLB Entry (trap #4)
	# Now remove ASR and try again (in kernel mode)
	# can't use absolute addresses in userspace (since we are relative to address 0) -> use a relative cincoffset
	dla $t0, (.Luserspace_without_access_sys_regs - .Luserspace_getpcc)
	cincoffset $c12, $c10, $t0
	remove_cap_perms $c12, __CHERI_CAP_PERMISSION_ACCESS_SYSTEM_REGISTERS__
	cjr $c12
	nop
.Luserspace_without_access_sys_regs:
	cgetpcc $c11			# Ensure access system registers permission was removed
	check_instruction_traps $s6, dmfc0 $a3, $15		# PrId (trap #5)
	check_instruction_traps $s7, tlbwi	# Write Indexed TLB Entry (trap #6)

	EXIT_TEST_WITH_COUNTING_CHERI_TRAP_HANDLER
.end userspace_test

