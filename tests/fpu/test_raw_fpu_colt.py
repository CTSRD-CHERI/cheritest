#-
# Copyright (c) 2013-2013 Ben Thorner, Colin Rothwell
# All rights reserved.
#
# This software was developed by Ben Thorner as part of his summer internship
# and Colin Rothwell as part of his final year undergraduate project.
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

class test_raw_fpu_colt(BaseCHERITestCase):
    def test_colt_single(self):
        '''Test we can compare less than in single precision'''
        self.assertRegisterEqual(self.MIPS.s0, 0x1, "Failed to compare less than 1.0, 2.0 in single precision")
        self.assertRegisterEqual(self.MIPS.s3, 0x0, "Failed to compare less than 2.0, 2.0 in single precision")

    def test_colt_double(self):
        '''Test we can compare less than in double precision'''
        self.assertRegisterEqual(self.MIPS.s1, 0x1, "Failed to compare less than 1.0, 2.0 in double precision")
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed to compare less than 2.0, 2.0 in double precision")

    def test_colt_paired(self):
        '''Test we can compare less than paired singles'''
        self.assertRegisterEqual(self.MIPS.s2, 0x1, "Failed to compare less than 2.0, 1.0 and 1.0, 2.0 in paired single precision")
        self.assertRegisterEqual(self.MIPS.s5, 0x0, "Failed to compare equal 2.0, 1.0 and 2.0, 1.0 in paired single precision")

    def test_colt_abs(self):
        self.assertRegisterEqual(self.MIPS.s6, 0x1, "-0.8 not marked as < 1")
