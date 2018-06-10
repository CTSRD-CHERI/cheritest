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
# Test that CReadHwr raises an exception if we don't have the required perms to
# access the kernel-only registers.
#

.macro try_write_cap_hwreg cap_hwreg_number, cause_capreg
	clear_counting_exception_handler_regs
	CWriteHwr $c1, \cap_hwreg_number
	# Save exception details in cause_capreg
	save_counting_exception_handler_cause \cause_capreg
.endm

BEGIN_TEST_WITH_COUNTING_TRAP_HANDLER
	# Set the offset field in the special registers so that we can verify
	# they didn't change
	# Note: we can't just clear them, since KCC is needed in the exception
	# handler to derive PCC
	SetCapHwrOffset kr1c, 22
	SetCapHwrOffset kr2c, 23
	SetCapHwrOffset kcc, 29
	SetCapHwrOffset kdc, 30
	SetCapHwrOffset epcc, 31
	cgetnull $c27	# clear $c27 to check that it is not mirrored to hwr 22
	cgetnull $c28	# clear $c28 to check that it is not mirrored to hwr 23

	# Clear the registers set by the counting trap handler
	clear_counting_exception_handler_regs

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

	CFromIntImm $c1, 0xbad1	# Writing value from kernel mode without access sysregs


	# Try to write EPCC (should fail - trap #1). Save exception details in $c2
	try_write_cap_hwreg $31, $c2
	# Try to write KDC (should fail - trap #2). Save exception details in $c3
	try_write_cap_hwreg $30, $c3
	# Try to write KCC (should fail - trap #3). Save exception details in $c4
	try_write_cap_hwreg $29, $c4

	# KR1C and KR2Cshould work
	try_write_cap_hwreg $22, $c5	# Write KR1C
	try_write_cap_hwreg $23, $c6	# Write KR2C

	# Try to write a non-existent kernel special capreg (trap #4)
	# Should fail with reserved instr
	try_write_cap_hwreg $28, $c7

	# Now try accessing the registers from user mode.

	# First we need to restore access system registers
	dla $t9, with_access_sys_regs
	csetoffset $c12, $c13, $t9
	cjr $c12
	nop
with_access_sys_regs:
	cgetpcc $c25
	csetoffset $c25, $c25, $zero	# set offset to 0 to simplify checks
	# Ensure that EPCC has sysregs even if we trapped without access_sysregs
	csetepcc $c25
	jump_to_usermode userspace_test
END_TEST


# ensure that the userspace test code is page aligned so that it fits on one page
.balign 4096
.ent userspace_test
userspace_test:
	# Ensure we have access system registers permission
	cgetpcc $c26
	csetoffset $c26, $c26, $zero	# set offset to 0 to simplify checks


	# Current trap count should be 4
	# Last registers used to store exception details was $c7
	# c11-c14 are used so we can save in $c8-c10 and $c15-$c25
	# In case I add more kernel mode tests start from $c15 here
	CFromIntImm $c1, 0xbad2	# Writing value from user mode

	# Try to write EPCC (should fail - trap #5).
	try_write_cap_hwreg $31, $c15
	# Try to write KDC (should fail - trap #6)
	try_write_cap_hwreg $30, $c16
	# Try to write KCC (should fail - trap #7)
	try_write_cap_hwreg $29, $c17

	# KR1C and KR2Cshould not work!
	try_write_cap_hwreg $22, $c18	# Write KR1C (trap #8)
	try_write_cap_hwreg $23, $c19	# Write KR2C (trap #9)

	# Try to read a non-existent kernel special capreg (trap #10)
	# Should fail with reserved instr
	try_write_cap_hwreg $28, $c20

	# TODO: should I also check this without PCC.access_sys_regs here?

	nop
	nop
	nop
	# Trigger a syscall to exit the test
	EXIT_TEST_WITH_COUNTING_CHERI_TRAP_HANDLER
.end userspace_test

