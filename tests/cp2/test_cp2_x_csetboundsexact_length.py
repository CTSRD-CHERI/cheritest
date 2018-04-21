#-
# Copyright (c) 2015, 2018 Michael Roe
# All rights reserved.
#
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

class test_cp2_x_csetboundsexact_length(BaseBERITestCase):

    @attr('capabilities')
    def test_cp2_x_csetboundsexact_length_1(self):
        '''Test that CSetBounds set the length to zero'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "CSetBounds didn't give the requested length of zero (possibly allowed by spec, but very unhelpful)")

    @attr('capabilities')
    def test_cp2_x_csetboundsexact_length_2(self):
        '''Test that CSetBoundsExact raises an exception when the requested length is greater than the current length'''
        self.assertRegisterEqual(self.MIPS.a2, 1, "CSetBoundsExact did not raise an exception")

    @attr('capabilities')
    def test_cp2_x_csetboundsexact_length_3(self):
        '''Test that CSetBoundsExact doesn't increase the length'''
        self.assertRegisterEqual(self.MIPS.a3, 0, "CSetBoundsExact increased the length")

