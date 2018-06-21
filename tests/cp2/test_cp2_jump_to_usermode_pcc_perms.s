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
# Test that jumping to usermode doesn't clear Access_System_Registers permission
#

BEGIN_TEST
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

	# Restore access system registers
	dla $t9, with_access_sys_regs
	csetoffset $c12, $c13, $t9
	cjr $c12
	nop
with_access_sys_regs:
	cgetpcc $c15
	csetoffset $c15, $c15, $zero	# set offset to 0 to simplify checks

	jump_to_usermode userspace_test
END_TEST


# ensure that the userspace test code is page aligned so that it fits on one page
.balign 4096
.ent userspace_test
userspace_test:
	cgetpcc $c16			# Ensure we have access system registers permission
	csetoffset $c16, $c16, $zero	# set offset to 0 to simplify checks
	nop
	nop
	nop
	# Trigger a syscall to exit the test
	EXIT_TEST_WITH_COUNTING_CHERI_TRAP_HANDLER
.end userspace_test

