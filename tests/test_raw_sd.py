#-
# Copyright (c) 2011 Steven J. Murdoch
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

class raw_sd(BaseCHERITestCase):
    def test_a0(self):
        '''Test load of stored double word'''
        self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Load of stored double word failed")

    def test_a1(self):
        '''Test signed load of stored positive double word'''
        self.assertRegisterEqual(self.MIPS.a1, 1, "Signed load of positive double word failed")

    def test_a2(self):
        '''Test signed load of stored negative double word'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "Signed load of negative double word failed")

    def test_pos_offset(self):
        '''Test double word store, load at positive offset'''
        self.assertRegisterEqual(self.MIPS.a3, 2, "Double word store, load at positive offset failed")

    def test_neg_offset(self):
        '''Test double word store, load at negative offset'''
        self.assertRegisterEqual(self.MIPS.a4, 1, "Double word store, load at negative offset failed")
