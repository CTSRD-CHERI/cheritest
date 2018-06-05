#-
# Copyright (c) 2012 Michael Roe
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
# Test that csc raises an exception if it does not have Permit_Store_Capability
# permission.
#

@attr('capabilities')
class test_cp2_x_csc_perm(BaseBERITestCase):

    def test_cp2_x_csc_perm_loaded_values(self):
        '''Test CSC did not store a capability without Permit_Store_Capability permission'''
        self.assertNullCap(self.MIPS.c3, "Original value should be null")
        self.assertCapabilitiesEqual(self.MIPS.c4, self.MIPS.c3,
            "CSC wrote a capability without Permit_Store_Capability permission")
        self.assertCapabilitiesEqual(self.MIPS.c5, self.MIPS.c3,
            "CSC wrote a capability without Permit_Store permission")

    def test_cp2_x_csc_perm_no_permit_store_cap_bytes(self):
        '''Test CSC did not store a capability without Permit_Store_Capability permission'''
        self.assertRegisterEqual(self.MIPS.a0, 0,
            "CSC wrote a capability without Permit_Store_Capability permission")
        self.assertRegisterEqual(self.MIPS.a1, 0,
            "CSC wrote a capability without Permit_Store_Capability permission")

    def test_cp2_x_csc_perm_no_permit_store_cap_triggered(self):
        '''Test CSC raises an exception when it does not have Permit_Store_Capability permission'''
        self.assertRegisterEqual(self.MIPS.a2, 1,
            "CSC did not raise an exception when it did not have Permit_Store_Capability permission")

    def test_cp2_x_csc_perm_no_permit_store_cap_cause(self):
        '''Test capability cause was set correctly when didn't have Permit_Store_Capability permission'''
        self.assertRegisterEqual(self.MIPS.a3, 0x1502,
            "CSC did not set capability cause correctly when didn't have Permit_Store_Capability permission")

    def test_cp2_x_csc_perm_no_permit_store_triggered(self):
        '''Test CSC raises an exception when it does not have Permit_Store permission'''
        self.assertRegisterEqual(self.MIPS.a5, 1,
            "CSC did not raise an exception when it did not have Permit_Store permission")

    def test_cp2_x_csc_perm_no_permit_store_cause(self):
        '''Test capability cause was set correctly when didn't have Permit_Store permission'''
        self.assertRegisterEqual(self.MIPS.a6, 0x1302,
            "CSC did not set capability cause correctly when didn't have Permit_Store permission")
