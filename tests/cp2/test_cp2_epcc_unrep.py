#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2017 Robert M. Norton
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

#
# Test to ensure that EPCC is set correctly when a branch occurs to an
# offset (PC) far outside the bounds of PCC such that EPCC would not
# be representable when capability compression is used.
#

@attr('capabilities')
class test_cp2_epcc_unrep(BaseBERITestCase):

    #
    # Check that sandbox was configured roughly as expected
    #
    @attr('capabilities')
    def test_length(self):
        assert self.MIPS.s0 ==  20, "sandbox length not 20"

    #
    # Check that EPC is as expected
    #
    def test_epc(self):
        assert self.MIPS.s3 == 0x10000000, "sandbox EPC unexpected"

    #
    # Check that the post-unrepresentable EPCC is as expected: unrepresentable.
    #
    @attr('cap_precise')
    def test_epcc_tag_precise(self):
        assert self.MIPS.cp2[3].t == 1, "sandbox EPCC tag incorrect"

    @attr('cap_imprecise')
    def test_epcc_tag_imprecise(self):
        assert self.MIPS.cp2[3].t == 0, "sandbox EPCC tag incorrect"

    def test_epcc_unsealed(self):
        assert self.MIPS.cp2[3].s == 0, "sandbox EPCC unsealed incorrect"

    @attr('cap_precise')
    def test_epcc_perms_precise(self):
        assert self.MIPS.cp2[3].perms == 0x0007, "sandbox EPCC perms incorrect"

    @attr('cap_imprecise')
    def test_epcc_perms_imprecise(self):
        assert self.MIPS.cp2[3].perms == 0x0, "sandbox EPCC perms incorrect"
        assert self.MIPS.epcc.perms == 0x0, "sandbox EPCC perms incorrect (final dump value)"

    def test_epcc_ctype(self):
        assert self.MIPS.cp2[3].ctype == 0, "sandbox EPCC ctype incorrect"
        assert self.MIPS.epcc.ctype == 0, "sandbox EPCC ctype incorrect (final dump value)"

    def test_epcc_offset(self):
        assert self.MIPS.cp2[3].base + self.MIPS.cp2[3].offset == self.MIPS.a7 + 0x10000000, "sandbox EPCC offset incorrect"
        assert self.MIPS.epcc.base + self.MIPS.epcc.offset == self.MIPS.a7 + 0x10000000, "sandbox EPCC offset incorrect (final dump value)"

    @attr('cap_imprecise')
    def test_epcc_base_imprecise(self):
        assert self.MIPS.cp2[3].base == 0, "sandbox EPCC base incorrect"
        assert self.MIPS.epcc.base == 0, "sandbox EPCC base incorrect (final dump value)"

    @attr('cap_precise')
    def test_epcc_base_precise(self):
        assert self.MIPS.cp2[3].base == self.MIPS.a7, "sandbox EPCC base incorrect"
        assert self.MIPS.epcc.base == self.MIPS.a7, "sandbox EPCC base incorrect  (final dump value)"

    @attr('cap_precise')
    def test_epcc_length_precise(self):
        assert self.MIPS.cp2[3].length == 20, "sandbox EPCC length incorrect"
        assert self.MIPS.epcc.length == 20, "sandbox EPCC length incorrect (final dump value)"

    @attr('cap_imprecise')
    @attr('cap_null_length')
    def test_epcc_length_imprecise(self):
        assert self.MIPS.cp2[3].length == HexInt(0xffffffffffffffff), "sandbox EPCC length incorrect"
        assert self.MIPS.epcc.length == HexInt(0xffffffffffffffff), "sandbox EPCC length incorrect (final dump value)"
