#-
# Copyright (c) 2013 Michael Roe
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

from beritest_tools import BaseBERITestCase
from beritest_tools import attr

#
# Test that cbtu raises a C2E exception if the capability register is one
# of the reserved registers, and the corresponding bit in PCC is not set.
#

@attr('capabilities')
class test_cp2_x_cbtu_reg(BaseBERITestCase):
    def test_trap_count(self):
        if self.MIPS.CHERI_C27_TO_31_INACESSIBLE:
            self.assertRegisterEqual(self.MIPS.v0, 1, "cbts did not raise an exception when register was reserved")
        else:
            assert self.MIPS.v0 == 0, "c27-c31 are no longer special in the latest ISA"

    def test_exception_details(self):
        '''Test capability cause is set correctly when register was reserved'''
        if self.MIPS.CHERI_C27_TO_31_INACESSIBLE:
            self.assertCp2Fault(self.MIPS.c8, cap_reg=27, cap_cause=self.MIPS.CapCause.Access_System_Registers_Violation, trap_count=1)
        else:
            self.assertCompressedTrapInfo(self.MIPS.c8, no_trap=True, msg="c27-c31 are no longer special in the latest ISA")
