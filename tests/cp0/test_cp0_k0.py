#-
# Copyright (c) 2018 Michael Roe
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

class test_cp0_k0(BaseBERITestCase):

    def test_cp0_k0_1(self):
        '''Test we can set Config.K0 to uncached'''
        self.assertRegisterMaskEqual(self.MIPS.a1, 0x3, 2, "Config0.K0 was not set to 2 (uncached)")

    def test_cp0_k0_2(self):
        '''Test we can set Config.K0 to cacheable noncoherent'''
        self.assertRegisterMaskEqual(self.MIPS.a2, 0x3, 3, "Config0.K0 was not set to 3 (cacheable noncoherent)")
