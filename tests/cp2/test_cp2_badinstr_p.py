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

#
# Test that the BadInstr register is implemented
#
class test_cp2_badinstr_p(BaseBERITestCase):
    def test_trap_handler_ran(self):
        assert self.MIPS.v1 == 42, "trap handler didn't run"

    def test_badinstr_p_supported(self):
        assert ((self.MIPS.t1 >> 27) & 1) == 1, "CP0.config3.BadInstrP is not set"

    def test_badinstr_value(self):
        assert self.MIPS.a1 == 0x48013b48, "expected  csetbounds      $c1, $c7, $13 in BadInstr (dmfc)"
        assert self.MIPS.a2 == 0x48013b48, "expected  csetbounds      $c1, $c7, $13 in BadInstr (mfc)"

    def test_badinstr_p_value(self):
        assert self.MIPS.a3 == 0x49270003, "expected cbtu    $c7, 16 in BadInstrP"
        assert self.MIPS.a4 == 0x49270003, "expected cbtu    $c7, 16 in BadInstrP"

    def test_cause_bdelay(self):
        assert ((self.MIPS.a5 >> 31) & 1) == 0x1, "expected BDELAY flag in Cause"

    def test_not_taken_badinstr_value(self):
        assert self.MIPS.s1 == 0x48013b08, "expected  csetbounds      $c1, $c7, $12 in BadInstr (dmfc)"
        assert self.MIPS.s2 == 0x48013b08, "expected  csetbounds      $c1, $c7, $12 in BadInstr (mfc)"

    def test_not_taken_badinstr_p_value(self):
        assert self.MIPS.s3 == 0x4a470004, "expected cbnz    $c7, 20 in BadInstrP"
        assert self.MIPS.s4 == 0x4a470004, "expected cbnz    $c7, 20 in BadInstrP"

    def test_not_taken_cause_bdelay(self):
        assert ((self.MIPS.s5 >> 31) & 1) == 0x1, "expected BDELAY flag in Cause"
