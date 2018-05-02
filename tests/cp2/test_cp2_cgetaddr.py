#-
# Copyright (c) 2018 Michael Roe
# Copyright (c) 2018 Alex Richardson
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
from nose.plugins.attrib import attr

class test_cp2_cgetaddr(BaseBERITestCase):

    @attr('capabilities')
    def test_cp2_cgetaddr_1(self):
        '''Test CGetAddr returns the address (a0 + 1) '''
        self.assertRegisterEqual(self.MIPS.a1, self.MIPS.a0 + 1, "CGetAddr did not return the expected address")
        self.assertRegisterEqual(self.MIPS.a2, 1, "CGetAddr did not return the expected address")

    @attr('capabilities')
    def test_cp2_cgetaddr_out_of_bouds_pos(self):
        '''Test CGetAddr returns the address even if the capability is out of bounds (offset > len) '''
        self.assertRegisterEqual(self.MIPS.a3, self.MIPS.a0 + 0x12345,
                                 "CGetAddr did not return the expected address for out-of-bounds addresses")

    @attr('capabilities')
    def test_cp2_cgetaddr_out_of_bouds_neg(self):
        '''Test CGetAddr returns the address even if the capability is out of bounds (negative offset)'''
        self.assertRegisterEqual(self.MIPS.a4, self.MIPS.a0 - 1,
                                 "CGetAddr did not return the expected address for out-of-bounds addresses")
