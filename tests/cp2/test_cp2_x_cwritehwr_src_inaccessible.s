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

#
# Test that CReadHwr raises an exception if the destination register is not accessible.
#

BEGIN_TEST_WITH_COUNTING_TRAP_HANDLER

	# Set the offset field in the special registers so that we can verify
	# they didn't change
	# Note: we can't just clear them, since KCC is needed in the exception
	# handler to derive PCC
	SetSpecialRegOffset KR1C, 27
	SetSpecialRegOffset KR2C, 28
	SetSpecialRegOffset KCC, 29
	SetSpecialRegOffset KDC, 30
	SetSpecialRegOffset EPCC, 31

	# The base MIPS trap handler relies on a zero-vaddr $ddc
	SetSpecialRegOffset Default, 0x0

	# remove Access_System_Registers
	dla $t9, without_access_sys_regs
	cgetpccsetoffset $c12, $t9
	dli $t0, ~__CHERI_CAP_PERMISSION_ACCESS_SYSTEM_REGISTERS__
	candperm $c12, $c12, $t0
	cgetpcc $c13 	# store old pcc in $c12
	cjr $c12
	csetoffset $c13, $c13, $zero	# set offset to 0 to simplify checks
without_access_sys_regs:
	cgetpcc $c14	# Check that $pcc doesn't have access system registers
	csetoffset $c14, $c14, $zero	# set offset to 0 to simplify checks

# Verify that we check for Access_sysregs on the GPR
.macro try_write_from_cap_gpr_to_hwr0 gpr, cause_capreg
	clear_counting_exception_handler_regs
	CWriteHwr \gpr, $0
	# Save exception details in cause_capreg
	save_counting_exception_handler_cause \cause_capreg
.endm
	# Try to write into EPCC (should fail - trap #1). Save exception details in $c2
	try_write_from_cap_gpr_to_hwr0 $c31, $c2
	# Try to write KDC (should fail - trap #2). Save exception details in $c3
	try_write_from_cap_gpr_to_hwr0 $c30, $c3
	# Try to write KCC (should fail - trap #3). Save exception details in $c4
	try_write_from_cap_gpr_to_hwr0 $c29, $c4
	# KR1C and KR2C should also not be permitted work
	try_write_from_cap_gpr_to_hwr0 $c28, $c5	# write into KR2C (trap #4)
	try_write_from_cap_gpr_to_hwr0 $c27, $c6	# write into KR1C (trap #5)

	# But writing from $c26 is fine
	try_write_from_cap_gpr_to_hwr0 $c26, $c7
	# same with $ddc
	try_write_from_cap_gpr_to_hwr0 $c0, $c8

last_trap:
	teq $zero, $zero	# trap #6
	dla $a7, last_trap	# load the address of the last trap inst to verify EPCC
END_TEST
