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
# Test single-precision rounding mode
#

from cheritest_tools import BaseCHERITestCase
from nose.plugins.attrib import attr

class test_raw_fpu_round_single(BaseCHERITestCase):

    def test_raw_fpu_round_single_mode(self):
        '''Test default rounding mode'''
	self.assertRegisterEqual(self.MIPS.a0, 0, "Default rounding mode is not round to nearest even")

    def test_raw_fpu_round_single_1(self):
        '''Test default rounding mode'''
	self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff, "-0.75 did not round to -1")

    def test_raw_fpu_round_single_2(self):
        '''Test default rounding mode'''
	self.assertRegisterEqual(self.MIPS.a2, 0, "-0.5 did not round to 0")

    def test_raw_fpu_round_single_3(self):
        '''Test default rounding mode'''
	self.assertRegisterEqual(self.MIPS.a3, 0, "-0.25 did not round to 0")

    def test_raw_fpu_round_single_4(self):
        '''Test default rounding mode'''
	self.assertRegisterEqual(self.MIPS.a4, 0, "0.5 did not round to 0")

    def test_raw_fpu_round_single_5(self):
        '''Test default rounding mode'''
	self.assertRegisterEqual(self.MIPS.a5, 2, "1.5 did not round to 2")


