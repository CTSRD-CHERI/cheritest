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


class test_cp2_x_jump_out_of_bounds_restrict_pcc_plus_one(BERITestBaseClasses.BranchOutOfBoundsTestCase):
    msg = " reaching end of $pcc and only 1 byte remaining"
    branch_offset = 7 * 4

    def test_last_instr_executed(self):
        assert self.MIPS.a7 == 0xf00d, "final li before end of $pcc not executed?"

    def test_epcc_offset(self):
        # epcc offset should be exactly offset 8 since we couldn't read a full instruction
        assert self.MIPS.c25.offset == 8

    def test_epcc_length(self):
        # epcc should contain the restricted $pcc with only 9 bytes length (i.e. not enough for a full instruction)
        assert self.MIPS.c25.length == 9
