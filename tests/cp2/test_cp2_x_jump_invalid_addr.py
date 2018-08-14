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

from beritest_tools import BaseBERITestCase
from beritest_tools import attr

#
# Test that EPC and EPCC are still in sync after a jump to a bad instruction
#

@attr('capabilities')
class test_cp2_x_jump_invalid_addr(BaseBERITestCase):
    def test_epc(self):
        self.assertRegisterEqual(self.MIPS.a4, 0x692f73757a756b69, "epc is wrong")

    def test_epcc(self):
        self.assertDefaultCap(self.MIPS.c1, offset=0x692f73757a756b69,  msg="epc is wrong")

    def test_cause(self):
        self.assertRegisterMaskEqual(self.MIPS.a3, 1 << 31, 0, "BD bit should not be set")

