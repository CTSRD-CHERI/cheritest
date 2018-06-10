#
# Copyright (c) 2017 Alfredo Mazzinghi
# Copyright (c) 2017 Hongyan Xia
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

from beritest_tools import BaseBERITestCase, xfail_gnu_binutils
from beritest_tools import attr

#
# Test a ccall_fast
#
@xfail_gnu_binutils
class test_cp2_x_ccall_fast_data_perm(BaseBERITestCase):

    @attr('capabilities')
    @attr('ccall_hw_2')
    def test_cp2_x_ccall_fast_data_perm_1(self):
        '''Test that the ccall does not enter the sandbox'''
        self.assertRegisterEqual(self.MIPS.t1, 0x0,
                                 "sandbox entered without Permit_CCall on sealed data capability.")

    @attr('capabilities')
    @attr('ccall_hw_2')
    def test_cp2_x_ccall_fast_data_perm_2(self):
        '''Test that the exception raised has the correct cause'''
        self.assertRegisterEqual(self.MIPS.t3, 0x1902,
                                 "Permit_CCall violation raised with invalid cause.")
