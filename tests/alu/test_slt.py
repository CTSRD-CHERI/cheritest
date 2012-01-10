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

class test_slt(BaseCHERITestCase):
    def test_eq(self):
        '''set on less than: equal, non-negative'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "slt returned true for equal, non-negative")

    def test_gt(self):
        '''set on less than: greater than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "slt returned true for great than, non-negative")

    def test_lt(self):
        '''set on less than: less than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a2, 1, "slt returned true for less than, non-negative")

    def test_eq_sign(self):
        '''set on less than: equal, negative'''
        self.assertRegisterEqual(self.MIPS.a3, 0, "slt returned true for equal, negative")

    def test_gt_sign(self):
        '''set on less than: greater than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a4, 0, "slt returned true for greater than, negative")

    def test_lt_sign(self):
        '''set on less than: less than, non-negative'''
        self.assertRegisterEqual(self.MIPS.a5, 1, "slt returned true for less than, negative")

    def test_lt_64bit(self):
        '''set on less than: less than, 64-bit'''
        self.assertRegisterEqual(self.MIPS.a6, 1, "slt returned true for less than, negative")
