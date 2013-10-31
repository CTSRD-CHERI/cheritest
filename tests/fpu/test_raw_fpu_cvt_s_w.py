#-
# Copyright (c) 2012 Ben Thorner
# Copyright (c) 2013 Colin Rothwell
# Copyright (c) 2013 Michael Roe
# All rights reserved.
#
# This software was developed by Ben Thorner as part of his summer internship
# and Colin Rothwell as part of his final year undergraduate project.
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

class test_raw_fpu_cvt_s_w(BaseCHERITestCase):

    def test_raw_fpu_cvt_s_w_1(self):
        '''Test we can convert 1 (32 bit int) to single precision'''
        self.assertRegisterEqual(self.MIPS.a0, 0x3F800000, "Didn't convert 1 (32 bit int) to single precision")

    def test_raw_fpu_cvt_s_w_2(self):
        '''Test we can convert 0x4c00041a (32 bit int) to single precision'''
        self.assertRegisterEqual(self.MIPS.a1, 0x4C00041A, "Didn't convert non exact to single precision")

    def test_raw_fpu_cvt_s_w_3(self):
        '''Test we can convert -23 (32 bit int) to single precision'''
        self.assertRegisterEqual(self.MIPS.a2, 0xFFFFFFFFC1B80000, "Didn't convert -23 to single precision")

    def test_raw_fpu_cvt_s_w_4(self):
        '''Test we can convert 0 (32 bit int) to single precision'''
        self.assertRegisterEqual(self.MIPS.a3, 0, "Didn't convert 0 to single precision")

