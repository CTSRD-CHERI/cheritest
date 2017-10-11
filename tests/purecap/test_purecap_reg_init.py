#-
# Copyright (c) 2017 Alex Richardson
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
from nose.plugins.attrib import attr


# Check that the registers used in purecap tests are initialized to usable values
class test_purecap_reg_init(BaseBERITestCase):
    @attr('capabilities')
    def test_pcc(self):
        self.assertRegisterEqual(self.MIPS.pcc.s, 0, "CP2 PCC sealed incorrectly initialised")
        self.assertRegisterAllPermissions(self.MIPS.pcc.perms, "CP2 PCC perms incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.pcc.ctype, 0x0, "CP2 PCC ctype incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.pcc.length, 0xffffffffffffffff, "CP2 PCC length incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.pcc.base, 0x0, "CP2 PCC base incorrectly initialised")

    @attr('capabilities')
    def test_other_capregs(self):
        self.assertDefaultCap(self.MIPS.cp2[0], "$ddc")
        for regnum in range(0, 31):
            name = "$c" + str(regnum)
            cap = self.MIPS.cp2[regnum]
            if regnum == 0:
                self.assertDefaultCap(cap, name + " (DDC)")
            elif regnum == 11:
                self.assertDefaultCap(cap, name + " (stack cap)")
                # FIXME: this will change once nosp is merged:
                # self.assertDefaultCap(cap, name + " (stack cap)", expected_offset=self.MIPS.sp)
            elif regnum == 12:
                self.assertDefaultCap(cap, name + " (jump cap)", expected_offset=self.MIPS.t9)
            elif regnum == 17:
                self.assertDefaultCap(cap, name + " (link cap)", expected_offset=self.MIPS.ra)
            elif regnum >= 27:
                # the kernel capabilities C27 - C31 should be default caps
                self.assertDefaultCap(cap, name)
            else:
                # All other capability registers should be null
                self.assertNullCap(cap, name)
