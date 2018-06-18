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
from beritest_tools import BaseBERITestCase, attr


@attr('capabilities')
class test_cp2_qemu_incoffset_negative(BaseBERITestCase):
    # Here are the before and after capabilities:
    MINUS_48_HEX = 0xffffFFFFffffFFD0
    def test_initial_cap(self):
        # (before add) t3: v:1 s:0 p:0007817d b:0000000165200000 l:0000000000004000 o:5d0 t:-1
        assert self.MIPS.threads[0].cp2[1].t
        assert not self.MIPS.threads[0].cp2[1].s
        assert self.MIPS.threads[0].cp2[1].perms == 0x7817d
        assert self.MIPS.threads[0].cp2[1].base == 0x0000000165200000
        assert self.MIPS.threads[0].cp2[1].offset == 0x5d0
        assert self.MIPS.threads[0].cp2[1].length == 0x0000000000004000

    def test_after_increment(self):
        # t3 = t3 + __intcap_t(-1536)
        assert self.MIPS.threads[0].cp2[2].t
        assert not self.MIPS.threads[0].cp2[2].s
        assert self.MIPS.threads[0].cp2[2].perms == 0x7817d
        assert self.MIPS.threads[0].cp2[2].base == 0x0000000165200000
        assert self.MIPS.threads[0].cp2[2].length == 0x0000000000004000
        # only the offset should have changed:
        assert self.MIPS.threads[0].cp2[2].offset == self.MINUS_48_HEX

    def test_after_setoffset(self):
        # setoffset should work the same as incoffset:
        # t3 = t3 + __intcap_t(-1536)
        assert self.MIPS.threads[0].cp2[3].t
        assert not self.MIPS.threads[0].cp2[3].s
        assert self.MIPS.threads[0].cp2[3].perms == 0x7817d
        assert self.MIPS.threads[0].cp2[3].base == 0x0000000165200000
        assert self.MIPS.threads[0].cp2[3].length == 0x0000000000004000
        # only the offset should have changed:
        assert self.MIPS.threads[0].cp2[3].offset == self.MINUS_48_HEX

    def test_after_store_load(self):
        # This previously generated v:1 s:0 p:0007817d b:0000000165100000 l:0000000000004000 o:fffd0 t:-1
        assert self.MIPS.threads[0].cp2[4].t
        assert not self.MIPS.threads[0].cp2[4].s
        assert self.MIPS.threads[0].cp2[4].perms == 0x7817d
        assert self.MIPS.threads[0].cp2[4].base == 0x0000000165200000
        assert self.MIPS.threads[0].cp2[4].length == 0x0000000000004000
        # only the offset should have changed:
        assert self.MIPS.threads[0].cp2[4].offset == self.MINUS_48_HEX



