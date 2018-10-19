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

from beritest_tools import BaseBERITestCase, attr, HexInt

@attr("qemu_magic_nops")
class test_magic_memset_tlb_miss2(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 1

    def test_badvaddr(self):
        self.assertRegisterEqual(self.MIPS.s0, self.MIPS.a4, "Wrong BadVaddr")

    def test_context(self):
        self.assertRegisterEqual(self.MIPS.s1, (self.MIPS.a4 & 0xffffe000)>>9, "Wrong Context") # TODO test page table base

    def test_xcontext(self):
        self.assertRegisterEqual(self.MIPS.s2, (self.MIPS.a4 & 0xffffe000)>>9, "Wrong XContext") # TODO test page table base

    def test_entryhi(self):
        self.assertRegisterMaskEqual(self.MIPS.a4, 0xfffff000, self.MIPS.s3, "Wrong EntryHi")

    def test_status(self):
        self.assertRegisterMaskEqual(self.MIPS.s4, 2, 2, "Wrong EXL")

    def test_epc(self):
        '''Test EPC after TLB Invalid exception'''
        # plus 12 since check_instruction_traps uses 3 instructions before invoking the actual insn
        self.assertRegisterEqual(self.MIPS.a6 + 12, self.MIPS.s6, "Wrong EPC")

    def test_testdata(self):
        self.assertRegisterEqual(self.MIPS.a7, 0xfedcba9876543210, "Wrong testdata")

    def test_trap_info(self):
        self.assertCompressedTrapInfo(self.MIPS.s5, mips_cause=self.MIPS.Cause.TLB_Store, trap_count=1)
