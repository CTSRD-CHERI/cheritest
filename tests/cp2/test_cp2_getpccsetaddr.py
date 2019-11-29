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
class test_cp2_getpccsetaddr(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 0

    _EXPECTED_ADDR = HexInt(0x123456)

    def test_basic_addr_zero(self):
        assert self.MIPS.c1.address == HexInt(0), "expected address zero"
        self.assertValidCap(self.MIPS.c1, base=0, offset=0, perms=self.max_permissions,
                            length=self.max_length, msg="Expected full addrspace value with offset == 0")

    def test_bdelay_offset_zero(self):
        """Check that we set the current $pcc value even in a branch delay slot"""
        assert self.MIPS.c2.address == HexInt(0), "expected address zero"
        self.assertValidCap(self.MIPS.c2, base=0, offset=0, perms=self.max_permissions,
                            length=self.max_length, msg="Expected full addrspace value with offset == 0")

    def test_basic_offset_one(self):
        assert self.MIPS.c3.address == self._EXPECTED_ADDR, "expected address 0x123456"
        self.assertValidCap(self.MIPS.c3, base=0, offset=self._EXPECTED_ADDR, perms=self.max_permissions,
                            length=self.max_length, msg="Expected full addrspace value with offset == 0x123456")

    def test_bdelay_offset_one(self):
        """Check that we set the current $pcc value even in a branch delay slot"""
        assert self.MIPS.c4.address == self._EXPECTED_ADDR, "expected address 0x123456"
        self.assertValidCap(self.MIPS.c4, base=0, offset=self._EXPECTED_ADDR, perms=self.max_permissions,
                            length=self.max_length, msg="Expected full addrspace value with offset == 0x123456")
