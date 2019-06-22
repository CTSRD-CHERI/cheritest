#-
# Copyright (c) 2019 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory (Department of Computer Science and
# Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
# DARPA SSITH research programme.
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

#
# Test CRepresentableAlignmentMask
#
# TODO: depends on 14-bit bottom, add attribute?
@attr('capabilities')
class test_cp2_cram(BaseBERITestCase):
    def test_capabilities_eq(self):
        assert self.MIPS.c4.base == self.MIPS.c2.base, "inexact setbounds result with rounded values should have same base as inexact setbounds"
        assert self.MIPS.c5.base == self.MIPS.c2.base, "exact setbounds result with rounded values should have same base as inexact setbounds"
        assert self.MIPS.c5 == self.MIPS.c4, "exact setbounds result with rounded values should be the same as inexact setbounds with rounded values"

    def test_no_trap_precise_setbounds(self):
        self.assertTrapInfoNoTrap(self.MIPS.a1, msg="Should not trap in exact setbounds")

    @attr("cap_imprecise")
    def test_imprecise_cram_expected_result(self):
        assert self.MIPS.a0 == HexInt(0xffe0000000000000), "wrong result from crrl?"

    @attr("cap_precise")
    def test_precise_cram_expected_result(self):
        assert self.MIPS.a0 == HexInt(0xffffffffffffffff), "wrong result from crrl (precise)?"

    @attr("cap_imprecise")
    def test_new_length(self):
        assert self.MIPS.c2.length == HexInt(0x7ac0000000000000), "unexpected length from inexact setbounds"
        assert self.MIPS.c2.length == self.MIPS.s2, "base computed with cram is wrong"
        assert self.MIPS.s2 == HexInt(0x7ac0000000000000), "length computed with cram is wrong"
        assert self.MIPS.c4.length == HexInt(0x7ac0000000000000), "length (second inexact setbounds) wrong"
        assert self.MIPS.c5.length == HexInt(0x7ac0000000000000), "length (exact setbounds) is wrong"

    @attr("cap_imprecise")
    def test_new_base(self):
        assert self.MIPS.c2.base == HexInt(0x5540000000000000), "unexpected base from inexact setbounds"
        assert self.MIPS.c2.base == self.MIPS.s3, "base computed with cram is wrong"
        assert self.MIPS.s3 == HexInt(0x5540000000000000), "base computed with cram is wrong"
        assert self.MIPS.c4.base == HexInt(0x5540000000000000), "base (second inexact setbounds) wrong"
        assert self.MIPS.c5.base == HexInt(0x5540000000000000), "base (exact setbounds) is wrong"

    @attr("cap_imprecise")
    def test_new_offset(self):
        assert self.MIPS.c2.base != HexInt(0), "unexpected zero offset after inexact setbounds"
        assert self.MIPS.c4.offset == HexInt(0), "offset (second inexact setbounds) should be zero"
        assert self.MIPS.c5.offset == HexInt(0), "offset (exact setbounds) should be zero"

    @attr("cap_precise")
    def test_precise_caps_results(self):
        # no rounding with precise caps:
        assert self.MIPS.c2.base == HexInt(0x5555aaaa5555aaaa)
        assert self.MIPS.c2.length == HexInt(0x7aaa5555aaaa5555)
        assert self.MIPS.a0 == HexInt(0xffffffffffffffff), "expected all-ones mask for precise caps"
