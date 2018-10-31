#-
# Copyright (c) 2013, 2016 Michael Roe
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
# Test that floating point load raises a C2E exception if c0 does not grant
# Permit_Load.
#

@attr('capabilities')
@attr('float')
@attr('float64')
class test_cp2_x_ldc1_perm(BaseBERITestCase):
    '''Test LDC1 raises an exception when $ddc doesn't have Permit_Load permission'''
    EXPECTED_EXCEPTIONS = 1

    def test_not_loaded(self):
        '''Test LDC1 did not load without Permit_Load permission'''
        self.assertRegisterEqual(self.MIPS.a0, 0,
            "LDC1 loaded without Permit_Load permission")

    def test_cp2_cause(self):
        '''Test capability cause is set correctly when doesn't have Permit_Load permission'''
        self.assertCp2Fault(self.MIPS.s0, trap_count=1, cap_cause=self.MIPS.CapCause.Permit_Load_Violation,
            cap_reg=0, msg="Capability cause was not set correctly when didn't have Permit_Load permission")

