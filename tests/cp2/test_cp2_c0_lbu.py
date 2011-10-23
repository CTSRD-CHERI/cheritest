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
# Test lbu (load byte unsigned) indirected via a constrainted c0.
#

class test_cp2_c0_lbu(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_lbu_64aligned(self):
        '''Test a 64-bit aligned byte load via a constrained c0'''
        self.assertRegisterEqual(self.MIPS.a0, 0x00, "64-bit aligned lbu returned incorrect value")

    @attr('capabilities')
    def test_cp2_lbu_32aligned(self):
        '''Test a 32-bit aligned byte load via a constrained c0'''
        self.assertRegisterEqual(self.MIPS.a1, 0x44, "32-bit aligned lbu returned incorrect value")

    @attr('capabilities')
    def test_cp2_lbu_16aligned(self):
        '''Test a 16-bit aligned byte load via a constrained c0'''
        self.assertRegisterEqual(self.MIPS.a2, 0x66, "16-bit aligned lbu returned incorrect value")

    @attr('capabilities')
    def test_cp2_lbu_8aligned(self):
        '''Test a 8-bit aligned byte load via a constrained c0'''
        self.assertRegisterEqual(self.MIPS.a3, 0x77, "8-bit aligned lbu returned incorrect value")
