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
@attr('cap_hwregs')
class test_cp2_x_creadhwr_dest_inaccessible(BaseBERITestCase):
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
    # TODO: turn this into a check NULL is not overwritten
    def test_nullreg_target(self):
        self.assertCompressedTrapInfo(self.MIPS.c2,
            mips_cause=self.MIPS.Cause.TRAP,
            trap_count=1, msg="Accessing EPCC should fail")
        self.assertDefaultCap(self.MIPS.c31, offset=self.MIPS.a7,
            perms=self.max_permissions & ~1024, msg="EPCC should be at last trap")

    def test_no_sysregs_in_kernel_mode_kdc(self):
        self.assertCompressedTrapInfo(self.MIPS.c3,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=30, trap_count=2, msg="Accessing KDC should fail")
        self.assertIntCap(self.MIPS.kdc, int_value=30, msg="Should still hold initial value")

    def test_no_sysregs_in_kernel_mode_kcc(self):
        self.assertCompressedTrapInfo(self.MIPS.c4,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=29, trap_count=3, msg="Accessing KCC should fail")
        self.assertDefaultCap(self.MIPS.kcc, offset=29, msg="Should still hold initial value")

    def test_no_sysregs_in_kernel_mode_kr2c(self):
        self.assertCompressedTrapInfo(self.MIPS.c5,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=28, trap_count=4, msg="Accessing KR2C should fail")
        self.assertIntCap(self.MIPS.cp2_hwregs[23], int_value=23, msg="Should still hold initial value")
        self.assertNullCap(self.MIPS.c28, msg="kr2c should not be mirrrored to $c28")

    def test_no_sysregs_in_kernel_mode_kr1c(self):
        self.assertCompressedTrapInfo(self.MIPS.c6,
            mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation,
            cap_reg=27, trap_count=5, msg="Accessing KR2C should fail")
        self.assertIntCap(self.MIPS.cp2_hwregs[22], int_value=22, msg="Should still hold initial value")
        self.assertNullCap(self.MIPS.c27, msg="kr1c should not be mirrrored to $c27")

    def test_no_sysregs_in_kernel_mode_dest_idc(self):
        self.assertCompressedTrapInfo(self.MIPS.c7, no_trap=True, msg="Accessing IDC should work")
        self.assertDefaultCap(self.MIPS.c26, offset=0)

    def test_no_sysregs_in_kernel_mode_dest_ddc(self):
        self.assertCompressedTrapInfo(self.MIPS.c8, no_trap=True, msg="Accessing DDC should work")
        self.assertDefaultCap(self.MIPS.ddc, offset=0)

    def test_total_exception_count(self):
        self.assertRegisterEqual(self.MIPS.v0, 6, "Wrong number of exceptions triggered")

