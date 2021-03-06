#
# Copyright (c) 2012, 2015 Michael Roe
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

#
# Test that the signed load linked operations sign-extend the value that is
# loaded.
#

class test_cp2_ll_signex(BaseBERITestCase):

    @attr('capabilities')
    @attr('cached')
    def test_cp2_ll_signex_1(self):
        '''Test that cllb sign-extends the result'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfffffffffffffffe,
            "cllb of negative value returned incorrect result")

    @attr('capabilities')
    @attr('cached')
    def test_cp2_ll_signex_2(self):
        '''Test that cllh sign-extends the result'''
        self.assertRegisterEqual(self.MIPS.a1, 0xfffffffffffffedc,
            "cllh of negative value returned incorrect result")

    @attr('capabilities')
    @attr('cached')
    def test_cp2_ll_signex_3(self):
        '''Test that cllw sign-extends the result'''
        self.assertRegisterEqual(self.MIPS.a2, 0xfffffffffedcba98,
            "clw of negative value returned incorrect result")

