#-
# Copyright (c) 2013 Michael Roe
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

#
# Test double-precision round operation when the FPU is in 64 bit mode
#

from cheritest_tools import BaseCHERITestCase
from nose.plugins.attrib import attr

class test_raw_fpu_floor_d64(BaseCHERITestCase):

    @attr('float64')
    def test_raw_fpu_floor_d64_1(self):
        '''Test double precision floor of -0.75'''
	self.assertRegisterEqual(self.MIPS.a0 & 0xffffffff, 0xffffffff, "-0.75 did not round down to -1")

    @attr('float64')
    def test_raw_fpu_floor_d64_2(self):
        '''Test double precision floor of -0.5'''
	self.assertRegisterEqual(self.MIPS.a1 & 0xffffffff, 0xffffffff, "-0.5 did not round down to -1")

    @attr('float64')
    def test_raw_fpu_floor_d64_3(self):
        '''Test double precision floor of -0.25'''
	self.assertRegisterEqual(self.MIPS.a2 & 0xffffffff, 0xffffffff, "-0.25 did not round down to -1")

    @attr('float64')
    def test_raw_fpu_floor_d64_4(self):
        '''Test double precision floor of 0.5'''
	self.assertRegisterEqual(self.MIPS.a3, 0, "0.5 did not round down to 0")

    @attr('float64')
    def test_raw_fpu_floor_d64_5(self):
        '''Test double precision round of 1.5'''
	self.assertRegisterEqual(self.MIPS.a4, 1, "1.5 did not round down to 1")


