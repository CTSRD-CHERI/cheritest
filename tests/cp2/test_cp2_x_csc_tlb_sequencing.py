#-
# Copyright (c) 2014 Michael Roe
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

class test_cp2_x_csc_tlb_sequencing(BaseBERITestCase):

    # Test sequencing (a5, c5)
    @attr('capabilities')
    @attr('tlb')
    def test_cp2_clc_tlb_progress(self):
        '''Test that test finishes at the end of stage 5'''
        self.assertRegisterEqual(self.MIPS.a5, 5, "Test did not finish at the end of stage 5")

    @attr('capabilities')
    @attr('tlb')
    def test_cp2_clc_tlb_write(self):
        '''Test that the store was ultimately successful'''
        self.assertCapabilitiesEqual(self.MIPS.c5, self.MIPS.c1, "Failed to store")

    # Initialization (a2)
    @attr('capabilities')
    @attr('tlb')
    def test_cp2_clc_tlb_0_ld(self):
        self.assertRegisterEqual(self.MIPS.a2, 0x0123, "Initial data load failed")

    # First fault (a3, c3)
    @attr('capabilities')
    @attr('tlb')
    def test_cp2_clc_tlb_1_cp0_cause(self):
        '''Test that CP0 cause register is set correctly'''
        self.assertRegisterMaskEqual(self.MIPS.a3, 0x1f << 2, 1 << 2, "First CP0.Cause.ExcCode is not TLB Modified")

    @attr('capabilities')
    @attr('tlb')
    def test_cp2_clc_tlb_1_nowrite(self):
        self.assertCapabilitiesEqual(self.MIPS.c3, self.MIPS.c2, "Memory modified despite dirty bit clear")

    # Second fault (a4, c4, a6)
    @attr('capabilities')
    @attr('tlb')
    def test_cp2_clc_tlb_2_cp2_cause(self):
        '''Test that CP0 cause register is set correctly'''
        self.assertRegisterMaskEqual(self.MIPS.a4, 0xFF00, 0x0900, "Second fault capcause is not MMU store inhibit")

    @attr('capabilities')
    @attr('tlb')
    def test_cp2_clc_tlb_2_nowrite(self):
        self.assertCapabilitiesEqual(self.MIPS.c4, self.MIPS.c2, "Memory modified despite store cap inhibit set")

    @attr('capabilities')
    @attr('tlb')
    def test_cp2_clc_tlb_2_cp0_cause(self):
        '''Test that CP0 cause register is set correctly'''
        self.assertRegisterMaskEqual(self.MIPS.a6, 0x1f << 2, 18 << 2, "Second CP0.Cause.ExcCode is not precise CP2 exception")

