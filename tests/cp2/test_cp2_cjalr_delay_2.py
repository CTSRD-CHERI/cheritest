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
from beritest_tools import BaseBERITestCase, attr


@attr('capabilities')
class test_cp2_cjalr_delay_2(BaseBERITestCase):
    def test_cjalr_return_cap_in_delay_slot(self):
        '''Test that the new value of $c17 is available in the delay slot'''
        self.assertRegisterEqual(self.MIPS.c4.offset, self.MIPS.t0 - 8, "return address offset wrong")
        self.assertCapabilitiesEqual(self.MIPS.c4, self.MIPS.c17, "storing $c17 in the delay slot should yield the link address")

    def test_cjalr_return_cap_after_delay_slot(self):
        self.assertRegisterEqual(self.MIPS.c5.offset, self.MIPS.t0 - 8, "return address offset wrong")
        self.assertRegisterEqual(self.MIPS.c17.offset, self.MIPS.t0 - 8, "return address offset wrong")

    def test_cjalr_jump_cap_after_delay_slot(self):
        self.assertRegisterEqual(self.MIPS.c6.offset, self.MIPS.t0, "jump cap modified by cjalr?")
        self.assertRegisterEqual(self.MIPS.c12.offset, self.MIPS.t0, "jump cap modified by cjalr?")

    def test_jalr_return_addr_in_delay_slot(self):
        '''Test that the new value of $ra is available in the delay slot'''
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.t9 - 8, "return address wrong")

    def test_jalr_return_addr_after_delay_slot(self):
        self.assertRegisterEqual(self.MIPS.a1, self.MIPS.t9 - 8, "return address wrong")

    def test_jalr_jump_addr_after_delay_slot(self):
        self.assertRegisterEqual(self.MIPS.a2, self.MIPS.t9, "jump address modified by jalr?")
