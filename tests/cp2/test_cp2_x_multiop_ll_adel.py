#-
# Copyright (c) 2015 Michael Roe
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

from beritest_tools import BaseBERITestCase
from beritest_tools import attr

class test_cp2_x_multiop_ll_adel(BaseBERITestCase):
    @attr('capabilities')
    @attr('cached')
    def test_cp2_x_multiop_ll_adel_cllc(self):
        # This one should always trap:
        self.assertCompressedTrapInfo(self.MIPS.c4,
            mips_cause=self.MIPS.Cause.AdEL,
            trap_count=1, msg="unaligned cllc should fail")

    @attr('capabilities')
    @attr('cached')
    def test_cp2_x_multiop_ll_adel_cllb(self):
        # cllb one should never trap:
        self.assertNullCap(self.MIPS.c5, msg="cllb should work at any alignment")

    @attr('capabilities')
    @attr('cached')
    def test_cp2_x_multiop_ll_adel_unalign_trap(self):
        self.assertCompressedTrapInfo(self.MIPS.c6,
            mips_cause=self.MIPS.Cause.AdEL,
            trap_count=2, msg="unaligned cllh should fail")
        self.assertCompressedTrapInfo(self.MIPS.c7,
            mips_cause=self.MIPS.Cause.AdEL,
            trap_count=3, msg="unaligned cllw should fail")
        self.assertCompressedTrapInfo(self.MIPS.c8,
            mips_cause=self.MIPS.Cause.AdEL,
            trap_count=4, msg="unaligned clld should fail")
        # If we trap on unaligned csd/cld we should get 4 exceptions here
        self.assertRegisterEqual(self.MIPS.v0, 4, "Unexpected number of exceptions raised during test of multiple operations raising AdEL")

