#-
# Copyright (c) 2018 Alexandre Joannou
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

from beritest_tools import BaseBERITestCase, xfail_on
from beritest_tools import attr

@attr("capabilities")
class test_cp2_swr_clear_tags(BaseBERITestCase):
    def test_cap1_before(self):
        assert self.MIPS.c6.t, "Initially first cap should have tag set"

    def test_cap2_before(self):
        assert self.MIPS.c7.t, "Initially second cap should have tag set"

    def test_cap1_after_swr(self):
        assert self.MIPS.c8.t == 0, "First cap tag should be cleared after swr"

    def test_cap2_after_swr(self):
        assert self.MIPS.c9.t, "Second cap tag should NOT be cleared after swr"

    def test_cap1_after_sdr(self):
        assert self.MIPS.c10.t == 0, "First cap tag should be cleared after sdr"

    def test_cap2_after_sdr(self):
        assert self.MIPS.c11.t, "Second cap tag should NOT be cleared after sdr"

    def test_cap1_after_swl(self):
        assert self.MIPS.c12.t == 0, "First cap tag should be cleared after swl"

    def test_cap2_after_swl(self):
        assert self.MIPS.c13.t, "Second cap tag should NOT be cleared after swl"

    def test_cap1_after_sdl(self):
        assert self.MIPS.c12.t == 0, "First cap tag should be cleared after sdl"

    def test_cap2_after_sdl(self):
        assert self.MIPS.c13.t, "Second cap tag should NOT be cleared after sdl"
