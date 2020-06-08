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
from beritest_tools import BaseBERITestCase, attr

@attr(beri_statcounters="icount")
class test_raw_loop_icount(BaseBERITestCase):
    def test_result(self):
        '''Test that MOVZ does not change the value of $zero'''
        self.assertRegisterEqual(self.MIPS.t0, self.minus_one_as_u64, "Loop should terminate when t0 is zero")

    def test_start_icount_nonzero(self):
        assert self.MIPS.s0 != 0, "icount should be nonzero"

    def test_start_icount_after_one_instr(self):
        assert self.MIPS.s1 == self.MIPS.s0 + 1, "icount should be one more after one inst"

    def test_start_icount_nonzero(self):
        assert self.MIPS.s2 == self.MIPS.s0 + 3 + (3 * 2), "icount after loop wrong"
