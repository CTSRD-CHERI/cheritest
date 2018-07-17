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
# Test that the BadInstr register is implemented (also for CHERI instructions)
#
class test_cp2_badinstr(BaseBERITestCase):
    def test_trap_handler_ran(self):
        assert self.MIPS.v1 == 42, "trap handler didn't run"

    def test_badinstr_supported(self):
        assert ((self.MIPS.s3 >> 26) & 1) == 1, "CP0.config3.BadInstr is not set"

    def test_badinstr_value_dmfc0(self):
        # dmfc0 should not sign extend the BadInstr value
        assert self.MIPS.s1 == 0xe8930803, "expected csd  $4, $1, 0($c19) in BadInstr"

    def test_badinstr_value_mfc0(self):
        # mfc0 should not sign extend the BadInstr value
        assert self.MIPS.s4 == 0xe8930803, "expected csd  $4, $1, 0($c19) in BadInstr"

    def test_capcause(self):
        assert (self.MIPS.s2  & 0xff) == 19, "expected register $c19 as the cause"
        assert ((self.MIPS.s2 >> 8) & 0xff) == self.MIPS.CapCause.Length_Violation, "expected length violation as the cause"

    def test_value_not_written(self):
        assert self.MIPS.s0 == 0x123456
