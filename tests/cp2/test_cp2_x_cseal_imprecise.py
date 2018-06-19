#-
# Copyright (c) 2016 Michael Roe
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

from beritest_tools import BaseBERITestCase, is_feature_supported
from beritest_tools import attr


@attr('capabilities')
@attr('cap_imprecise')
class test_cp2_x_cseal_imprecise(BaseBERITestCase):

    def test_maybe_unrep(self):
        # New QEMU implementation can actuall represent this:
        if is_feature_supported('improved_cheri_cc'):
            self.assertNullCap(self.MIPS.c4, "Should not have caused a trap")
            assert self.MIPS.c3.ctype == 0x11
            assert self.MIPS.c3.base == 0x101
            assert self.MIPS.c3.length == 0x101
            assert self.MIPS.c3.offset == 0
            assert self.MIPS.c3.t
            assert self.MIPS.c3.s
        else:
            self.assertNullCap(self.MIPS.c3, "Should not have changed capreg")
            self.assertCp2Fault(self.MIPS.c4, cap_reg=1, cap_cause=self.MIPS.CapCause.Bounds_Not_Exactly_Representable, trap_count=1)

    def test_definitely_unrepresenatable(self):
        trap_count = 1 if is_feature_supported('improved_cheri_cc') else 2
        self.assertCp2Fault(self.MIPS.c7, cap_reg=1, cap_cause=self.MIPS.CapCause.Bounds_Not_Exactly_Representable, trap_count=trap_count)
        self.assertNullCap(self.MIPS.c6, "Should not have changed capreg")

