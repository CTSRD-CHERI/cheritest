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
from beritest_tools import BaseBERITestCase
from beritest_tools import attr


class test_cp2_x_reg0_is_ddc_store_cond(BaseBERITestCase):
    @attr('capabilities')
    def test_num_traps(self):
        self.assertRegisterEqual(self.MIPS.v0, 12, "Expected 12 traps")

    @attr('capabilities')
    def test_null_csdword_tag_violation(self):
        self.assertCp2Fault(self.MIPS.c4, self.MIPS.CapCause.Tag_Violation,
                            cap_reg=4, trap_count=1, msg="load of null should give tag violation")

    @attr('capabilities')
    def test_null_cscap_tag_violation(self):
        self.assertCp2Fault(self.MIPS.c13, self.MIPS.CapCause.Tag_Violation,
                            cap_reg=13, trap_count=10, msg="load of null should give tag violation")

    @attr('capabilities')
    def test_csc_ddc_store_violation(self):
        # the cap data load should use $ddc for reg 0
        self.assertCp2Fault(self.MIPS.c12, self.MIPS.CapCause.Permit_Store_Violation,
                            msg="load of reg0 should use $ddc -> load violation")

    @attr('capabilities')
    def test_csbhwdu_ddc_store_violation(self):
        # $c5 - $c11 contain the MIPS traps
        for i in range(5, 9):
            # all the normal data stores should have caused a tag violation
            self.assertCp2Fault(self.MIPS.cp2[i], self.MIPS.CapCause.Permit_Store_Violation,
                                cap_reg=0, trap_count=i - 3,
                                msg="load of reg0 should use $ddc -> load violation")
        for i in range(9, 12):
            self.assertCompressedTrapInfo(self.MIPS.cp2[i], mips_cause=self.MIPS.Cause.TRAP, trap_count=i - 3)

    @attr('capabilities')
    def test_mips_stores_ddc_store_violation(self):
        # $c14 and $c15 contain the MIPS sc values (no byte variants)
        self.assertCp2Fault(self.MIPS.c14, self.MIPS.CapCause.Permit_Store_Violation,
                            cap_reg=0, trap_count=11,
                            msg="MIPS sc should use $ddc not $cnull -> load violation")
        self.assertCp2Fault(self.MIPS.c15, self.MIPS.CapCause.Permit_Store_Violation,
                            cap_reg=0, trap_count=12,
                            msg="MIPS sc should use $ddc not $cnull -> load violation")

    @attr('capabilities')
    def test_values_not_modified(self):
        self.assertRegisterEqual(self.MIPS.a0, 0x0123456789abcdef)
        self.assertRegisterEqual(self.MIPS.a1, 0x0123456789abcdef)
        self.assertRegisterEqual(self.MIPS.a2, 0x0123456789abcdef)
        self.assertRegisterEqual(self.MIPS.a3, 0x0123456789abcdef)
