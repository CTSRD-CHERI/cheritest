#-
# Copyright (c) 2014 Michael Roe
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

class test_raw_srlv(BaseCHERITestCase):

    def test_srlv_0(self):
        '''Test SRLV by 0 bits'''
        self.assertRegisterEqual(self.MIPS.a0, 0x76543210, "SRLV by 0 bits failed")

    def test_srlv_1(self):
        '''Test SRLV by 1 bit'''
        self.assertRegisterEqual(self.MIPS.a1, 0x3b2a1908, "SRLV by 1 bit failed")

    def test_srlv_16(self):
        '''Test SRLV by 16 bits'''
        self.assertRegisterEqual(self.MIPS.a2, 0x7654, "SRLV by 16 bits failed")

    def test_srlv_31(self):
        '''Test SRLV by 31 bits'''
        self.assertRegisterEqual(self.MIPS.a3, 0x0, "SRLV by 31 bits failed")

    def test_srlv_0_neg(self):
        '''Test SRLV by 0 bits of a negative value'''
        self.assertRegisterEqual(self.MIPS.a4, 0xfffffffffedcba98, "SRLV by 0 bits of a negative value failed")

    def test_srlv_1_neg(self):
        '''Test SRLV by 1 bits of a negative value'''
        self.assertRegisterEqual(self.MIPS.a5, 0x7f6e5d4c, "SRLV by 1 bit of a negative value failed")

    def test_srlv_16_neg(self):
        '''Test SRLV by 16 bits of a negative value'''
        self.assertRegisterEqual(self.MIPS.a6, 0xfedc, "SRLV by 16 bits of a negative value failed")

    def test_srlv_31_neg(self):
        '''Test SRLV by 31 bits of a negative value'''
        self.assertRegisterEqual(self.MIPS.a7, 0x1, "SRLV by 31 bits of a negative value failed")

