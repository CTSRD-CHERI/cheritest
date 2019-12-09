#
# Copyright (c) 2019 Alex Richardson
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

from beritest_tools import BaseBERITestCase, attr, HexInt

#
# Test a ccall with addr check
#
@attr('capabilities')
@attr('sentry_caps')
class test_cp2_sentry(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 8

    def test_good_return_value(self):
        assert self.MIPS.a0 == 42, "test did not run to completion"

    def test_num_sandbox_calls(self):
        assert self.MIPS.a7 == 6, "Should call the sandbox 6 times"

    def test_attributes_sealed(self):
        assert self.MIPS.a1 == 1, "cgetsealed $a1, $c1 should return true"
        assert self.MIPS.c1.s

    def test_attributes_perm(self):
        assert self.MIPS.a2 == self.max_permissions, "cgetperm $a2, $c1 should return max exec perms"
        assert self.MIPS.c1.perms == self.max_permissions

    def test_attributes_base(self):
        assert self.MIPS.a3 == 0, "cgetbase $a3, $c1 wrong"
        assert self.MIPS.c1.base == 0

    def test_attributes_offset(self):
        assert self.MIPS.a4 == self.MIPS.c12.offset, "cgetoffset $a4, $c1 wrong"
        assert self.MIPS.c1.offset == self.MIPS.c12.offset

    def test_attributes_len(self):
        assert self.MIPS.a5 == self.MIPS.c12.length, "cgetlen $a5, $c1 wrong"
        assert self.MIPS.c1.length == self.MIPS.c12.length

    def test_attributes_tag(self):
        assert self.MIPS.a6 == 1, "cgettag $a6, $c1 wrong"
        assert self.MIPS.c1.t

    def test_attributes_type(self):
        assert self.MIPS.t8 == self.sentry_otype, "cgettype $t3, $c1 should be -2"
        assert self.MIPS.c1.ctype == self.sentry_otype

    def test_good_csealcode(self):
        self.assertTrapInfoNoTrap(self.MIPS.s0, msg="CSealCode with normal $pcc should succeed")
        assert self.MIPS.c1.s == 1, "Result of csealcode should be sealed!"

    def test_bad_csealcode_permit_execute(self):
        self.assertCp2Fault(self.MIPS.s1, cap_cause=self.MIPS.CapCause.Permit_Execute_Violation,
                            cap_reg=4, msg="CSealCode without Permit_Execute should trap", trap_count=1)

    def test_cseal_worked(self):
        self.assertTrapInfoNoTrap(self.MIPS.s2, msg="CSeal should work")
        assert self.MIPS.c7.s == 1, "$c7 should be sealed"

    def test_bad_csealcode_sealed_source(self):
        self.assertCp2Fault(self.MIPS.s3, cap_cause=self.MIPS.CapCause.Seal_Violation,
                            cap_reg=7, msg="CSealCode without sealed source cap should trap", trap_count=2)

    def test_sentry_immutable_cincoffset(self):
        self.assertCp2Fault(self.MIPS.s4, cap_cause=self.MIPS.CapCause.Seal_Violation,
                            cap_reg=1, msg="CIncOffset (nonzero offset) on sentry cap should trap", trap_count=3)

    def test_sentry_immutable_candperm(self):
        self.assertCp2Fault(self.MIPS.s5, cap_cause=self.MIPS.CapCause.Seal_Violation,
                            cap_reg=1, msg="CAndPerm (nonzero offset) on sentry cap should trap", trap_count=4)

    def test_sentry_immutable_cmove_ok(self):
        self.assertTrapInfoNoTrap(self.MIPS.s6, msg="CMove on sentry should work")
        assert self.MIPS.c19.s == 1, "$c21 should be sealed"

    def test_sentry_immutable_cincoffset_0(self):
        self.assertTrapInfoNoTrap(self.MIPS.s7, msg="CIncOffset 0 on sentry should work")
        assert self.MIPS.c20.s == 1, "$c22 should be sealed"

    def test_sentry_no_load_permitted(self):
        self.assertCp2Fault(self.MIPS.t2, cap_cause=self.MIPS.CapCause.Seal_Violation,
                            cap_reg=1, msg="Loading via sentry cap should trap", trap_count=8)
        assert self.MIPS.t3 == 0xbad

    def test_unsealed_call_perm_load(self):
        self.assertIntCap(self.MIPS.c21, 0x1234, "Unsealed call should be able to load value")

    def test_unsealed_call_no_load(self):
        self.assertIntCap(self.MIPS.c22, 0xbad, "Unsealed call without perm_exe should not load")

    def test_sentry_cjalr_perm_load(self):
        self.assertIntCap(self.MIPS.c23, 0x1234, "Sentry cjalr should be able to load value")

    def test_unsealed_cjalr_noload(self):
        self.assertIntCap(self.MIPS.c24, 0xbad, "Sentry cjalr without perm_exe should not load")

    def test_sentry_cjr_perm_load(self):
        self.assertIntCap(self.MIPS.c25, 0x1234, "Sentry cjr should be able to load value")

    def test_unsealed_cjr_noload(self):
        self.assertIntCap(self.MIPS.c26, 0xbad, "Sentry cjr without perm_exe should not load")
