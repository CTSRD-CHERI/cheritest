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
from bsim_utils import BaseBsimTestCase

class raw_lh(BaseBsimTestCase):
    def test_a0(self):
        '''Test unsigned load half word from double word'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedc, "Unsigned half word load from double word failed")

    def test_a1(self):
        '''Test signed-extended positive load half word'''
        self.assertRegisterEqual(self.MIPS.a1, 0x7fff, "Sign-extended positive half word load failed")

    def test_a2(self):
        '''Test signed-extended negative load half word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Sign-extended negative half word load failed")

    def test_a3(self):
        '''Test unsigned positive load half word'''
        self.assertRegisterEqual(self.MIPS.a3, 0x7fff, "Unsigned positive half word load failed")

    def test_a4(self):
        '''Test unsigned negative load half word'''
        self.assertRegisterEqual(self.MIPS.a4, 0xffff, "Unsigned negative half word load failed")

    def test_pos_offset(self):
        '''Test half word load at positive offset'''
        self.assertRegisterEqual(self.MIPS.a5, 2, "Half word load at positive offset failed")

    def test_neg_offset(self):
        '''Test half word load at negative offset'''
        self.assertRegisterEqual(self.MIPS.a6, 1, "Half word load at negative offset failed")
