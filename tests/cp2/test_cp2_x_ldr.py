#-
# Copyright (c) 2018 Alex Richardson
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer
# Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
# project, funded by EPSRC grant EP/K008528/1.
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

from beritest_tools import BaseBERITestCase, xfail_on
from beritest_tools import attr

@attr("capabilities")
class test_cp2_x_ldr(BaseBERITestCase):
    def test_offset_0(self):
        self.assertTrapInfoNoTrap(self.MIPS.s0, msg="First swr should succeed")

    def test_offset_1(self):
        self.assertTrapInfoNoTrap(self.MIPS.s1, msg="Second swr should succeed")

    def test_offset_2(self):
        self.assertCp2Fault(self.MIPS.s2, cap_cause=self.MIPS.CapCause.Length_Violation, cap_reg=0, trap_count=1)

    def test_offset_3(self):
        self.assertCp2Fault(self.MIPS.s3, cap_cause=self.MIPS.CapCause.Length_Violation, cap_reg=0, trap_count=2)

    def test_offset_4(self):
        self.assertCp2Fault(self.MIPS.s4, cap_cause=self.MIPS.CapCause.Length_Violation, cap_reg=0, trap_count=3)

    def test_offset_5(self):
        self.assertCp2Fault(self.MIPS.s5, cap_cause=self.MIPS.CapCause.Length_Violation, cap_reg=0, trap_count=4)

    def test_offset_6(self):
        self.assertCp2Fault(self.MIPS.s6, cap_cause=self.MIPS.CapCause.Length_Violation, cap_reg=0, trap_count=5)

    def test_offset_7(self):
        self.assertCp2Fault(self.MIPS.s7, cap_cause=self.MIPS.CapCause.Length_Violation, cap_reg=0, trap_count=6)

    def test_trap_count(self):
        self.assertRegisterEqual(self.MIPS.v0, 6, "Expected 6 traps")
