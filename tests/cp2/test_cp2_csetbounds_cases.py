#-
# Copyright (c) 2015 Michael Roe
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

from beritest_tools import BaseBERITestCase, attr, HexInt

@attr('capabilities')
class test_cp2_csetbounds_cases(BaseBERITestCase):

    def test_cp2_csetbounds_base_or_length_unexpected(self):
        self.assertRegisterEqual(self.MIPS.a0, 0, "One case of CSetBounds did not get an expected value")

    def test_case_one_base(self):
        assert self.MIPS.c5.base == HexInt(0x1600f4000)
        assert self.MIPS.c6.base == HexInt(0x1600f4000 + 0x1ffe0)

    def test_case_one_length(self):
        assert self.MIPS.c5.length == HexInt(0x20000)
        assert self.MIPS.c6.length == HexInt(0x10)


    def test_case_two_base(self):
        assert self.MIPS.c7.base == HexInt(0x7fffffe8c0)
        assert self.MIPS.c8.base == HexInt(0x7fffffe8c0)

    def test_case_two_length(self):
        assert self.MIPS.c7.length == HexInt(0x0)
        assert self.MIPS.c8.length == HexInt(0x0)

    def test_case_three_first_cap(self):
        assert self.MIPS.c9.base == HexInt(0x16022e000)
        assert self.MIPS.c9.length == HexInt(0x400000)
        assert self.MIPS.c9.offset == HexInt(0)
        assert self.MIPS.c9.t

    def test_case_three_second_cap(self):
        assert self.MIPS.c10.base == HexInt(0x16022e000)
        assert self.MIPS.c10.length == HexInt(0x400000)
        assert self.MIPS.c10.offset == HexInt(0x7ee940)
        assert self.MIPS.c10.t

    def test_case_three_third_cap(self):
        assert self.MIPS.c11.base == HexInt(0x16022e000)
        assert self.MIPS.c11.length == HexInt(0x400000)
        assert self.MIPS.c11.offset == HexInt(0x7ee940 - 0xf18)
        assert self.MIPS.c11.t

    def test_case_four_base(self):
        assert self.MIPS.c12.base == HexInt(0x160600000)
        assert self.MIPS.c13.base == HexInt(0x160600000)
        assert self.MIPS.c14.base == HexInt(0x160600000)

    def test_case_four_length(self):
        assert self.MIPS.c12.length == HexInt(0x300000)
        assert self.MIPS.c13.length == HexInt(0x300000)
        assert self.MIPS.c14.length == HexInt(0x300000)

    def test_case_four_sealed_bit(self):
        assert self.MIPS.c12.s == False
        assert self.MIPS.c13.s == True
        assert self.MIPS.c14.s == False

    def test_case_five_first_cap(self):
        assert self.MIPS.c15.base == HexInt(0x98000000600f9000)
        assert self.MIPS.c15.length == HexInt(0x38000)
        assert self.MIPS.c15.offset == HexInt(0x88c0)
        assert self.MIPS.c15.t

    def test_case_five_return_cap(self):
        # base and length should be the same, offset unpredictable
        assert self.MIPS.c15.base == HexInt(0x98000000600f9000)
        assert self.MIPS.c15.length == HexInt(0x38000)
        assert self.MIPS.c15.t
