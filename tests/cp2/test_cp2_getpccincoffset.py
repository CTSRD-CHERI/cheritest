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
