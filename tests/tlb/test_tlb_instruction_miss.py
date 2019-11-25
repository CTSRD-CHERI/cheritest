#-
# Copyright (c) 2011 Robert N. M. Watson
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
from beritest_tools import attr, xfail_on

@attr('tlb')
class test_tlb_instruction_miss(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 1
    def test_epc(self):
        self.assertRegisterEqual(self.MIPS.a5, 0xbeef, "Translated instructions didn't run")

    def test_badVaddr(self):
        self.assertRegisterEqual(self.MIPS.a4, self.MIPS.a6, "Bad Virtual Address is incorrect")

    def test_badVictim(self):
        self.assertRegisterEqual(self.MIPS.a4, self.MIPS.a7, "EPC is incorrect")

    def test_context(self):
        self.assertRegisterMaskEqual(self.MIPS.s0, 0xffffffffff800000, 0xfeedfacede800000, "tlb context ptebase incorrect")
        self.assertRegisterMaskEqual(self.MIPS.s0, 0x7ffff0, (self.MIPS.a4 >> 9) & 0x7ffff0, "tlb context vpn2 incorrect")
        self.assertRegisterMaskEqual(self.MIPS.s0, 0xf, 0, "tlb context 3..0 incorrect")
        
    @xfail_on('qemu')
    def test_xcontext_ptebase(self):
        self.assertRegisterMaskEqual(self.MIPS.s1, 0xfffffffe00000000, 0xafadedca00000000, "tlb xcontext ptebase incorrect")
        self.assertRegisterMaskEqual(self.MIPS.s1, 0x1fffffff0, (self.MIPS.a4 >> 9) & 0x7ffff0, "tlb xcontext r/ vpn2 incorrect")
        self.assertRegisterMaskEqual(self.MIPS.s1, 0xf, 0, "tlb xcontext 3..0 incorrect")

    @attr(beri_statcounters="tlb")
    def test_itlb_miss_statcounters(self):
        assert self.MIPS.s3 == 1, "Expected one ifetch TLB miss"

    @attr(beri_statcounters="tlb")
    def test_dtlb_miss_statcounters(self):
        assert self.MIPS.s4 == 0, "Expected zero data TLB miss"


