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

class test_cp2_x_cjr_length(BaseBERITestCase):

    @attr('capabilities')
    def test_cp2_x_cjr_length_1(self):
        self.assertRegisterEqual(self.MIPS.a0, 0, "Sandbox was run even though it was outside the bounds of the capability")

    @attr('capabilities')
    def test_cp2_x_cjr_length_2(self):
        self.assertRegisterEqual(self.MIPS.a1, self.MIPS.a5, "CJR outside the bounds of the capability did not set EPCC to the expected value")

    @attr('capabilities')
    def test_cp2_x_cjr_length_3(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "CJR outside the bounds of the capability did not raise an exception")

    @attr('capabilities')
    def test_cp2_x_cjr_length_4(self):
        self.assertRegisterEqual(self.MIPS.a3, 0x0101, "CJR outside the bounds of the capability set the cause register to an unexpected value")

