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
class test_cp2_magic_memcpy_clears_tags(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 0

    # a6 contains begin_data
    def test_return_value(self):
        assert self.MIPS.s2 == self.MIPS.a6, "memset should return begin_data"

    def test_magic_nop_called(self):
        assert self.MIPS.s3 == HexInt(0xDEC0DED), "magic function selector $v1 should be changed to 0xDEC0DED after call"

    def test_byte_after_memset(self):
        assert self.MIPS.s4 == HexInt(0xab), "should not change byte after end_data"

    def test_last_byte_after_memset(self):
        assert self.MIPS.s5 == HexInt(0x11), "byte before end_data should be cleared"

    def test_tag_before_memset(self):
        assert self.MIPS.c4.t == 1, "tag should be set before memset"

    def test_tag_after_memset(self):
        # self.assertNullCap(self.MIPS.c5, msg="Should be a untagged null cap after memset")
        assert self.MIPS.c5.t == 0, "tag should NOT be set after memset"
        assert self.MIPS.c5.address == HexInt(0x1111111111111111), "cursor should be all 0x11 after memset"

    def test_cap2_tag_before_memset(self):
        assert self.MIPS.c6.t == 1, "tag should be set before memset"

    def test_cap2_tag_after_memset(self):
        # The initial implementation of magic memset only cleared the first tag
        # -> check that we clear the tag for cap2 as well
        # self.assertNullCap(self.MIPS.c5, msg="Should be a untagged null cap after memset")
        assert self.MIPS.c7.t == 0, "second cap tag should NOT be set after memset"
        assert self.MIPS.c7.address == HexInt(0x1111111111111111), "cursor should be all 0x11 after memset"

    def test_small_buffer_caps_before(self):
        assert self.MIPS.c10.t == 1, "small buffer first tag should be set before memcpy"
        assert self.MIPS.c11.t == 1, "small buffer second tag should be set before memcpy"

    def test_small_buffer_cap1_after(self):
        assert self.MIPS.c12.t == 0, "small buffer first tag should NOT be set after memcpy"
        assert self.MIPS.c12.address  == HexInt(0x1111111111111111), "cursor should be all 0x11 after memcpy"

    def test_small_buffer_cap2_after(self):
        assert self.MIPS.c13.t == 1, "small buffer second tag should still be set after memcpy"
        assert self.MIPS.c13.offset == HexInt(0x1234), "second cap cursor should be unchanged after memset"

