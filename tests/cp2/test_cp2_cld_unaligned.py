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

from beritest_tools import BaseBERITestCase, attr, HexInt, is_feature_supported

@attr('capabilities')
class test_cp2_cld_unaligned(BaseBERITestCase):
    @property
    def EXPECTED_EXCEPTIONS(self):
        if is_feature_supported("trap_unaligned_ld_st"):
            return 2     # cld + csd should trap
        return 0

    @attr("allow_unaligned")
    def test_after_store_unaliged_ok(self):
        assert self.MIPS.s0 == HexInt(0x1122334455667788)

    @attr('allow_unaligned')
    def test_tags_cleared_unaliged_ok(self):
        pass

    def test_tags_before(self):
        assert self.MIPS.c5.t, "tag should be set due to csc!"
        assert self.MIPS.c6.t, "tag should be set due to csc!"
        assert self.MIPS.c7.t, "tag should be set due to csc!"
        assert self.MIPS.c8.t, "tag should be set due to csc!"

    @attr('allow_unaligned')
    def test_tags_after_unaligned_ok(self):
        assert self.MIPS.c9.t, "tag should still be set!"
        assert not self.MIPS.c10.t, "tag should not set set due to csd across page boundary!"
        assert not self.MIPS.c11.t, "tag should not set set due to csd across page boundary!"
        assert self.MIPS.c12.t, "tag should still be set!"

    @attr('trap_unaligned_ld_st')
    def test_tags_not_cleared_unaliged_traps(self):
        assert self.MIPS.c9.t, "tag should not be cleared if unaligned store failed"
        assert self.MIPS.c10.t, "tag should not be cleared if unaligned store failed"
        assert self.MIPS.c11.t, "tag should not be cleared if unaligned store failed"
        assert self.MIPS.c12.t, "tag should not be cleared if unaligned store failed"

    @attr('trap_unaligned_ld_st')
    def test_store_traps(self):
        self.assertCompressedTrapInfo(self.MIPS.s3, mips_cause=self.MIPS.Cause.AdES, trap_count=1, msg="Store should trap (unaligned load across page boundary)")

    @attr('trap_unaligned_ld_st')
    def test_load_traps(self):
        self.assertCompressedTrapInfo(self.MIPS.s4, mips_cause=self.MIPS.Cause.AdEL, trap_count=2, msg="Load should trap (unaligned load across page boundary)")

    @attr("trap_unaligned_ld_st")
    def test_after_store_unaliged_traps(self):
        assert self.MIPS.s0 == HexInt(0xdead)
