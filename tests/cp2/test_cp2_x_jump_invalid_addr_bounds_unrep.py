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

#
# Test that EPC and EPCC are still in sync after a jump to a bad instruction
#

@attr('capabilities')
class test_cp2_x_jump_invalid_addr_bounds_unrep(BaseBERITestCase):
    @attr('cap_precise')
    def test_epc_precise(self):
        self.assertRegisterEqual(self.MIPS.a4, 0x12345678, "epc is wrong (should be address of the jr)")

    @attr('cap_precise')
    def test_epcc_precise(self):
        self.assertValidCap(self.MIPS.c1, base=0, length=0x300, offset=0x12345678, perms=self.max_permissions, msg="EPCC is wrong (should be address of the jr)")

    @attr('cap_precise')
    def test_cause_precise(self):
        # Should get a tlb miss
        self.assertRegisterMaskEqual(self.MIPS.a3, 1 << 31, 0, "BD bit should not be set")
        self.assertRegisterMaskEqual(self.MIPS.a3 >> 2, 0x1f, self.MIPS.Cause.TLB_Load.value, "expected a TLB fault")
        self.assertRegisterEqual(self.MIPS.a5, 0, "CapCause should be 0x0")

    @attr('cap_imprecise')
    def test_epcc_imprecise(self):
        self.assertValidCap(self.MIPS.c1, base=0, length=0x300, offset=0x80, perms=self.max_permissions, msg="EPCC is wrong (should be address of the jr)")

    @attr('cap_imprecise')
    def test_epc_imprecise(self):
        self.assertRegisterEqual(self.MIPS.a4, 0x80, "epc is wrong (should be address of the jr)")

    @attr('cap_imprecise')
    def test_cause_imprecise(self):
        self.assertRegisterMaskEqual(self.MIPS.a3, 1 << 31, 0, "BD bit should not be set")
        self.assertRegisterMaskEqual(self.MIPS.a5, 0xff, 0xff, "register should be 0xff")
