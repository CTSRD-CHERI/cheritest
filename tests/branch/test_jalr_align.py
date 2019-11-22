#-
# Copyright (c) 2014 Michael Roe
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


class test_jalr_align(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 1

    def test_jalr_align_trap_info(self):
        '''Test that CP0.Cause.ExcCode was set to AdEL after jalr to unaligned address'''
        self.assertCompressedTrapInfo(self.MIPS.s1, mips_cause=self.MIPS.Cause.AdEL)

    def test_jalr_align_vaddr(self):
        self.assertRegisterEqual(self.MIPS.a4, self.MIPS.a3, "BadVAddr was not set correctly after jalr to unaligned address")

    def test_jalr_align_epc(self):
        self.assertRegisterEqual(self.MIPS.a5, self.MIPS.a3, "EPC was not set correctly after jalr to unaligned address")

    def test_jalr_align_continue(self):
        assert self.MIPS.a2 == 1, "Did not continue after branch delay slot"

    def test_jalr_subroutine_call1(self):
        assert self.MIPS.a6 == 0, "Should have skipped first instr in subroutine"

    def test_jalr_subroutine_call2(self):
        assert self.MIPS.a7 == 1, "Should not skip second instr in subroutine"

    def test_jalr_ra_should_be_set(self):
        assert self.MIPS.a1 == self.MIPS.s2, "$ra should be set to &exit, fault happens on target not on call!"
