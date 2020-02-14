#-
# Copyright (c) 2011 Michael Roe
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
# Check basic behaviour of cgetpcc.
#
@attr('capabilities')
class test_cp2_getpccincoffset(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 0

    def test_basic_offset_zero(self):
        self.assertValidCap(self.MIPS.c1, base=0, offset=self.MIPS.s0, perms=self.max_permissions,
                            length=self.max_length, msg="Expected full addrspace value with offset == .Lfirst_getpcc")

    def test_bdelay_offset_zero(self):
        """Check that we set the current $pcc value even in a branch delay slot"""
        self.assertValidCap(self.MIPS.c2, base=0, offset=self.MIPS.s1, perms=self.max_permissions,
                            length=self.max_length, msg="Expected full addrspace value with offset == .Lsecond_getpcc")

    def test_basic_offset_one(self):
        self.assertValidCap(self.MIPS.c3, base=0, offset=self.MIPS.s2 + 1, perms=self.max_permissions,
                            length=self.max_length, msg="Expected full addrspace value with offset == .Lthird_getpcc+1")

    def test_bdelay_offset_one(self):
        """Check that we set the current $pcc value even in a branch delay slot"""
        self.assertValidCap(self.MIPS.c4, base=0, offset=self.MIPS.s3 + 1, perms=self.max_permissions,
                            length=self.max_length, msg="Expected full addrspace value with offset == .Lfourth_getpcc+1")

    def test_expected_difference(self):
        assert self.MIPS.s1 == self.MIPS.s0 + 8, "Expected a difference of two instructions"
        assert self.MIPS.s3 == self.MIPS.s2 + 8, "Expected a difference of two instructions"

    def test_restricted_target(self):
        assert self.MIPS.c12.base == self.MIPS.s5, "Expected base == .Lnonzero_base"
        assert self.MIPS.c12.address == self.MIPS.s5 + 100, "Expected addr == .Lnonzero_base"
        assert self.MIPS.c12.offset == 100
        assert self.MIPS.c12.length == 116

    def test_restricted_getpccincoffset(self):
        assert self.MIPS.c5.address == self.MIPS.s5 + 100 - 1, "Expected addr == .Lnonzero_base + 100 - 1"
        assert self.MIPS.c5.base == self.MIPS.s5, "Expected base == .Lnonzero_base"
        assert self.MIPS.c5.offset == HexInt(99), "Expected offset == 99"
        assert self.MIPS.c5.length == 116

    def test_restricted_getpccincoffset_unrep_common(self):
        assert self.MIPS.c6.address == self.MIPS.s5 + 0x10000000 + 100 + 4, "Expected addr to be .Lnonzero_base+100+4+0x10000000"
        assert self.MIPS.c6.length == 116

    @attr("cap_imprecise")
    def test_restricted_getpccincoffset_unrep_imprecise(self):
        assert not self.MIPS.c6.t, "Expected tag to be cleared"
        assert self.MIPS.c6.base == self.MIPS.s5 + 0x10000000, "Expected base to be changed"
        assert self.MIPS.c6.offset == HexInt(104), "Expected offset == 104"

    @attr("cap_precise")
    def test_restricted_getpccincoffset_unrep_precise(self):
        assert self.MIPS.c6.t, "Expected tag"
        assert self.MIPS.c6.base == self.MIPS.s5, "Expected base == .Lnonzero_base"
        assert self.MIPS.c6.offset == HexInt(0x10000000) + 104, "Expected offset == 100 + 0x10000004"
