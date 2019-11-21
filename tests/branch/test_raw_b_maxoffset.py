#-
# Copyright (c) 2011 Steven J. Murdoch
# Copyright (c) 2012 Robert M. Norton
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


class test_raw_b_maxoffset(BaseBERITestCase):
    def test_before_branch__exec(self):
        assert self.MIPS.a0 == 1, "instruction before branch missed"

    def test_at_branch_delay_slot_exec(self):
        """'Test instruction in branch delay slot is executed"""
        assert self.MIPS.a1 == 1, "instruction in branch-delay slot missed"

    def test_after_branch_delay_slot_not_exec(self):
        """Test instruction after branch delay slot is not executed"""
        assert self.MIPS.a2 != 1, "branch failed to skip instruction"

    def test_before_branch_target_not_exec(self):
        """Test instruction before branch target is not executed"""
        assert self.MIPS.a3 != 1, "branch failed to skip instruction"

    def test_at_branch_target_exec(self):
        """Test instruction at branch target is executed"""
        assert self.MIPS.a4 == 1, "branch target missed"
