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
class test_magic_nop_memset_tlb_miss(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 3
    BAD_ADDRESS = 0x0001000000100000

    def test_store_byte_traps(self):
        self.assertCompressedTrapInfo(self.MIPS.s0, mips_cause=self.MIPS.Cause.AdES,
            trap_count=1, msg="lbu from bad address should trap")

    def test_magic_memset_traps(self):
        self.assertCompressedTrapInfo(self.MIPS.s1, mips_cause=self.MIPS.Cause.AdES,
            trap_count=2, msg="magic memset nop from bad address should trap with ades")

    def test_magic_memset_traps_on_continue(self):
        self.assertCompressedTrapInfo(self.MIPS.s7, mips_cause=self.MIPS.Cause.AdES,
            trap_count=3, msg="magic memset nop from bad address should trap with ades")

    def test_return_value(self):
        assert self.MIPS.s2 == self.BAD_ADDRESS, "On miss $v0 should contain the orignal $v1 arg"

    def test_selector_value(self):
        assert self.MIPS.s3 == 0xbadc0de00000001, "Continuation flag + memset selector should be set in $v1"

    def test_a0_after_first_call(self):
        assert self.MIPS.s4 == self.BAD_ADDRESS, "$a0 should not be modified on trap"

    def test_a1_after_first_call(self):
        assert self.MIPS.s5 == 0x12, "$a1 should not be modified on trap"

    def test_a2_after_first_call(self):
        assert self.MIPS.s6 == 4095, "$a1 should not be modified on trap"

    def test_return_value_after_second_call(self):
        assert self.MIPS.a5 == self.BAD_ADDRESS, "On second call the helper should use the saved $v0 register and not update it to $a0"

    def test_selector_value_after_second_call(self):
        assert self.MIPS.s3 == 0xbadc0de00000001, "Continuation flag + memset selector should be set in $v1"

    def test_a0_after_second_call(self):
        assert self.MIPS.a0 == self.BAD_ADDRESS + 1, "$a0 should still be BAD_ADDR + 1"

    def test_a1_after_second_call(self):
        assert self.MIPS.a1 == 0x12, "$a1 should not be modified by second call"

    def test_a2_after_second_call(self):
        assert self.MIPS.a2 == 4094, "$a1 should not be modified by second call"
