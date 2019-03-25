#-
# Copyright (c) 2019 Robert M. Norton-Wright
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
class test_cp2_cc_wraps(BaseBERITestCase):
    EXPECTED_EXCEPTIONS=6
    
    def test_cc_wraps_oob_load1(self):
        self.assertCp2Fault(self.MIPS.s0, trap_count=1, cap_cause=self.MIPS.CapCause.Length_Violation, cap_reg=2, msg="Out of bounds access did not cause expected capabiltiy fault when pointer has wrapped around address space.")

    def test_cc_wraps_oob_load2(self):
        self.assertCp2Fault(self.MIPS.s1, trap_count=2, cap_cause=self.MIPS.CapCause.Length_Violation, cap_reg=2, msg="Out of bounds access did not cause expected capabiltiy fault when pointer has wrapped around address space.")

    def test_cc_wraps_in_bounds_load1(self):
        self.assertCompressedTrapInfo(self.MIPS.s2, trap_count=3, mips_cause=self.MIPS.Cause.TLB_Load, msg="In bounds access did not cause expected TLB fault when pointer has wrapped around address space.")

    # The following tests require cap128 because they need top=2**64 
    @attr('cap_imprecise')
    def test_cc_wraps_in_bounds_load2(self):
        self.assertCompressedTrapInfo(self.MIPS.s3, trap_count=4, mips_cause=self.MIPS.Cause.TLB_Load, msg="In bounds access did not cause expected TLB fault when pointer has wrapped around address space.")

    @attr('cap_imprecise')
    def test_cc_wraps_oob_load3(self):
        self.assertCp2Fault(self.MIPS.s4, trap_count=5, cap_cause=self.MIPS.CapCause.Length_Violation, cap_reg=4, msg="Out of bounds access did not cause expected capabiltiy fault when pointer has wrapped around address space.")

    @attr('cap_imprecise')
    def test_cc_wraps_in_bounds_load3(self):
        self.assertCompressedTrapInfo(self.MIPS.s5, trap_count=6, mips_cause=self.MIPS.Cause.TLB_Load, msg="In bounds access did not cause expected TLB fault when pointer has wrapped around address space.")
