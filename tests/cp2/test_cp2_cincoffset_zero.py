#-
# Copyright (c) 2015 Michael Roe
# Copyright (c) 2019 Alex Richardson
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

@attr('capabilities')
class test_cp2_cincoffset_zero(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 2

    def test_cp2_cincoffset_zero_1(self):
        '''Test that CIncOffset with an offset of zero can copy a sealed capability'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "Test did not run to completion")

    def test_cp2_cincoffset_zero_2(self):
        '''Test that CIncOffset with an offset of zero copied the permissions field of a sealed capability'''
        self.assertRegisterEqual(self.MIPS.a1, 7, "cincoffset with an offset of zero did not copy the permissions field of a sealed capability")

    def test_cmove_works(self):
        self.assertTrapInfoNoTrap(self.MIPS.s0, "CMove should not trap with a sealed capability")
        self.assertCapabilitiesEqual(self.MIPS.c3, self.MIPS.c2)

    def test_cincoffset_reg0_works(self):
        self.assertTrapInfoNoTrap(self.MIPS.s1, "CIncOffset $zero should not trap with a sealed capability")
        self.assertCapabilitiesEqual(self.MIPS.c4, self.MIPS.c2)

    def test_cincoffsetimm_value0_traps(self):
        '''Test that CIncOffset with an offset of zero copied the permissions field of a sealed capability'''
        self.assertCp2Fault(self.MIPS.s3, cap_reg=2, cap_cause=self.MIPS.CapCause.Seal_Violation,
                            msg="CIncOffsetImm with value zero should trap with a sealed capability")
        self.assertNullCap(self.MIPS.c5)

    def test_cincoffset_value0_traps(self):
        '''Test that CIncOffset with an offset of zero copied the permissions field of a sealed capability'''
        self.assertCp2Fault(self.MIPS.s3, cap_reg=2, cap_cause=self.MIPS.CapCause.Seal_Violation,
                            msg="CIncOffset with value zero should trap with a sealed capability")
        self.assertNullCap(self.MIPS.c6)
