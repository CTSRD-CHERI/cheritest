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

from beritest_tools import BaseBERITestCase, attr
#
# Test a that CCallFast can't go in a branch delay slot
#
@attr('capabilities')
@attr('ccall_hw_2')
class test_cp2_x_ccall_fast_in_delay_slot(BaseBERITestCase):
    def test_no_exceptions(self):
        self.assertRegisterEqual(self.MIPS.v0, 1, "Should have trapped!")

    def test_sandbox_not_calledi(self):
        self.assertRegisterEqual(self.MIPS.a1, 0x1234, "Sandbox should not have been called!")

    def test_trap_cause(self):
        self.assertCompressedTrapInfo(self.MIPS.c5, mips_cause=self.MIPS.Cause.ReservedInstruction,
                trap_count=1, bdelay=True, msg="CCallFast in bdelay should cause RI trap!")
