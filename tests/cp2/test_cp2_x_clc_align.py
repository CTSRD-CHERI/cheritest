#-
# Copyright (c) 2012 Michael Roe
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
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

from cheritest_tools import BaseCHERITestCase
from nose.plugins.attrib import attr

#
# Test that clc raises an exception if the address from which the capability
# is to be loaded is not aligned on a 32-byte boundary.
#

class test_cp2_x_clc_align(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_x_clc_align_1(self):
        '''Test clc did not load from an unaligned address'''
        self.assertRegisterEqual(self.MIPS.a0, 0,
            "clc loaded from an unaligned address")

    @attr('capabilities')
    def test_cp2_x_clc_align_2(self):
        '''Test clc raises an exception when the address is unaligned'''
        self.assertRegisterEqual(self.MIPS.a2, 1,
            "clc did not raise an exception when the address was unaligned")

    @attr('capabilities')
    def test_cp2_x_clc_align_3(self):
        '''Test CP0 cause register was set correctly when address was unaligned'''
        self.assertRegisterEqual(self.MIPS.a3, 4*4,
            "CP0 status was not set to AdEL when the address was unaligned")
