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
# Test CRoundRepresentableLength (aka CRoundArchitecturalPrecision or "crap")
#
# TODO: depends on 14-bit bottom, add attribute?
@attr('capabilities')
class test_cp2_crap(BaseBERITestCase):
    def test_rounded_length_eq(self):
        assert self.MIPS.a0 == self.MIPS.a1, "crrl(len) != cgetlen(rounded_cap)"

    @attr("cap_imprecise")
    def test_cround_representable_length_expected_result(self):
        assert self.MIPS.a0 == HexInt(0xaac0000000000000), "wrong result from crrl?"

    @attr("cap_imprecise")
    def test_rounded_cap_length(self):
        assert self.MIPS.c2.length == HexInt(0xaac0000000000000)

    @attr("cap_imprecise")
    def test_rounded_cap_base(self):
        assert self.MIPS.c2.base == HexInt(0x5540000000000000)

    @attr("cap_precise")
    def test_precise_result(self):
        # no rounding with precise caps:
        assert self.MIPS.c2.base == HexInt(0x5555aaaa5555aaaa)
        assert self.MIPS.c2.length == HexInt(0xaaaa5555aaaa5555)
        assert self.MIPS.a0 == HexInt(0xaaaa5555aaaa5555)

