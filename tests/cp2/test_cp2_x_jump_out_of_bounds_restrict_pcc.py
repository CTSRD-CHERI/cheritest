#-
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

from beritest_baseclasses import BERITestBaseClasses


class test_cp2_x_jump_out_of_bounds_restrict_pcc(BERITestBaseClasses.BranchOutOfBoundsTestCase):
    msg = " JR out of range of PCC"
    branch_offset = 7 * 4

    def test_last_instr_executed(self):
        assert self.MIPS.a7 == 0xf00d, "final li before end of $pcc not executed?"

    def test_epcc_offset(self):
        # epcc offset should be exactly the end of $pcc
        assert self.MIPS.c25.length == self.MIPS.c25.offset
        assert self.MIPS.c25.offset == 8

    def test_epcc_length(self):
        # epcc should contain the restricted $pcc wiht only 8 bytes length
        assert self.MIPS.c25.length == 8
