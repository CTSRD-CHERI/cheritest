#-
# Copyright (c) 2015 Michael Roe
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

from beritest_tools import BaseBERITestCase
from beritest_tools import attr

class test_cp2_cnexeq(BaseBERITestCase):

    @attr('capabilities')
    def test_cp2_cnexeq_1(self):
        self.assertRegisterEqual(self.MIPS.a0, 0, "CNEQEX of a capability with itself did not return 0")

    @attr('capabilities')
    def test_cp2_cnexeq_2(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "CNEQEX of capabilities with different offsets did not return 1")

    @attr('capabilities')
    def test_cp2_cnexeq_3(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "CNEQEX of capabilities with different permissions did not return 1")

    @attr('capabilities')
    def test_cp2_cnexeq_4(self):
        self.assertRegisterEqual(self.MIPS.a3, 1, "CNEQEX of capabilities with different lengths did not return 1")

    @attr('capabilities')
    def test_cp2_cnexeq_5(self):
        self.assertRegisterEqual(self.MIPS.a4, 1, "CNEQEX of capabilities with different tag bit did not return 1")
