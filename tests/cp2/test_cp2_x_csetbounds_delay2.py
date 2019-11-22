# -
# Copyright (c) 2012 Michael Roe
# Copyright (c) 2019 Alex Richardson
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

from beritest_tools import BaseBERITestCase, attr


#
# Test what happens when csetbounds raises a C2E exception in a branch delay slot
#
@attr('capabilities')
class test_cp2_x_csetbounds_delay2(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 1

    def test_cp2_x_csetbounds_delay2_1(self):
        self.assertNullCap(self.MIPS.c3, "CSetBounds should have trapped!")

    def test_cp2_x_csetbounds_delay2_2(self):
        '''Test CSetBounds raised a C2E exception when capability was sealed'''
        self.assertCp2Fault(self.MIPS.s7, cap_reg=1,
                            cap_cause=self.MIPS.CapCause.Seal_Violation,
                            trap_count=1, bdelay=True,
                            msg="CSetBounds did not raise an exception when capability was sealed")
