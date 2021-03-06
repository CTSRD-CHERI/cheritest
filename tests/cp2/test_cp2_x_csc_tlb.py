#-
# Copyright (c) 2014 Michael Roe
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

from beritest_tools import BaseBERITestCase
from beritest_tools import attr

@attr('capabilities')
@attr('tlb')
class test_cp2_x_csc_tlb(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 1

    def test_cp2_clc_tlb_progress(self):
        '''Test that test finishes at the end of stage 3'''
        self.assertRegisterEqual(self.MIPS.a5, 3, "Test did not finish at the end of stage 3")

    def test_cp2_clc_tlb_cause_csc(self):
        '''Test that CP0 cause set to TLB_Store_Capability_Violation'''
        self.assertCp2Fault(self.MIPS.s1, cap_cause=self.MIPS.CapCause.TLB_Store_Capability_Violation, trap_count=1)
