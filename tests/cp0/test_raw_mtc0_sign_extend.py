#-
# Copyright (c) 2011 William M. Morland
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

class test_raw_mtc0_sign_extend(BaseCHERITestCase):
    def test_mtc0_signext(self):
        '''MTC0 should sign extend (some documentation suggests all 64-bits should be copied but sign-extension is logical and in line with other operations and GXemul)'''
        self.assertRegisterEqual(self.MIPS.a0, 0x00000000ffff0000, "LUI instruction failed")
        self.assertRegisterEqual(self.MIPS.a0|0xffffffff00000000, self.MIPS.a2, "Value not copied in and out of EPC correctly")

    def test_mfc0_signext_mtc0(self):
        self.assertRegisterEqual(self.MIPS.a0|0xffffffff00000000, self.MIPS.a1, "MFC0 did not correctly sign extend")

    def test_dmtc0_nosignext(self):
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a4, "Value was altered in process of dmtc0 and dmfc0")

    def test_mfc0_signext_dmtc0(self):
        self.assertRegisterEqual(self.MIPS.a0|0xffffffff00000000, self.MIPS.a3, "MFC0 did not correctly sign extend")


