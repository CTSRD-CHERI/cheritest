#-
# Copyright (c) 2020 Alex Richardson
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


@attr('capabilities')
class test_cp2_qemu_tag_opt(BaseBERITestCase):
    def test_was_tagged(self):
        self.assertDefaultCap(self.MIPS.c11, offset=1, msg="stored cap should be default+N")
        self.assertDefaultCap(self.MIPS.c12, offset=2, msg="stored cap should be default+N")
        self.assertDefaultCap(self.MIPS.c13, offset=3, msg="stored cap should be default+N")
        self.assertDefaultCap(self.MIPS.c14, offset=4, msg="stored cap should be default+N")
        self.assertDefaultCap(self.MIPS.c15, offset=5, msg="stored cap should be default+N")
        self.assertDefaultCap(self.MIPS.c16, offset=6, msg="stored cap should be default+N")
        self.assertDefaultCap(self.MIPS.c17, offset=7, msg="stored cap should be default+N")
        self.assertDefaultCap(self.MIPS.c18, offset=8, msg="stored cap should be default+N")

    def test_was_cleared(self):
        assert not self.MIPS.c21.t, "Store should have cleared tag 1"
        assert not self.MIPS.c22.t, "Store should have cleared tag 2"
        assert not self.MIPS.c23.t, "Store should have cleared tag 3"
        assert not self.MIPS.c24.t, "Store should have cleared tag 4"
        assert not self.MIPS.c25.t, "Store should have cleared tag 5"
        assert not self.MIPS.c26.t, "Store should have cleared tag 6"
        assert not self.MIPS.c27.t, "Store should have cleared tag 7"
        assert not self.MIPS.c28.t, "Store should have cleared tag 8"

    def test_address_was_stored(self):
        assert self.MIPS.c21.address == HexInt(2), "Address 1 should have changed"
        assert self.MIPS.c22.address == HexInt(3), "Address 2 should have changed"
        assert self.MIPS.c23.address == HexInt(4), "Address 3 should have changed"
        assert self.MIPS.c24.address == HexInt(5), "Address 4 should have changed"
        assert self.MIPS.c25.address == HexInt(6), "Address 5 should have changed"
        assert self.MIPS.c26.address == HexInt(7), "Address 6 should have changed"
        assert self.MIPS.c27.address == HexInt(8), "Address 7 should have changed"
        assert self.MIPS.c28.address == HexInt(9), "Address 8 should have changed"

