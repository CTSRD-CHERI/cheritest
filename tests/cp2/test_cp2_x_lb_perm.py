#-
# Copyright (c) 2012 Michael Roe
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

from beritest_tools import BaseBERITestCase, attr, HexInt


#
# Test that lbu raises a C2E exception if c0 does not grant Permit_Load.
#
@attr('capabilities')
class test_cp2_x_lb_perm(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 1

    def test_cp2_x_lb_first_load_succeeds(self):
        '''Test lbu did not read without Permit_Load permission'''
        assert self.MIPS.a0 == 1, "lbu should read with Permit_Load permission"
        self.assertTrapInfoNoTrap(self.MIPS.s0)

    def test_cp2_x_lb_perm_not_loaded(self):
        '''Test lbu did not read without Permit_Load permission'''
        assert self.MIPS.a1 == HexInt(0xdead), "lbu should not read without Permit_Load permission"

    def test_cp2_x_lb_perm_excecption(self):
        '''Test lbu raises an exception when doesn't have Permit_Load permission'''
        self.assertCp2Fault(self.MIPS.s1, cap_cause=self.MIPS.CapCause.Permit_Load_Violation,
                            cap_reg=0, trap_count=1,
                            msg="lbu did not raise an exception when didn't have Permit_Load permission")
