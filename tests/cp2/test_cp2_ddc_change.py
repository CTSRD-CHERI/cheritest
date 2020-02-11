#-
# Copyright (c) 2020 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory (Department of Computer Science and
# Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
# DARPA SSITH research programme.
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
import itertools
from beritest_tools import BaseBERITestCase, attr, HexInt
#
# Test that the unsigned load operations zero-extend the value that is loaded.
#

@attr('capabilities')
class test_cp2_ddc_change(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 2

    def test_first_load_succeeded(self):
        self.assertTrapInfoNoTrap(self.MIPS.s1)
        assert self.MIPS.a1 == HexInt(0x1234), "Should have loaded"

    def test_second_load_succeeded(self):
        self.assertTrapInfoNoTrap(self.MIPS.s2)
        assert self.MIPS.a2 == HexInt(0x1234), "Should have loaded"

    def test_third_load_failed(self):
        self.assertCp2Fault(self.MIPS.s3, cap_cause=self.MIPS.CapCause.Length_Violation, cap_reg=0, trap_count=1,
                            msg="lhu with length 1 $ddc should fail")
        assert self.MIPS.a4 == HexInt(0), "Should not have loaded"

    def test_load_failed(self):
        self.assertCp2Fault(self.MIPS.s4, cap_cause=self.MIPS.CapCause.Tag_Violation, cap_reg=0, trap_count=2,
                            msg="lhu with NULL $ddc should fail")
        assert self.MIPS.a4 == HexInt(0), "Should not have loaded"

