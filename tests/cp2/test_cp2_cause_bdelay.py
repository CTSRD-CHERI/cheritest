#
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

# Check that CP0_Cause.BD is set correctly for CHERI instructions
@attr('capabilities')
class test_cp2_cause_bdelay(BaseBERITestCase):
    def test_trap_handler_ran(self):
        assert self.MIPS.v0 == 8, "Expected 7 traps"

    def test_mips_trap_not_bdelay(self):
        self.assertCompressedTrapInfo(self.MIPS.c4, mips_cause=self.MIPS.Cause.TRAP, trap_count=1, bdelay=False)

    def test_mips_trap_bdelay(self):
        self.assertCompressedTrapInfo(self.MIPS.c5, mips_cause=self.MIPS.Cause.TRAP, trap_count=2, bdelay=True)

    def test_csetbounds_not_bdelay(self):
        self.assertCp2Fault(self.MIPS.c6, cap_cause=self.MIPS.CapCause.Tag_Violation,
                                      cap_reg=1, trap_count=3, bdelay=False)

    def test_csetbounds_bdelay(self):
        self.assertCp2Fault(self.MIPS.c7, cap_cause=self.MIPS.CapCause.Tag_Violation,
                                      cap_reg=1, trap_count=4, bdelay=True)

    def test_cfromptr_bdelay(self):
        self.assertCp2Fault(self.MIPS.c8, cap_cause=self.MIPS.CapCause.Tag_Violation,
                                      cap_reg=1, trap_count=5, bdelay=True)

    def test_clc_bdelay(self):
        self.assertCp2Fault(self.MIPS.c9, cap_cause=self.MIPS.CapCause.Tag_Violation,
                                      cap_reg=1, trap_count=6, bdelay=True)

    def test_csc_bdelay(self):
        self.assertCp2Fault(self.MIPS.c10, cap_cause=self.MIPS.CapCause.Tag_Violation,
                                      cap_reg=1, trap_count=7, bdelay=True)

    def test_clcbi_bdelay(self):
        self.assertCp2Fault(self.MIPS.c11, cap_cause=self.MIPS.CapCause.Tag_Violation,
                                      cap_reg=1, trap_count=8, bdelay=True)
