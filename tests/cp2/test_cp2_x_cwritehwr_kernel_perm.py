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

from beritest_tools import BaseBERITestCase, xfail_gnu_binutils
from beritest_tools import attr
import copy


#
# Test that creadhwr raises exceptions when the kernel registers are accessed
# without the appropriate permissions
#
@attr('capabilities')
class test_cp2_x_cwritehwr_kernel_perm(BaseBERITestCase):
    def test_pcc_has_no_access_sys_regs(self):
        self.assertCapPermissions(self.MIPS.c14, self.max_permissions & ~1024,
            "$pcc for the test function should not have Access system registers")
        self.assertCapPermissions(self.MIPS.c13, self.max_permissions,
            "$pcc outside the test function should have Access system registers")

        c14_with_access_sys_regs = copy.deepcopy(self.MIPS.c14)
        c14_with_access_sys_regs.perms = self.MIPS.c13.perms
        self.assertCapabilitiesEqual(c14_with_access_sys_regs, self.MIPS.c13,
            "c14 and c13 should be identical except for permissions")

    # Writing EPCC, KDC and KCC should fail
    def test_no_sysregs_in_kernel_mode_epcc(self):
        self.assertCompressedTrapInfo(self.MIPS.c2,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=31, trap_count=1, msg="Accessing EPCC should fail")

    def test_no_sysregs_in_kernel_mode_kdc(self):
        self.assertCompressedTrapInfo(self.MIPS.c3,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=30, trap_count=2, msg="Accessing KDC should fail")

    def test_no_sysregs_in_kernel_mode_kcc(self):
        self.assertCompressedTrapInfo(self.MIPS.c4,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=29, trap_count=3, msg="Accessing KCC should fail")

    # But KR1C and KR2C should be fine
    def test_no_sysregs_in_kernel_mode_kr1c(self):
        self.assertCompressedTrapInfo(self.MIPS.c5,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=22, trap_count=4, msg="Accessing KR1C should fail")

    def test_no_sysregs_in_kernel_mode_kr2c(self):
        self.assertCompressedTrapInfo(self.MIPS.c6,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=23, trap_count=5, msg="Accessing KR2C should fail")

    def test_no_sysregs_in_kernel_mode_invalid_reg(self):
        # CapHWR 28 doesn't exist so this should raise reserved instr
        self.assertCompressedTrapInfo(self.MIPS.c7,
            mips_cause=self.MIPS.Cause.ReservedInstruction,
            trap_count=6, msg="Accessing invalid reg should fail")

    # In user mode none of the registers should be accessible
    def test_usermode_pcc_no_access_sys_regs(self):
        self.assertCapPermissions(self.MIPS.c25, self.max_permissions,
            "$pcc before usermode should have access sys regs")
        self.assertCapPermissions(self.MIPS.c26, self.max_permissions,
            "$pcc in usermode should have access sys regs")

    def test_user_mode_epcc(self):
        self.assertCompressedTrapInfo(self.MIPS.c15,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=31, trap_count=7, msg="Accessing EPCC should fail")

    def test_user_mode_kdc(self):
        self.assertCompressedTrapInfo(self.MIPS.c16,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=30, trap_count=8, msg="Accessing KDC should fail")

    def test_user_mode_kcc(self):
        self.assertCompressedTrapInfo(self.MIPS.c17,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=29, trap_count=9, msg="Accessing KCC should fail")

    def test_user_mode_kr1c(self):
        self.assertCompressedTrapInfo(self.MIPS.c18,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=22, trap_count=10, msg="Accessing KR1C should fail")

    def test_user_mode_kr2c(self):
        self.assertCompressedTrapInfo(self.MIPS.c19,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=23, trap_count=11, msg="Accessing KR2C should fail")

    def test_user_mode_invalid_reg(self):
        # CapHWR 28 doesn't exist so this should raise reserved instr
        self.assertCompressedTrapInfo(self.MIPS.c20,
            mips_cause=self.MIPS.Cause.ReservedInstruction,
            trap_count=12, msg="Accessing invalid reg should fail")

    def test_final_values(self):
        # check that kr1c and kr2c were not updated by the writes to chwr $22 and $23 in kernel mode:
        self.assertNullCap(self.MIPS.c27, msg="kr1c should not mirrored to $c27")
        self.assertNullCap(self.MIPS.c28, msg="kr2c should not mirrored to $c28")
        self.assertIntCap(self.MIPS.cp2_hwregs[22], int_value=22, msg="kr1c should not mirrored to $c27")
        self.assertIntCap(self.MIPS.cp2_hwregs[23], int_value=23, msg="kr2c should not mirrored to $c28")
        # these should not have changed (they are mirrored):
        self.assertDefaultCap(self.MIPS.kcc, offset=29)
        self.assertDefaultCap(self.MIPS.cp2_hwregs[29], offset=29)
        self.assertIntCap(self.MIPS.kdc, int_value=30)
        self.assertIntCap(self.MIPS.cp2_hwregs[30], int_value=30)

    def test_final_eppc(self):
        # EPCC will be somewhere on the first userspace page and will have access_sys_regs
        self.assertValidCap(self.MIPS.epcc, offset=(0x0, 0x2000), base=0,
            length=self.max_length, perms=self.max_permissions)

    def test_total_exception_count(self):
        self.assertRegisterEqual(self.MIPS.v0, 12, "Wrong number of exceptions triggered")

