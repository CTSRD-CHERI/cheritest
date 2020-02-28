#-
# Copyright (c) 2013 Robert M. Norton
# Copyright (c) 2020 Alex Richardson
# All rights reserved.
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

# Register assignment:
# a0 - desired epc 1
# a1 - actual epc 1
# a2 - desired badvaddr 1
# a3 - actual badvaddr 1
# a4 - cause 1
# s5 - trap info 1
# a5 - desired epc 2
# a6 - actual  epc 2
# a7 - desired badvaddr 2
# s0 - actual  badvaddr 2
# s1 - cause 2
# s6 - trap info 2


@attr('tlb')
class test_tlb_addrerr_load(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 2

    def test_epc1(self):
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a1, "Wrong EPC 1")

    def test_badvaddr1(self):
        self.assertRegisterEqual(self.MIPS.a2, self.MIPS.a3, "Wrong badaddr 1")

    def test_cause1(self):
        self.assertRegisterMaskEqual(self.MIPS.a4, 0xff, 0x10, "Wrong cause 1")

    def test_trap_info_1(self):
        self.assertCompressedTrapInfo(self.MIPS.s5, mips_cause=self.MIPS.Cause.AdEL, trap_count=1,
                                      msg="Expected address error on load fault")

    def test_epc2(self):
        self.assertRegisterEqual(self.MIPS.a5, self.MIPS.a6, "Wrong EPC 2")

    def test_badvaddr2(self):
        self.assertRegisterEqual(self.MIPS.a7, self.MIPS.s0, "Wrong badaddr 2")

    def test_cause2(self):
        self.assertRegisterMaskEqual(self.MIPS.s1, 0xff, 0x10, "Wrong cause 2")

    def test_trap_info_2(self):
        self.assertCompressedTrapInfo(self.MIPS.s6, mips_cause=self.MIPS.Cause.AdEL, trap_count=2,
                                      msg="Expected address error on load fault")
