#-
# Copyright (c) 2014, 2016 Michael Roe
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

#
# Test neg.s of "Quiet Not a Number" (QNaN)
#

from beritest_tools import attr

from beritest_tools import BaseBERITestCase


class test_raw_fpu_neg_qnan(BaseBERITestCase):

#
# This test for a 'not a number' value really should test that the fraction
# part is non-zero, as this denotes +/- infinity rather than NaN.
#
    def test_raw_fpu_neg_qnan_1(self):
        '''Test NEG.S of QNaN'''
        self.assertRegisterMaskEqual(self.MIPS.a0, 0x7f800000, 0x7f800000, "NEG.S did not return QNaN")

    @attr('floatlegacyabs')
    def test_raw_fpu_neg_qnan_2(self):
        '''Test that NEG.S of QNaN has IEEE 754-1985 behaviour'''
        self.assertRegisterMaskEqual(self.MIPS.a0, 0xff800000, 0x7f800000, "NEG.S did not return QNaN")

    @attr('floatlegacyabs')
    @attr('floatechonan')
    def test_raw_fpu_neg_qnan_3(self):
        '''Test NEG.S echos a QNaN'''
        self.assertRegisterEqual(self.MIPS.a0, 0x7f900000, "NEG.S did not echo QNaN")

    def test_raw_fpu_neg_qnan_4(self):
        '''Test NEG.D of QNaN'''
        self.assertRegisterMaskEqual(self.MIPS.a2, 0x7ff0000000000000, 0x7ff0000000000000, "NEG.D did not return QNaN")
        
    @attr('floatlegacyabs')
    def test_raw_fpu_neg_qnan_5(self):
        '''Test that NEG.D has IEEE 754-1985 behaviour'''
        self.assertRegisterMaskEqual(self.MIPS.a2, 0xfff0000000000000, 0x7ff0000000000000, "NEG.D did not return QNaN")

    @attr('floatlegacyabs')
    @attr('floatechonan')
    def test_raw_fpu_neg_qnan_6(self):
        '''Test that NEG.D echos QNaN'''
        self.assertRegisterEqual(self.MIPS.a2, 0x7ff1000000000000, "NEG.D did not return QNaN")
        
    @attr('floatlegacyabs')
    def test_raw_fpu_neg_qnan_7(self):
        '''Test that FCSR.ABS2008 is not set'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "FCSR.ABS2008 was set")

