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

from beritest_tools import BaseBERITestCase, attr, HexInt


@attr('llsc')
class test_scd_unalign_unmatched(BaseBERITestCase):
    """
    Note: even if the CPU supports unaligned accesses (e.g. QEMU) this
    does not apply to SC. According MIPS64 spec v6.06:

    The effective address must be naturally-aligned.
    If any of the 2 least-significant bits of the address is non-zero,
    an Address Error exception occurs.
    """
    EXPECTED_EXCEPTIONS = 1

    def test_trap(self):
        self.assertCompressedTrapInfo(self.MIPS.s5, mips_cause=self.MIPS.Cause.AdES, trap_count=1)

    def test_value_not_written(self):
        assert self.MIPS.s1 == HexInt(0x5656565656565656), "value before sc wrong"
        assert self.MIPS.s2 == HexInt(0x5656565656565656), "sc stored value!"

    def test_llsc_result(self):
        # The result of SC is UNPREDICTABLE, however all of our implementations return zero
        # or leave the register unchanged on failure:
        assert self.MIPS.a7 == 0 or self.MIPS.a7 == 0x12345, "Expected sc failure return code"
