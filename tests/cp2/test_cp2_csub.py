#-
# Copyright (c) 2016 Michael Roe
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
class test_cp2_csub(BaseBERITestCase):

    def test_cp2_csub_1(self):
        '''Test CSub of two capabilities'''
        assert self.MIPS.a0 == 4, "CSub did not compute the expected result"

    def test_cp2_csub_untagged_untagged(self):
        assert self.MIPS.a1 == HexInt(0x233), "CSub untagged, untagged was wrong"

    def test_cp2_csub_tagged_untagged(self):
        assert self.MIPS.a2 == HexInt(0x1111), "CSub tagged, untagged was wrong"

    def test_cp2_csub_untagged_tagged(self):
        assert self.MIPS.a3 == HexInt(0x5432), "CSub untagged, tagged was wrong"

    def test_cp2_csub_tagged_tagged(self):
        assert self.MIPS.a4 == HexInt(0x7654), "CSub tagged, tagged (non-overlapping bounds) was wrong"

    def test_cp2_csub_tagged_null(self):
        assert self.MIPS.a5 == HexInt(0x2345), "CSub null, tagged was wrong"

    def test_cp2_csub_null_tagged(self):
        assert self.MIPS.a6 == HexInt(0), "CSub tagged, null was wrong"
