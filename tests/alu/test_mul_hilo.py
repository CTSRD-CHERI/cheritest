#-
# Copyright (c) 2014 Michael Roe
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
from nose.plugins.attrib import attr

class test_mul_hilo(BaseBERITestCase):

    def test_mul_hilo_1(self):
        '''Test MUL followed by MFHI/MFLO'''
        self.assertRegisterEqual(self.MIPS.a0, 6, "MUL of 2 and 3 did not result in 6")

    @attr('mul_hilo_cleared')
    def test_mul_hilo_2(self):
        '''Test that MUL zeros LO'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "MUL did not zero LO (unpredictable value in the MIPS ISA")

    @attr('mul_hilo_cleared')
    def test_mul_hilo_3(self):
        '''Test that MUL zeros HI'''
        self.assertRegisterEqual(self.MIPS.a2, 0, "MUL did not zero HI (unpredictable value in the MIPS ISA")

    @attr('mul_hilo_unchanged')
    def test_mul_hilo_4(self):
        '''Test that MUL leaves LO unchanged'''
        self.assertRegisterEqual(self.MIPS.a1, 5, "MUL changed the value of LO (unpredictable value in the MIPS ISA")

    @attr('mul_hilo_unchanged')
    def test_mul_hilo_5(self):
        '''Test that MUL leaves HI unchanged'''
        self.assertRegisterEqual(self.MIPS.a2, 5, "MUL changed the value of HI (unpredictable value in the MIPS ISA")
