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

from beritest_tools import BaseBERITestCase
from beritest_tools import attr

class test_cp2_csetaddr(BaseBERITestCase):

    @attr('capabilities')
    def test_cp2_csetaddr_near_0(self):
        assert self.MIPS.c2.t, "Omnipotent csetaddr to near 0 not tagged"
        assert self.MIPS.c2.offset == 0x123

    @attr('capabilities')
    def test_cp2_csetaddr_near_top(self):
        assert self.MIPS.c3.t, "Omnipotent csetaddr to near top not tagged"
        assert self.MIPS.c3.offset == 0xFFFFFFFFFFFFFEDD

    @attr('capabilities')
    def test_cp2_csetaddr_near_cheriabi_user_top(self):
        assert self.MIPS.c4.t, "Omnipotent csetaddr to near CheriABI user top not tagged"
        assert self.MIPS.c4.offset == 0x7FFF02403E

    @attr('capabilities')
    def test_cp2_csetaddr_restrict_pre(self):
        assert self.MIPS.c8.t
        assert self.MIPS.c8.base   == 0x80000
        assert self.MIPS.c8.length == 0x80000
        assert self.MIPS.c8.offset == 0

    @attr('capabilities')
    def test_cp2_csetaddr_restrict_below_base(self):
        assert self.MIPS.c9.t
        assert self.MIPS.c9.offset == 0xFFFFFFFFFFFFFFFF

    @attr('capabilities')
    def test_cp2_csetaddr_restrict_above_base(self):
        assert self.MIPS.c10.t
        assert self.MIPS.c10.offset == 1

    @attr('capabilities')
    def test_cp2_csetaddr_restrict_above_limit(self):
        assert self.MIPS.c11.t
        assert self.MIPS.c11.offset == 0x80001

    @attr('capabilities')
    def test_cp2_csetaddr_restrict_below_limit(self):
        assert self.MIPS.c12.t
        assert self.MIPS.c12.offset == 0x7FFFF
