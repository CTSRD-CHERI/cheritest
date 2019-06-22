#-
# Copyright (c) 2015, 2016 Michael Roe
# Copyright 2019 Alex Richardson
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
class test_cp2_cfromptr_imprecise(BaseBERITestCase):
    @attr('cap_precise')
    def test_cp2_cfromptr_imprecise_offset_precise(self):
        self.assertRegisterEqual(self.MIPS.a0, 0x1000000, "CFromPtr did not set the offset to the expected value")

    @attr('cap_imprecise')
    def test_cp2_cfromptr_imprecise_offset_imprecise(self):
        assert self.MIPS.c1.offset == 0, "CFromPtr did not set the offset to the expected value"
        self.assertRegisterEqual(self.MIPS.a0, 0x0, "CFromPtr did not set the offset to the expected value")

    @attr('cap_precise')
    def test_cp2_cfromptr_imprecise_tag_precise(self):
        assert self.MIPS.c1.t, "CFromPtr did not set the tag on the result"
        self.assertRegisterEqual(self.MIPS.a1, 1, "CFromPtr did not set the tag on the result")

    @attr('cap_imprecise')
    def test_cp2_cfromptr_imprecise_tag_imprecise(self):
        self.assertRegisterEqual(self.MIPS.a1, 0, "CFromPtr did not set the tag on the result when it was imprecise")

    @attr('cap_precise')
    def test_cp2_cfromptr_imprecise_base_precise(self):
        assert self.MIPS.c1.base == 2, "CFromPtr did not set base to the expected value"
        # Also check the cgetbase result
        self.assertRegisterEqual(self.MIPS.a2, 2, "CFromPtr did not set base to the expected value")

    def test_cp2_cfromptr_imprecise_len_precise(self):
        # The length should be correct even if the capability became unrepresentable
        assert self.MIPS.c1.length == 1, "CFromPtr did not set length to the expected value"
        self.assertRegisterEqual(self.MIPS.a3, 1, "CFromPtr did not set length to the expected value")

    def test_cp2_cfromptr_imprecise_perms_precise(self):
        # The length should be correct even if the capability became unrepresentable
        assert self.MIPS.c1.perms == 6, "CFromPtr did not set permissions to the expected value"

    def test_cp2_cfromptr_imprecise_addr_precise(self):
        # The address should be correct even if the capability became unrepresentable
        assert self.MIPS.c1.address == HexInt(0x0000000001000002), "CFromPtr did not set address to the expected value"
        self.assertRegisterEqual(self.MIPS.a4, 0x0000000001000002, "CFromPtr did not set address to the expected value")

    def test_cp2_cfromptr_imprecise_base_cap(self):
        assert self.MIPS.c2.base == HexInt(2), "input capability base is wrong"
        assert self.MIPS.c2.address == HexInt(2), "input capability address is wrong"
        assert self.MIPS.c2.length == HexInt(1), "input capability length is wrong"
        assert self.MIPS.c2.t, "input capability tag is wrong"
