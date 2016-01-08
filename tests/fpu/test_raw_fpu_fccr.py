#-
# Copyright (c) 2011 (holder)
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

class test_raw_fpu_fccr(BaseBERITestCase):

    @attr('floatfccr')
    def test_raw_fpu_fccr_1(self):
        '''Test we can set FCCR to all ones'''
        self.assertRegisterEqual(self.MIPS.a0, 0xff, "FCCR was not set to all ones")

    @attr('floatfccr')
    def test_raw_fpu_fccr_2(self):
        '''Test we can set FCCR to all zeros'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "FCCR was not set to all zeros")

    @attr('floatfccr')
    def test_raw_fpu_fccr_3(self):
        '''Test we can set FCCR to all ones by writing to FCSR'''
        self.assertRegisterEqual(self.MIPS.a2, 0xff, "FCCR was not set to all ones")

    @attr('floatfccr')
    def test_raw_fpu_fccr_4(self):
        '''Test we can set FCCR to all zeros by writing to FCSR'''
        self.assertRegisterEqual(self.MIPS.a3, 0, "FCCR was not set to all ones")


