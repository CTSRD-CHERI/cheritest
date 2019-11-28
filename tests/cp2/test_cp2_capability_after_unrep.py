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
from beritest_tools import BaseBERITestCase, attr, HexInt


# Check that unrepresentable capabilities retain the same address:
# This test also checks how the other fields are adjusted (due to being relative to the cursor)
@attr('capabilities')
class test_cp2_capability_after_unrep(BaseBERITestCase):
    def test_addr(self):
        assert self.MIPS.c2.address == HexInt(0x10000000), "addr should be value from csetaddr"
        assert self.MIPS.c2.address == self.MIPS.a1, "addr should be value from csetaddr"
        assert self.MIPS.s1 == self.MIPS.a1, "addr should be value from csetaddr"

    def test_perms(self):
        assert self.MIPS.c2.perms == 0x7, "perms should not change due to unrep"
        assert self.MIPS.c2.perms == self.MIPS.c1.perms, "perms should not change due to unrep"
        assert self.MIPS.s3 == self.MIPS.c1.perms, "perms should not change due to unrep"

    def test_sealed(self):
        assert self.MIPS.c2.s == 0, "unrep cap should not be sealed"

    def test_otype(self):
        assert self.MIPS.c2.ctype == self.unsealed_otype, "unrep cap should not have an otype"

    @attr('cap_imprecise')
    def test_base_imprecise(self):
        assert self.MIPS.c2.base == HexInt(0x10000000), "base should change to retain address"
        assert self.MIPS.s2 == HexInt(0x10000000), "base should change to retain address"

    @attr('cap_precise')
    def test_base_precise(self):
        assert self.MIPS.c2.base == self.MIPS.c1.base, "base should not change when precise"
        assert self.MIPS.s2 == self.MIPS.c1.base, "base should not change when precise"

    def test_length(self):
        assert self.MIPS.c2.length == self.MIPS.c1.length, "length should not change"
        assert self.MIPS.s0 == self.MIPS.c1.length, "length should not change"

    @attr('cap_imprecise')
    def test_tag_imprecise(self):
        assert self.MIPS.c2.t == 0, "tag should be cleared to 0 on unrep"

    @attr('cap_precise')
    def test_tag_precise(self):
        assert self.MIPS.c2.t == 1, "tag should not be cleared with precise caps"

    @attr('cap_imprecise')
    def test_offset_imprecise(self):
        assert self.MIPS.c2.offset == HexInt(0), "Offset should be zero (since base was adjusted)"
        assert self.MIPS.s4 == HexInt(0), "Offset should be zero (since base was adjusted)"

    @attr('cap_precise')
    def test_offset_precise(self):
        assert self.MIPS.c2.offset == HexInt(0x10000000), "Offset should be == addr"
        assert self.MIPS.c2.offset == self.MIPS.c2.address, "Offset should be == addr"
        assert self.MIPS.s4 == self.MIPS.s1, "Offset should be == addr when precise"
        assert self.MIPS.s4 == self.MIPS.a1, "Offset should be == addr when precise"
