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

class test_raw_fpu_cvtw(BaseCHERITestCase):
    def test_convert_one_to_word(self):
        '''Test we can convert 1.0f to word'''
        self.assertRegisterEqual(self.MIPS.s0, 1, "Didn't convert 1 to word")

    def test_convert_negative_to_word(self):
        '''Test we can convert -1.0f to word'''
        self.assertRegisterEqual(self.MIPS.s1, 0xFFFFFFFFFFFFFFFF, "Didn't convert -1 to word")

    def test_convert_large_to_word(self):
        '''Test we can convert 2^30 to word'''
        self.assertRegisterEqual(self.MIPS.s2, 1073741824 , "Didn't convert 2^30 to word")

    def test_convert_fraction_to_word(self):
        '''Test we can convert fractional values to word'''
        self.assertRegisterEqual(self.MIPS.s3, 107, "Didn't convert 107.325 to word")
        self.assertRegisterEqual(self.MIPS.s4, 6, "Didn't truncate 6.66 to word")
