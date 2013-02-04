#-
# Copyright (c) 2013 Robert M. Norton
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

# Register assignment:
# a0 - desired epc 1
# a1 - actual epc 1
# a2 - desired badvaddr 1
# a3 - actual badvaddr 1
# a4 - cause 1
# a5 - desired epc 2
# a6 - actual  epc 2
# a7 - desired badvaddr 2
# s0 - actual  badvaddr 2
# s1 - cause 2

class test_tlb_addrerr_load(BaseCHERITestCase):
    def test_epc1(self):
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a1, "Wrong EPC 1")
    def test_badvaddr1(self):
        self.assertRegisterEqual(self.MIPS.a2, self.MIPS.a3, "Wrong badaddr 1")
    def test_cause1(self):
        self.assertRegisterEqual(self.MIPS.a4 & 0xff, 0x10, "Wrong cause 1")
    def test_epc2(self):
        self.assertRegisterEqual(self.MIPS.a5, self.MIPS.a6, "Wrong EPC 2")
    def test_badvaddr2(self):
        self.assertRegisterEqual(self.MIPS.a7, self.MIPS.s0, "Wrong badaddr 2")
    def test_cause2(self):
        self.assertRegisterEqual(self.MIPS.s1 & 0xff, 0x10, "Wrong cause 2")
