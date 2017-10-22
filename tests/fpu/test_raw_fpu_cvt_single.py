#-
# Copyright (c) 2013 Michael Roe
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
# Test single-precision rounding mode
#

from beritest_tools import BaseBERITestCase


class test_raw_fpu_cvt_single(BaseBERITestCase):

    def test_raw_fpu_cvt_single_mode(self):
        '''Test default rounding mode'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "Default rounding mode is not round to nearest even")

    def test_raw_fpu_cvt_single_1(self):
        '''Test default rounding mode'''
        self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff, "-0.75 did not round to -1")

    def test_raw_fpu_cvt_single_2(self):
        '''Test default rounding mode'''
        self.assertRegisterEqual(self.MIPS.a2, 0, "-0.5 did not round to 0")

    def test_raw_fpu_cvt_single_3(self):
        '''Test default rounding mode'''
        self.assertRegisterEqual(self.MIPS.a3, 0, "-0.25 did not round to 0")

    def test_raw_fpu_cvt_single_4(self):
        '''Test default rounding mode'''
        self.assertRegisterEqual(self.MIPS.a4, 0, "0.5 did not round to 0")

    def test_raw_fpu_cvt_single_5(self):
        '''Test default rounding mode'''
        self.assertRegisterEqual(self.MIPS.a5, 2, "1.5 did not round to 2")


