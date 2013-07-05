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

class test_raw_fpu_mov_cc(BaseCHERITestCase):
    def test_mov_cc(self):
        '''Test we can move on CCs'''
        self.assertRegisterEqual(self.MIPS.s0, 0x41000000, "Failed MOVF on condition true in single precision");
        self.assertRegisterEqual(self.MIPS.s1, 0x4000000000000000, "Failed MOVF on condition true in double precision");
        self.assertRegisterEqual(self.MIPS.s2, 0x4000000041000000, "Failed MOVF on condition true in paired single precision");
        self.assertRegisterEqual(self.MIPS.s3, 0x0, "Failed MOVF on condition false in single precision");
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed MOVF on condition false in double precision");
        self.assertRegisterEqual(self.MIPS.s5, 0x0, "Failed MOVF on condition false in paired single precision");
        self.assertRegisterEqual(self.MIPS.s6, 0x41000000, "Failed MOVT on condition true in single precision");
        self.assertRegisterEqual(self.MIPS.s7, 0x4000000000000000, "Failed MOVT on condition true in double precision");
        self.assertRegisterEqual(self.MIPS.a0, 0x4000000041000000, "Failed MOVT on condition true in paired single precision");
        self.assertRegisterEqual(self.MIPS.a1, 0x0, "Failed MOVT on condition false in single precision");
        self.assertRegisterEqual(self.MIPS.a2, 0x0, "Failed MOVT on condition false in double precision");
        self.assertRegisterEqual(self.MIPS.a3, 0x0, "Failed MOVT on condition false in paired single precision");
