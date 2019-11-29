#-
# Copyright (c) 2011 Michael Roe
# Copyright (c) 2016 Jonathan Woodruff
# Copyright (c) 2019 Alex Richardson
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
# Check basic behaviour of cgetpccsetoffset.
#

@attr('capabilities')
class test_cp2_getpccsetoffset(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 0

    def test_getpcc(self):
        self.assertValidCap(self.MIPS.c1, offset=0x1234, perms=self.max_permissions,
                            length=self.max_length,
                            msg="Expected full addrspace value with offset 0x1234")

    def test_offset(self):
        '''Test that cgetpcc returns correct offset'''
        assert self.MIPS.a4 == self.MIPS.v0, "cgetpccsetoffset returns incorrect offset"
        assert self.MIPS.a5 == self.MIPS.v0, "cgetpccsetoffset returns incorrect offset"
        assert self.MIPS.a4 == HexInt(0x1234), "cgetpccsetoffset returns incorrect offset"
        assert self.MIPS.a5 == HexInt(0x1234), "cgetpccsetoffset returns incorrect offset"

    def test_delay_slot(self):
        assert self.MIPS.c1 == self.MIPS.c2, "Value set in branch delay slot should be the same!"
