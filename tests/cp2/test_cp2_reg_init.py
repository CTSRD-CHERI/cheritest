#-
# Copyright (c) 2011 Robert N. M. Watson
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

import itertools
import os

#
# Check that a variety of CHERI specification properties are true.
#
# XXXRW notes:
#
# 1. The CHERI specification doesn't (quite) say what state the unsealed bit
#    should be in.  I am assuming 1 for all capabilities.
# 2. The CHERI specification doesn't say what type should be used.  I am
#    assuming 0x0 for all capabilities.
# 3. The CHERI specification suggests an initial base value of 2^64-1 for
#    general-purpose registers.  I am using 0 because that way we universally
#    use base 0x0 length 0x0 perms 0x0 for the 'null' capability -- except
#    for unsealed.  This might not be right -- unclear.
# 4. We don't currently have a syntax for indexed inspection of capability
#    registers, which is highly desirable for the general-purpose range.
#

class test_cp2_reg_init(BaseBERITestCase):

    @attr('capabilities')
    def test_cp2_reg_init_pcc_base(self):
        '''Test that CP2 register PCC.base is correctly initialised'''
        self.assertRegisterEqual(self.MIPS.pcc.base, 0x0, "CP2 PCC base incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_pcc_len(self):
        self.assertRegisterEqual(self.MIPS.pcc.length, 0xffffffffffffffff, "CP2 PCC length incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_pcc_otype(self):
        self.assertRegisterEqual(self.MIPS.pcc.ctype, 0x0, "CP2 PCC ctype incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_pcc_perms(self):
        self.assertRegisterAllPermissions(self.MIPS.pcc.perms, "CP2 PCC perms incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_pcc_unsealed(self):
        self.assertRegisterEqual(self.MIPS.pcc.s, 0, "CP2 PCC sealed incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_rest_base(self):
        '''Test that CP2 general-purpose register bases are correctly initialised'''
        for i in range(1, 26):
            self.assertRegisterEqual(self.MIPS.cp2[i].base, 0x0, "CP2 capability register bases incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_rest_length(self):
        '''Test that CP2 general-purpose register lengths are correctly initialised'''
        for i in range(1, 26):
            self.assertRegisterEqual(self.MIPS.cp2[i].length, 0xffffffffffffffff, "CP2 capability register lengths incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_rest_ctype(self):
        '''Test that CP2 general-purpose register ctypes are correctly initialised'''
        for i in range(1, 26):
            self.assertRegisterEqual(self.MIPS.cp2[i].ctype, 0x0, "CP2 capability register ctypes incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_rest_perms(self):
        '''Test that CP2 general-purpose register perms are correctly initialised'''
        for i in range(1, 26):
            self.assertRegisterAllPermissions(self.MIPS.cp2[i].perms, "CP2 capability register perms incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_rest_unsealed(self):
        '''Test that CP2 general-purpose register unsealeds are correctly initialised'''
        for i in range(1, 26):
            self.assertRegisterEqual(self.MIPS.cp2[i].s, 0, "CP2 capability register sealed incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_unused_hwregs(self):
        '''Test that all cap hwregs that aren't defined in the spec are None'''
        for t in self.MIPS.threads.values():
            for i in itertools.chain(range(2, 8), range(9, 22), range(24, 29)):
                self.assertIsNone(t.cp2_hwregs[i], msg="Hwreg " + str(i) + " should not exist")

    def _test_mirrored_hwreg(self, name, number):
        for t in self.MIPS.threads.values():
            self.assertDefaultCap(getattr(t, name), msg="$" + name + " incorrect")
            # TODO: this will change once $c0 is $cnull
            self.assertDefaultCap(t.cp2[number], msg="$c" + str(number) + " != $" + name + "?")
            self.assertDefaultCap(t.cp2_hwregs[number], msg="cap_hwr " + str(number) + " != $" + name + "?")

    @attr('capabilities')
    def test_cp2_reg_init_ddc(self):
        '''Check that $ddc is correctly initialized to be the full addrespace'''
        for t in self.MIPS.threads.values():
            self.assertDefaultCap(t.ddc, msg="t.ddc should be a default cap")
            self.assertDefaultCap(t.cp2_hwregs[0], msg="cap_hwr 0 (ddc) should be a default cap")

    @attr('capabilities')
    def test_cp2_reg_init_c0(self):
        '''Check that c0 is correctly initialized (either as $ddc or $cnull)'''
        for t in self.MIPS.threads.values():
            if self.MIPS.CHERI_C0_IS_NULL:
                self.assertNullCap(t.cp2[0], msg="C0 should be the null register")
                self.assertNotEqual(t.cp2[0], t.cp2_hwregs[0], msg="C0 should not be a mirror of caphwr ddc")
            else:
                self.assertDefaultCap(t.cp2[0], msg="C0 should be ddc")
                self.assertCapabilitiesEqual(t.cp2[0], t.cp2_hwregs[0], msg="C0 should be a mirror of mirrored caphwr ddc")

    @attr('capabilities')
    def test_cp2_reg_init_usertls_null(self):
        for t in self.MIPS.threads.values():
            self.assertNullCap(t.cp2_hwregs[1], msg="user tls reg should be null on reset")

    @attr('capabilities')
    def test_cp2_reg_init_privtls_null(self):
        for t in self.MIPS.threads.values():
            self.assertNullCap(t.cp2_hwregs[8], msg="privileged tls reg should be null on reset")

    @attr('capabilities')
    def test_cp2_reg_init_hwreg_kr1c_null(self):
        for t in self.MIPS.threads.values():
            self.assertNullCap(t.cp2_hwregs[22], msg="caphwr kr1c should be null on reset")

    @attr('capabilities')
    def test_cp2_reg_init_hwreg_kr2c_null(self):
        for t in self.MIPS.threads.values():
            self.assertNullCap(t.cp2_hwregs[23], msg="caphwr kr1c should be null on reset")

    @attr('capabilities')
    def test_cp2_reg_init_kcc(self):
        self._test_mirrored_hwreg("kcc", 29)

    @attr('capabilities')
    def test_cp2_reg_init_kdc(self):
        self._test_mirrored_hwreg("kdc", 30)

    @attr('capabilities')
    def test_cp2_reg_init_epcc(self):
        self._test_mirrored_hwreg("epcc", 31)
