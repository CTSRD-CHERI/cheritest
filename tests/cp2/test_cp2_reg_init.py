#-
# Copyright (c) 2011 Robert N. M. Watson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
# ("CTSRD"), as part of the DARPA CRASH research programme.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
from cheritest_tools import BaseCHERITestCase
from nose.plugins.attrib import attr

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

class test_cp2_reg_init(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_reg_init_pcc(self):
        '''Test that CP2 register PCC is correctly initialised'''
        self.assertRegisterEqual(self.MIPS.pcc.base, 0x0, "CP2 PCC base incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.pcc.length, 0xffffffffffffffff, "CP2 PCC length incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.pcc.ctype, 0x0, "CP2 PCC ctype incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.pcc.perms, 0x7c91, "CP2 PCC perms incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.pcc.u, 1, "CP2 PCC unsealed incorrectly initialised")

    @attr('capabilities')
    def test_cp2_reg_init_c0(self):
        '''Test that CP2 register C0 is correctly initialised'''
        self.assertRegisterEqual(self.MIPS.c0.base, 0x0, "CP2 C0 base incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c0.length, 0xffffffffffffffff, "CP2 C0 length incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c0.ctype, 0x0, "CP2 C0 ctype incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c0.perms, 0x4018, "CP2 C0 perms incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c0.u, 1, "CP2 C0 unsealed incorrectly initialised")

    # Note: these tests includes C26, which is RCC.
#
# XXXRW: These tests are disabled until we have a syntax for accessing
# capability registers using an indexed array, similar to self.MIPS[].
#
#    @attr('capabilities')
#    def test_cp2_reg_init_rest_base(self):
#        '''Test that CP2 general-purpose register bases are correctly initialised'''
#        for i in range(1, 26):
#            self.assertRegisterEqual(self.MIPS.cp2[i].base, 0x0, "CP2 capability register bases incorrectly initialised")
#
#    @attr('capabilities')
#    def test_cp2_reg_init_rest_length(self):
#        '''Test that CP2 general-purpose register lengths are correctly initialised'''
#        for i in range(1, 26):
#            self.assertRegisterEqual(self.MIPS.cp2[i].length, 0x0, "CP2 capability register lengths incorrectly initialised")
#
#    @attr('capabilities')
#    def test_cp2_reg_init_rest_ctype(self):
#        '''Test that CP2 general-purpose register ctypes are correctly initialised'''
#        for i in range(1, 26):
#            self.assertRegisterEqual(self.MIPS.cp2[i].ctype, 0x0, "CP2 capability register ctypes incorrectly initialised")
#
#    @attr('capabilities')
#    def test_cp2_reg_init_rest_perms(self):
#        '''Test that CP2 general-purpose register perms are correctly initialised'''
#        for i in range(1, 26):
#            self.assertRegisterEqual(self.MIPS.cp2[i].perms, 0x0, "CP2 capability register perms incorrectly initialised")
#
#
#    @attr('capabilities')
#    def test_cp2_reg_init_rest_unsealed(self):
#        '''Test that CP2 general-purpose register unsealeds are correctly initialised'''
#        for i in range(1, 26):
#            self.assertRegisterEqual(self.MIPS.cp2[i].unsealed, 1, "CP2 capability register unsealeds incorrectly initialised")

    # IDC is c27
    @attr('capabilities')
    def test_cp2_reg_init_idc(self):
        '''Test that CP2 register IDC is correctly initialised'''
        self.assertRegisterEqual(self.MIPS.c27.base, 0x0, "CP2 IDC base incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c27.length, 0xffffffffffffffff, "CP2 IDC length incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c27.ctype, 0x0, "CP2 IDC ctype incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c27.perms, 0x7fff, "CP2 IDC perms incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c27.u, 1, "CP2 IDC unsealed incorrectly initialised")

    # TSC is c28
    @attr('capabilities')
    def test_cp2_reg_init_tsc(self):
        '''Test that CP2 register TSC is correctly initialised'''
        self.assertRegisterEqual(self.MIPS.c28.base, 0x0, "CP2 TSC base incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c28.length, 0x0, "CP2 TSC length incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c28.ctype, 0x0, "CP2 TSC ctype incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c28.perms, 0x0, "CP2 TSC perms incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c28.u, 1, "CP2 TSC unsealed incorrectly initialised")

    # KCC is c29
    @attr('capabilities')
    def test_cp2_reg_init_kcc(self):
        '''Test that CP2 register KCC is correctly initialised'''
        self.assertRegisterEqual(self.MIPS.c29.base, 0x0, "CP2 KCC base incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c29.length, 0xffffffffffffffff, "CP2 KCC length incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c29.ctype, 0x0, "CP2 KCC ctype incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c29.perms, 0x7fff, "CP2 KCC perms incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c29.u, 1, "CP2 KCC unsealed incorrectly initialised")

    # KDC is c30
    @attr('capabilities')
    def test_cp2_reg_init_kdc(self):
        '''Test that CP2 register KDC is correctly initialised'''
        self.assertRegisterEqual(self.MIPS.c30.base, 0x0, "CP2 KDC base incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c30.length, 0x0, "CP2 KDC length incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c30.ctype, 0x0, "CP2 KDC ctype incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c30.perms, 0x0, "CP2 KDC perms incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c30.u, 1, "CP2 KDC unsealed incorrectly initialised")

    # EPCC is c31
    @attr('capabilities')
    def test_cp2_reg_init_epcc(self):
        '''Test that CP2 register EPCC is correctly initialised'''
        self.assertRegisterEqual(self.MIPS.c31.base, 0x0, "CP2 EPCC base incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c31.length, 0xffffffffffffffff, "CP2 EPCC length incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c31.ctype, 0x0, "CP2 EPCC ctype incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c31.perms, 0x7c91, "CP2 EPCC perms incorrectly initialised")
        self.assertRegisterEqual(self.MIPS.c31.u, 1, "CP2 EPCC unsealed incorrectly initialised")
