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
class test_magic_nop_memset(BaseBERITestCase):
    def test_start_byte_before_memset(self):
        assert self.MIPS.s0 == HexInt(0xaa)

    def test_end_byte_before_memset(self):
        assert self.MIPS.s1 == HexInt(0xaa)

    # a6 contains begin_data
    def test_return_value(self):
        assert self.MIPS.s2 == self.MIPS.a6, "memset should return begin_data"

    def test_magic_nop_called(self):
        assert self.MIPS.s3 == HexInt(0xDEC0DED), "magic function selector $v1 should be changed to 0xDEC0DED after call"

    def test_start_byte_after_memset(self):
        assert self.MIPS.s4 == HexInt(0x12)

    def test_last_byte_after_memset(self):
        assert self.MIPS.s5 == HexInt(0x12)

    def test_one_past_end_after_memset(self):
        assert self.MIPS.s6 == HexInt(0xaa)

    def test_two_past_end_after_memset(self):
        assert self.MIPS.s7 == HexInt(0xff)
