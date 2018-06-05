#-
# Copyright (c) 2018 Michael Roe
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

from beritest_tools import BaseBERITestCase
from beritest_tools import attr

class test_cp2_csch_align(BaseBERITestCase):

    @attr('capabilities')
    @attr('cached')
    def test_cp2_csch_align_1(self):
        '''Test CLLH with a word-aligned address'''
        self.assertRegisterEqual(self.MIPS.a0, 0x0123, "CLLH did not read the expected value")

    @attr('capabilities')
    @attr('cached')
    def test_cp2_csch_align_2(self):
        '''Test CLLH, CSCH, CLLH with a word-aligned address'''
        self.assertRegisterEqual(self.MIPS.a1, 0xfffffffffffffedc, "CLLH did not read back the expected value after CSCH")

    @attr('capabilities')
    @attr('cached')
    def test_cp2_csch_align_3(self):
        '''Test CLLH with a half-word-aligned address'''
        self.assertRegisterEqual(self.MIPS.a2, 0x4567, "CLLH did not read the expected value")

    @attr('capabilities')
    @attr('cached')
    def test_cp2_csch_align_4(self):
        '''Test CLLH, CSCH, CLLH with half-a word-aligned address'''
        self.assertRegisterEqual(self.MIPS.a3, 0xffffffffffffba98, "CLLH did not read back the expected value after CSCH")

