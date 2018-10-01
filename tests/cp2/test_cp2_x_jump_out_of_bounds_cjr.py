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
#

from beritest_tools import BaseBERITestCase
from beritest_tools import attr

@attr('capabilities')
class test_cp2_x_jump_out_of_bounds_cjr(BaseBERITestCase):
    msg = " CJR with out of bounds cap"

    def test_epcc_offset(self):
        '''Test that EPCC.offset is set to the offset of the branch in the sandbox'''
        assert self.MIPS.c25.offset == 0x10, "EPCC.offset was not set to the expected value after" + self.msg

    def test_exception(self):
        assert self.MIPS.a2 == 1, "An exception was not raised after" + self.msg

    def test_delay_slot_not_executed(self):
        assert self.MIPS.a5 == 0x1, "Delay slot of out-of-bounds branch should not be taken after" + self.msg

    def test_epcc_tag(self):
        assert self.MIPS.c25.t, "EPCC.tag was not set to true after" + self.msg

    def test_epcc_length(self):
        assert self.MIPS.c25.length == 0x28, "EPCC.length was not set to the expected value after" + self.msg
