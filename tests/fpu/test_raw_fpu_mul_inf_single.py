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

#
# Test IEEE 747 infinity values in single-precision arithmetic
#

from beritest_tools import attr

from beritest_tools import BaseBERITestCase


class test_raw_fpu_mul_inf_single(BaseBERITestCase):

    def test_raw_fpu_mul_inf_single_1(self):
        '''Test MUL.S of 1.0 and +infinity'''
        self.assertRegisterEqual(self.MIPS.a0, 0x7f800000, "MUL.S of 1.0 and +infinity did not give +infinity")

    def test_raw_fpu_mul_inf_single_2(self):
        '''Test MUL.S of +Infinity and 0.0'''
        self.assertRegisterIsSingleNaN(self.MIPS.a1, "MUL.S of +infinity and 0.0 did not give NaN")

    @attr('floatnan2008')
    def test_raw_fpu_mul_inf_single_3(self):
        '''Test MUL.S of +Infinity and 0.0'''
        self.assertRegisterIsSingleQNaN(self.MIPS.a1, "MUL.S of +infinity and 0.0 did not give QNaN")

