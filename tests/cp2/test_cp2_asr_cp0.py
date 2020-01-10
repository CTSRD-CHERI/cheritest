#-
# Copyright (c) 2019 Alex Richardson
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
from beritest_tools import BaseBERITestCase, attr, HexInt

@attr('capabilities')
class test_cp2_asr_cp0(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 6
    # check that we intially have asr, then don't and then restored it again
    def test_asr_perm_kernel_1(self):
        assert self.MIPS.c1.t, "c1 Should be a valid cap"
        assert self.MIPS.c1.has_perms(self.permission_bits.AccessSystemRegs), "Initial PCC should have ASR"
    def test_asr_perm_kernel_2(self):
        assert self.MIPS.c2.t, "c2 Should be a valid cap"
        assert not self.MIPS.c2.has_perms(self.permission_bits.AccessSystemRegs), "second PCC should no longer have ASR"
    def test_asr_perm_kernel_3(self):
        assert self.MIPS.c3.t, "c3 Should be a valid cap"
        assert self.MIPS.c3.has_perms(self.permission_bits.AccessSystemRegs), "third PCC should have ASR again"

    def test_prid_read_kernel_asr(self):
        assert self.MIPS.a0 != HexInt(-1), "Should have read PrID"
    def test_prid_read_kernel_asr_cause(self):
        self.assertTrapInfoNoTrap(self.MIPS.s0)
    def test_tlbwi_read_kernel_asr_cause(self):
        self.assertTrapInfoNoTrap(self.MIPS.s1, msg="tlbwi should succeed in kernel with ASR")

    def test_prid_read_kernel_no_asr(self):
        assert self.MIPS.a1 == HexInt(-1), "Should not have read PrID"
    def test_prid_read_kernel_no_asr_cause(self):
        self.assertCp2Fault(self.MIPS.s2, cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation, trap_count=1,
                            msg="mcf0 should not succeed in kernel mode without ASR")
    def test_tlbwi_read_kernel_no_asr_cause(self):
        self.assertCp2Fault(self.MIPS.s3, cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation, trap_count=2,
                            msg="tlbwi should not succeed in kernel mode without ASR")

    def test_prid_read_kernel_asr_restored(self):
        assert self.MIPS.a4 != HexInt(-1), "Should have read PrID"
    def test_prid_read_kernel_asr_restored(self):
        self.assertTrapInfoNoTrap(self.MIPS.a5)


    # In userspace with ASR we should get the CP0 unusable exception
    def test_prid_read_user_asr(self):
        assert self.MIPS.a2 == HexInt(-1), "Should not have read PrID"
    def test_prid_read_user_asr_cause(self):
        self.assertCompressedTrapInfo(self.MIPS.s4, mips_cause=self.MIPS.Cause.COP_Unusable, trap_count=3,
                                      msg="mcf0 should not succeed in user mode with ASR (COP_UNSUABLE expected)")
    def test_tlbwi_read_user_asr_cause(self):
        self.assertCompressedTrapInfo(self.MIPS.s5, mips_cause=self.MIPS.Cause.COP_Unusable, trap_count=4,
                                      msg="mcf0 should not succeed in user mode with ASR (COP_UNSUABLE expected)")

    # But without ASR, the ASR fault is checked first.
    def test_prid_read_user_no_asr(self):
        assert self.MIPS.a3 == HexInt(-1), "Should not have read PrID"
    def test_prid_read_user_no_asr_cause(self):
        self.assertCompressedTrapInfo(self.MIPS.s6, mips_cause=self.MIPS.Cause.COP_Unusable, trap_count=5,
                                      msg="mcf0 should not succeed in user mode without ASR (COP_UNSUABLE expected)")
    def test_tlbwi_read_user_no_asr_cause(self):
        self.assertCompressedTrapInfo(self.MIPS.s7, mips_cause=self.MIPS.Cause.COP_Unusable, trap_count=6,
                                      msg="mcf0 should not succeed in user mode without ASR (COP_UNSUABLE expected)")

    # check that we intially have asr, and don't in the second case
    def test_asr_perm_user_1(self):
        assert self.MIPS.c10.t, "c10 Should be a valid cap"
        assert self.MIPS.c10.has_perms(self.permission_bits.AccessSystemRegs), "Initial userspace PCC should have ASR"
    def test_asr_perm_user_2(self):
        assert self.MIPS.c11.t, "c11 Should be a valid cap"
        assert not self.MIPS.c11.has_perms(self.permission_bits.AccessSystemRegs), "second userspace PCC should no longer have ASR"
