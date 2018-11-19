#-
# Copyright (c) 2018 Alex Richardson
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer
# Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
# project, funded by EPSRC grant EP/K008528/1.
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

from beritest_tools import BaseBERITestCase, attr

@attr('capabilities')
class test_cp2_csetboundsimmediate(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 1

    def test_length_zero(self):
        assert self.MIPS.c12.t, "non-immediate csetbounds broken (tag missing)"
        assert self.MIPS.c12.length == 0, "non-immediate csetbounds broken"
        assert self.MIPS.c2.t, "immediate csetbounds broken (tag missing)"
        assert self.MIPS.c2.length == 0, "immediate csetbounds broken"

    def test_length_max(self):
        # This would cause a length violation if the immediate was treated as
        # signed (2047 unsigned -> -1 signed)
        assert self.MIPS.c13.t, "non-immediate csetbounds broken (tag missing)"
        assert self.MIPS.c13.length == 2047, "non-immediate csetbounds broken"
        assert self.MIPS.c3.t, "immediate csetbounds broken (tag missing)"
        assert self.MIPS.c3.length == 2047, "immediate csetbounds broken"

    def test_length_max_minus_one_bit(self):
        assert self.MIPS.c14.t, "non-immediate csetbounds broken (tag missing)"
        assert self.MIPS.c14.length == 1023, "non-immediate csetbounds broken"
        assert self.MIPS.c4.t, "immediate csetbounds broken (tag missing)"
        assert self.MIPS.c4.length == 1023, "immediate csetbounds broken"

    def test_length_max_minus_one_bit_plus_1(self):
        # This would cause a length violation if the immediate was treated as
        # signed (1024 unsigned -> -1024 signed)
        assert self.MIPS.c15.t, "non-immediate csetbounds broken (tag missing)"
        assert self.MIPS.c15.length == 1024, "non-immediate csetbounds broken"
        assert self.MIPS.c5.t, "immediate csetbounds broken (tag missing)"
        assert self.MIPS.c5.length == 1024, "immediate csetbounds broken"

    def test_length_one(self):
        assert self.MIPS.c16.t, "non-immediate csetbounds broken (tag missing)"
        assert self.MIPS.c16.length == 1, "non-immediate csetbounds broken"
        assert self.MIPS.c6.t, "immediate csetbounds broken (tag missing)"
        assert self.MIPS.c6.length == 1, "immediate csetbounds broken"

    def test_length_minus_one(self):
        self.assertCp2Fault(self.MIPS.s0, cap_reg=1,
            cap_cause=self.MIPS.CapCause.Length_Violation, trap_count=1)
