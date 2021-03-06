#-
# Copyright (c) 2012 Michael Roe
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
# Test that candperm raises a C2E exception if the tag bit is not set on
# the capability register.
#

class test_cp2_x_candperm_tag(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 1

    @attr('capabilities')
    def test_cp2_x_candperm_tag_1(self):
        '''Test CAndPerm raised a C2E exception when capability tag was unset'''
        self.assertCp2Fault(self.MIPS.a2, cap_cause=self.MIPS.CapCause.Tag_Violation, cap_reg=1,
            msg="CAndPerm did not raise an exception when capability tag was unset")

    @attr('capabilities')
    def test_cp2_x_candperm_tag_3(self):
        '''Test CAndPerm did not change dword 0 of an untagged capability'''
        self.assertRegisterEqual(self.MIPS.s0, 0,
            "CAndPerm changed dword 0 of an untagged capability")

    @attr('capabilities')
    def test_cp2_x_candperm_tag_4(self):
        '''Test CAndPerm did not change dword 1 of an untagged capability'''
        self.assertRegisterEqual(self.MIPS.s1, 0,
            "CAndPerm changed dword 1 of an untagged capability")
    @attr('capabilities')

    def test_cp2_x_candperm_tag_5(self):
        '''Test CAndPerm did not change dword 2 of an untagged capability'''
        self.assertRegisterEqual(self.MIPS.s2, 0,
            "CAndPerm changed dword 0 of an untagged capability")

    @attr('capabilities')
    def test_cp2_x_candperm_tag_3(self):
        '''Test CAndPerm did not change dword 0 of an untagged capability'''
        self.assertRegisterEqual(self.MIPS.s3, 0,
            "CAndPerm changed dword 0 of an untagged capability")

