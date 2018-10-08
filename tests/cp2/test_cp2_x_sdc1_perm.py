#-
# Copyright (c) 2013 Michael Roe
# Copyright (c) 2018 Alex Richardson
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
# Test that a double precision floating point store raises a C2E exception if
# c0 does not grant Permit_Store.
#

@attr('capabilities')
@attr('float')
@attr('float64')
class test_cp2_x_sdc1_perm(BaseBERITestCase):
    def test_cp2_x_sdc1_perm_1(self):
        '''Test sdc1 did not store without Permit_Store permission'''
        self.assertRegisterEqual(self.MIPS.t0, 0x0123456789abcdef,
            "sdc1 stored without Permit_Store permission")

    def test_cp2_x_sdc1_perm_exc_count(self):
        '''Test sdc1 raises an exception when doesn't have Permit_Store permission'''
        self.assertRegisterEqual(self.MIPS.v0, 1,
            "should only have one exception: sdc1 Permit_Store violation")

    def test_cp2_x_sdc1_perm_permit_store(self):
        '''Test capability cause is set correctly when doesn't have Permit_Store permission'''
        self.assertCompressedTrapInfo(self.MIPS.s0, mips_cause=self.MIPS.Cause.COP2,
            cap_cause=self.MIPS.CapCause.Permit_Store_Violation, trap_count=1,
            msg="unexpected trap during sdc1 when didn't have Permit_Store permission")

    def test_cp2_x_sdc1_perm_no_more_exceptions(self):
        self.assertNullCap(self.MIPS.c4, msg='There should not have been any more exceptions')

