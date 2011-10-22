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
# Check that the assembler, simulator, and test suite agree (adequately) on
# the naming of capability registers.
#
# XXXRW: Once we support aliases such as $c2_pcc, we should also check those.
#

class test_cp2_reg_name(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_reg_name_pcc(self):
        self.assertRegisterEqual(self.MIPS.pcc.ctype, 0, "CP2 PCC name mismatch")
    
    @attr('capabilities')
    def test_cp2_reg_name_c0(self):
        self.assertRegisterEqual(self.MIPS.c0.ctype, 1, "CP2 C0 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c1(self):
        self.assertRegisterEqual(self.MIPS.c1.ctype, 2, "CP2 C1 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c2(self):
        self.assertRegisterEqual(self.MIPS.c2.ctype, 3, "CP2 C2 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c3(self):
        self.assertRegisterEqual(self.MIPS.c3.ctype, 4, "CP2 C3 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c4(self):
        self.assertRegisterEqual(self.MIPS.c4.ctype, 5, "CP2 C4 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c5(self):
        self.assertRegisterEqual(self.MIPS.c5.ctype, 6, "CP2 C5 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c6(self):
        self.assertRegisterEqual(self.MIPS.c6.ctype, 7, "CP2 C6 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c7(self):
        self.assertRegisterEqual(self.MIPS.c7.ctype, 8, "CP2 C7 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c8(self):
        self.assertRegisterEqual(self.MIPS.c8.ctype, 9, "CP2 C8 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c9(self):
        self.assertRegisterEqual(self.MIPS.c9.ctype, 10, "CP2 C9 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c10(self):
        self.assertRegisterEqual(self.MIPS.c10.ctype, 11, "CP2 C10 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c11(self):
        self.assertRegisterEqual(self.MIPS.c11.ctype, 12, "CP2 C11 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c12(self):
        self.assertRegisterEqual(self.MIPS.c12.ctype, 13, "CP2 C12 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c13(self):
        self.assertRegisterEqual(self.MIPS.c13.ctype, 14, "CP2 C13 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c14(self):
        self.assertRegisterEqual(self.MIPS.c14.ctype, 15, "CP2 C14 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c15(self):
        self.assertRegisterEqual(self.MIPS.c15.ctype, 16, "CP2 C15 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c16(self):
        self.assertRegisterEqual(self.MIPS.c16.ctype, 17, "CP2 C16 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c17(self):
        self.assertRegisterEqual(self.MIPS.c17.ctype, 18, "CP2 C17 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c18(self):
        self.assertRegisterEqual(self.MIPS.c18.ctype, 19, "CP2 C18 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c19(self):
        self.assertRegisterEqual(self.MIPS.c19.ctype, 20, "CP2 C19 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c20(self):
        self.assertRegisterEqual(self.MIPS.c20.ctype, 21, "CP2 C20 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c21(self):
        self.assertRegisterEqual(self.MIPS.c21.ctype, 22, "CP2 C21 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c22(self):
        self.assertRegisterEqual(self.MIPS.c22.ctype, 23, "CP2 C22 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c23(self):
        self.assertRegisterEqual(self.MIPS.c23.ctype, 24, "CP2 C23 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c24(self):
        self.assertRegisterEqual(self.MIPS.c24.ctype, 25, "CP2 C24 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c25(self):
        self.assertRegisterEqual(self.MIPS.c25.ctype, 26, "CP2 C25 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c26(self):
        self.assertRegisterEqual(self.MIPS.c26.ctype, 27, "CP2 C26 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c27(self):
        self.assertRegisterEqual(self.MIPS.c27.ctype, 28, "CP2 C27 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c28(self):
        self.assertRegisterEqual(self.MIPS.c28.ctype, 29, "CP2 C28 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c29(self):
        self.assertRegisterEqual(self.MIPS.c29.ctype, 30, "CP2 C29 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c30(self):
        self.assertRegisterEqual(self.MIPS.c30.ctype, 31, "CP2 C30 name mismatch")

    @attr('capabilities')
    def test_cp2_reg_name_c31(self):
        self.assertRegisterEqual(self.MIPS.c31.ctype, 32, "CP2 C31 name mismatch")
