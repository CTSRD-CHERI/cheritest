#-
# Copyright (c) 2015 Michael Roe
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

class test_cp2_csetoffset_imprecise(BaseBERITestCase):

    @attr('capabilities')
    @attr('cap_precise')
    def test_cp2_csetoffset_imprecise_offset_precise(self):
        self.assertRegisterEqual(self.MIPS.a0, 0x1000000, "CSetOffset did not set the offset to the expected value")

    @attr('capabilities')
    @attr('cap_precise')
    def test_cp2_csetoffset_imprecise_tag_precise(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "CSetOffset did not set the tag on the result")

    @attr('capabilities')
    @attr('cap_imprecise')
    def test_cp2_csetoffset_imprecise_tag_imprecise(self):
        self.assertRegisterEqual(self.MIPS.a1, 0, "CSetOffset did not set the tag on the result when it was imprecise")


    @attr('capabilities')
    @attr('cap_precise')
    def test_cp2_csetoffset_imprecise_base_precise(self):
        self.assertRegisterEqual(self.MIPS.a2, 2, "CSetOffset did not set base to the expected value")

    @attr('capabilities')
    def test_cp2_csetoffet_imprecise_len_precise(self):
        self.assertRegisterEqual(self.MIPS.a3, 1, "CSetOffset did not set length to the expected value")
