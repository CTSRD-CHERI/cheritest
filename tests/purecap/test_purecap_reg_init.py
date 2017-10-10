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
        for regnum in range(0, 31):
            if regnum == 12 or regnum == 17:
                continue  # already handled
            regname = "$c" + str(regnum) + " "
            self.assertRegisterAllPermissions(self.MIPS.cp2[regnum].perms,
                                              regname + "should have all permissions")
            self.assertRegisterEqual(self.MIPS.cp2[regnum].s, 0,
                                     regname + "should not be sealed sealed")
            self.assertRegisterEqual(self.MIPS.cp2[regnum].ctype, 0,
                                     regname + "should not have an otype")
            self.assertRegisterEqual(self.MIPS.cp2[regnum].length, 0xffffffffffffffff,
                                     regname + "should span whole addr space")
            self.assertRegisterEqual(self.MIPS.cp2[regnum].base, 0x0,
                                     regname + "should have offset zero")
            self.assertRegisterEqual(self.MIPS.cp2[regnum].offset, 0x0,
                                     regname + "should have offset zero")
    @attr('capabilities')
    def test_c12(self):
            regname = "$c12 "
            self.assertRegisterAllPermissions(self.MIPS.cp2[regnum].perms,
                                              regname + "should have all permissions")
            self.assertRegisterEqual(self.MIPS.cp2[regnum].s, 0,
                                     regname + "should not be sealed sealed")
            self.assertRegisterEqual(self.MIPS.cp2[regnum].ctype, 0,
                                     regname + "should not have an otype")
            self.assertRegisterEqual(self.MIPS.cp2[regnum].length, 0xffffffffffffffff,
                                     regname + "should span whole addr space")
            self.assertRegisterEqual(self.MIPS.cp2[regnum].base, 0x0,
                                     regname + "should have offset zero")
            self.assertRegisterEqual(self.MIPS.cp2[regnum].offset, 0x0,
                                     regname + "should have offset zero")

    def _test_register(self, register, regname, expected_base=0x0,
                       expected_offset=0x0, expected_length=0xffffffffffffffff):
        self.assertRegisterAllPermissions(register.perms, regname + " should have all permissions")
        self.assertRegisterEqual(register.s, 0, regname + " should not be sealed sealed")
        self.assertRegisterEqual(register.ctype, 0, regname + " should not have an otype")
        self.assertRegisterEqual(register.length, expected_length, regname + " length is wrong")
        self.assertRegisterEqual(register.base, expected_base, regname + " base is wrong")
        self.assertRegisterEqual(register.offset, expected_offset, regname + " offset is wrong")

    @attr('capabilities')
    def test_c12(self):
        self._test_register(self.MIPS.cp2[12], "$c12 (jump cap)", expected_offset=self.MIPS.t9)

    @attr('capabilities')
    def test_c17(self):
        self._test_register(self.MIPS.cp2[17], "$c17 (link cap)", expected_offset=self.MIPS.ra)

    # TODO: C11 should be different once nosp is merged

    @attr('capabilities')
    def test_other_capregs(self):
        for regnum in range(0, 31):
            if regnum == 12 or regnum == 17:
                continue  # already handled
            self._test_register(self.MIPS.cp2[regnum], "$c" + str(regnum))

