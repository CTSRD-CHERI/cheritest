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
# Test a ccall_fast
#
@attr('capabilities')
@attr('ccall_hw_2')
class test_cp2_ccall_fast_no_bdelay(BaseBERITestCase):
    def test_no_exceptions(self):
        self.assertRegisterEqual(self.MIPS.v0, 0, "Should not have trapped!")

    def test_insn_after_not_executed(self):
        self.assertDefaultCap(self.MIPS.c4, "The CGetNull in the instruction after CCall should not have been executed (no more branch delay slot)")

    def test_sandbox_called(self):
        self.assertIntCap(self.MIPS.c5, 0x0de1a1, "Sandbox should have run!")
