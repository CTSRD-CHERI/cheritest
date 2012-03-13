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

# a0: paddr of testdata
# a1: PFN of testdata
# a2: EntryLo0 value
# a3: EntryLo1 value
# a4: Vaddr of testdata
# a5: Result of load 
# a6: Expected PC of faulting instruction
# a7: final value of testdata
	
# s0: BadVAddr
# s1: Context
# s2: XContext
# s3: EntryHi
# s4: Status
# s5: Cause
# s6: EPC	

class test_tlb_invalid_store(BaseCHERITestCase):
    def test_badvaddr(self):
        self.assertRegisterEqual(self.MIPS.s0, self.MIPS.a4, "Wrong BadVaddr")
    def test_context(self):
        self.assertRegisterEqual(self.MIPS.s1, (self.MIPS.a4 & 0xffffe000)>>9, "Wrong Context") # TODO test page table base
    def test_xcontext(self):
        self.assertRegisterEqual(self.MIPS.s2, (self.MIPS.a4 & 0xffffe000)>>9, "Wrong XContext") # TODO test page table base
    def test_entryhi(self):
        self.assertRegisterEqual(self.MIPS.s3, self.MIPS.a4 & 0xfffff000, "Wrong EntryHi")
    def test_status(self):
        self.assertRegisterEqual(self.MIPS.s4 & 2, 2, "Wrong EXL")
    def test_cause(self):
        self.assertRegisterEqual(self.MIPS.s5 & 0x3c, 0xc, "Wrong Exception Code")
    def test_epc(self):
        self.assertRegisterEqual(self.MIPS.a6, self.MIPS.s6, "Wrong EPC")
    def test_testdata(self):
        self.assertRegisterEqual(self.MIPS.a7, 0xfedcba9876543210, "Wrong testdata")
