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

@attr('capabilities')
class test_cp2_reg_init(BaseBERITestCase):

    def test_cp2_reg_init_pcc_base(self):
        '''Test that CP2 register PCC.base is correctly initialised'''
        self.assertRegisterEqual(self.MIPS.pcc.base, 0x0, "CP2 PCC base incorrectly initialised")

    def test_cp2_reg_init_pcc_len(self):
        self.assertRegisterEqual(self.MIPS.pcc.length, 0xffffffffffffffff, "CP2 PCC length incorrectly initialised")

    def test_cp2_reg_init_pcc_otype(self):
        self.assertRegisterEqual(self.MIPS.pcc.ctype, self.unsealed_otype, "CP2 PCC ctype incorrectly initialised")

    def test_cp2_reg_init_pcc_perms(self):
        self.assertRegisterAllPermissions(self.MIPS.pcc.perms, "CP2 PCC perms incorrectly initialised")

    def test_cp2_reg_init_pcc_unsealed(self):
        self.assertRegisterEqual(self.MIPS.pcc.s, 0, "CP2 PCC sealed incorrectly initialised")

    def test_cp2_reg_init_rest(self):
        '''Test that CP2 general-purpose register perms are correctly initialised'''
        for i in range(1, 32):
            # c12 will be set up to point to the start of the test and $c17 will be the return value
            if i == 12:
                self.assertDefaultCap(self.MIPS.cp2[i], offset=self.MIPS.a1, msg="$c12 should point to start of test fn")
            elif i == 17:
                self.assertDefaultCap(self.MIPS.cp2[i], offset=self.MIPS.a2, msg="$c17 should point to return addr")
            else:
                self.assertNullCap(self.MIPS.cp2[i], "CP2 capability register $c" + str(i) + " incorrectly initialised")

    def test_cp2_reg_init_rest_unsealed(self):
        '''Test that CP2 general-purpose register unsealeds are correctly initialised'''
        for i in range(1, 26):
            self.assertRegisterEqual(self.MIPS.cp2[i].s, 0, "CP2 capability register sealed incorrectly initialised")

    def test_cp2_reg_init_unused_hwregs(self):
        '''Test that all cap hwregs that aren't defined in the spec are None'''
        for t in self.MIPS.threads.values():
            for i in itertools.chain(range(2, 8), range(9, 22), range(24, 28)):
                self.assertIsNone(t.cp2_hwregs[i], msg="Hwreg " + str(i) + " should not exist")

    def _test_special_hwreg(self, name, number, is_null=False, **kwargs):
        for t in self.MIPS.threads.values():
            func = self.assertNullCap if is_null else self.assertDefaultCap
            func(getattr(t, name), msg="$" + name + " incorrect", **kwargs)
            func(t.cp2_hwregs[number], msg="cap_hwr " + str(number) + " != $" + name + "?", **kwargs)

    def test_cp2_reg_init_ddc(self):
        '''Check that $ddc is correctly initialized to be the full addrespace'''
        for t in self.MIPS.threads.values():
            self.assertDefaultCap(t.ddc, msg="t.ddc should be a default cap")
            self.assertDefaultCap(t.cp2_hwregs[0], msg="cap_hwr 0 (ddc) should be a default cap")

    def test_cp2_reg_init_c0(self):
        '''Check that c0 is correctly initialized (either as $ddc or $cnull)'''
        for t in self.MIPS.threads.values():
            self.assertNullCap(t.cp2[0], msg="C0 should be the null register")
            self.assertNotEqual(t.cp2[0], t.cp2_hwregs[0], msg="C0 should not be a mirror of caphwr ddc")

    def test_cp2_reg_init_usertls_null(self):
        for t in self.MIPS.threads.values():
            self.assertNullCap(t.cp2_hwregs[1], msg="user tls reg should be null on reset")

    def test_cp2_reg_init_privtls_null(self):
        for t in self.MIPS.threads.values():
            self.assertNullCap(t.cp2_hwregs[8], msg="privileged tls reg should be null on reset")

    def test_cp2_reg_init_hwreg_kr1c_null(self):
        for t in self.MIPS.threads.values():
            self.assertNullCap(t.cp2_hwregs[22], msg="caphwr kr1c should be null on reset")

    def test_cp2_reg_init_hwreg_kr2c_null(self):
        for t in self.MIPS.threads.values():
            self.assertNullCap(t.cp2_hwregs[23], msg="caphwr kr1c should be null on reset")

    @attr('errorepc')
    def test_cp2_reg_init_error_epcc(self):
        # Offset may not be zero for QEMU (it initializes errorEPC to 0xffffffffbfc00000)
        self._test_special_hwreg("error_epcc", 28, offset=(0, self.max_length))

    def test_cp2_reg_init_kcc(self):
        self._test_special_hwreg("kcc", 29)

    def test_cp2_reg_init_kdc(self):
        self._test_special_hwreg("kdc", 30, is_null=True)

    def test_cp2_reg_init_epcc(self):
        self._test_special_hwreg("epcc", 31)
