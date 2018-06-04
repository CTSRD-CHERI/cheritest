#-
# Copyright (c) 2013 Michael Roe
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
from nose.plugins.attrib import attr

#
# Test that floating point store raises a C2E exception if c0 does not grant
# Permit_Store.
#

class test_cp2_null_vs_ddc(BaseBERITestCase):
    @attr('capabilities')
    def test_cmove_0_is_null(self):
        if self.MIPS.CHERI_C0_IS_NULL:
            self.assertNullCap(self.MIPS.c4, "cmove $c4, $cnull should return NULL")
        else:
            self.assertCapabilitiesEqual(self.MIPS.c4, self.MIPS.c3, "cmove $c4, $cnull should return $ddc (legacy mode)")

    @attr('capabilities')
    def test_cfromptr_0_is_ddc(self):
        self.assertCapabilitiesEqual(self.MIPS.c5, self.MIPS.c3, "cfromptr cb == 0 should use $ddc")

    @attr('capabilities')
    def test_ctoptr_0_is_ddc(self):
        self.assertCapabilitiesEqual(self.MIPS.t1, self.MIPS.c3.offset, "ctoptr ct == 0 should use $ddc")
        self.assertCapabilitiesEqual(self.MIPS.t1, self.MIPS.t1, "ctoptr ct == 0 should use $ddc")
        self.assertRegisterNotEqual(self.MIPS.t1, 0, "ctoptr ct == 0 should use $ddc")
        if self.MIPS.CHERI_C0_IS_NULL:
            self.assertRegisterEqual(self.MIPS.t2, 0, "ctoptr cb == 0 should use return 0")
        else
            self.assertRegisterEqual(self.MIPS.t2, self.MIPS.c3.offset, "ctoptr cb == 0 should use return $ddc (legacy)")

    @attr('capabilities')
    def test_cbuildcap_0_is_ddc(self):
        self.assertRegisterEqual(self.MIPS.c6.t, 0, "$c6 should not be tagged")
        self.assertCapabilitiesEqual(self.MIPS.c7, self.MIPS.c3, "cbuildcap cb == 0 should use $ddc")

    @attr('capabilities')
    def test_cincoffset_imm_0_is_null(self):
        if self.MIPS.CHERI_C0_IS_NULL:
            self.assertIntCap(self.MIPS.c8, int_value=42, msg="cincoffsetimm $cnull should return NULL")
        else:
            self.assertDefaultCap(self.MIPS.c8, offset=self.MIPS.c3.offset + 42, msg="cincoffsetimm $cnull should return $ddc (legacy mode)")

    @attr('capabilities')
    def test_cincoffset_reg_0_is_null(self):
        if self.MIPS.CHERI_C0_IS_NULL:
            self.assertIntCap(self.MIPS.c9, int_value=43, msg="cincoffset $cnull should return NULL")
        else:
            self.assertDefaultCap(self.MIPS.c9, offset=self.MIPS.c3.offset + 43, msg="cincoffset $cnull should return $ddc (legacy mode)")

    @attr('capabilities')
    def test_csetoffset_0_is_null(self):
        if self.MIPS.CHERI_C0_IS_NULL:
            self.assertIntCap(self.MIPS.c10, int_value=44, msg="csetoffset $cnull should return NULL")
        else:
            self.assertDefaultCap(self.MIPS.c10, offset=44, msg="csetoffset $cnull should return $ddc (legacy mode)")

    @attr('capabilities')
    def test_write_0_noop(self):
        if self.MIPS.CHERI_C0_IS_NULL:
            self.assertNullCap(self.MIPS.c0, msg="None of the operations with $c0 as output should modify $c0")

    @attr('capabilities')
    def test_load_uses_ddc(self):
        self.assertRegisterEqual(self.MIPS.a0, 0x01, "clbu returned wrong value")
        self.assertRegisterEqual(self.MIPS.a1, 0x0123, "clhu returned wrong value")
        self.assertRegisterEqual(self.MIPS.a2, 0x01234567, "clw returned wrong value")
        self.assertRegisterEqual(self.MIPS.a3, 0x0123456789abcdef, "cld returned wrong value")

    @attr('capabilities')
    def test_clc_uses_ddc(self):
        self.assertRegisterEqual(self.MIPS.c11.base + self.MIPS.c11.offset, 0x0123456789abcdef, "clc cursor wrong?")

    @attr('capabilities')
    def test_load_linked_uses_ddc(self):
        self.assertRegisterEqual(self.MIPS.a4, 0x01, "clbu returned wrong value")
        self.assertRegisterEqual(self.MIPS.a5, 0x0123, "clhu returned wrong value")
        self.assertRegisterEqual(self.MIPS.a6, 0x01234567, "clw returned wrong value")
        self.assertRegisterEqual(self.MIPS.a7, 0x0123456789abcdef, "cld returned wrong value")

    @attr('capabilities')
    def test_cllc_uses_ddc(self):
        self.assertRegisterEqual(self.MIPS.c12.base + self.MIPS.c12.offset, 0x0123456789abcdef, "cllc cursor wrong?")

