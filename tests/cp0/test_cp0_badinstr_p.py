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
class test_cp0_badinstr_p(BaseBERITestCase):
    def test_trap_handler_ran(self):
        assert self.MIPS.v1 == 42, "trap handler didn't run"

    @attr("badinstr_p")
    def test_badinstr_p_supported(self):
        assert ((self.MIPS.a4 >> 27) & 1) == 1, "CP0.config3.BadInstrP is not set"

    def test_badinstr_value(self):
        assert self.MIPS.a1 == 0x00000034, "expected teq $zero, $zero in BadInstr"

    @attr("badinstr_p")
    def test_badinstr_p_value(self):
        assert self.MIPS.a2 == 0x10000003, "expected b 16 in BadInstrP"

    def test_cause_bdelay(self):
        assert ((self.MIPS.a3 >> 31) & 1) == 0x1, "expected BDELAY flag in Cause"


    def test_not_taken_badinstr_value(self):
        assert self.MIPS.s1 == 0x00000034, "expected teq $zero, $zero in BadInstr"

    @attr("badinstr_p")
    def test_not_taken_badinstr_p_value(self):
        assert self.MIPS.s2 == 0x10050004, "beq $zero, $5, 20 in BadInstrP"

    def test_not_taken_cause_bdelay(self):
        assert ((self.MIPS.s3 >> 31) & 1) == 0x1, "expected BDELAY flag in Cause"
