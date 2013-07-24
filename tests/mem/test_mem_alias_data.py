#-
# Copyright (c) 2011 Robert N. M. Watson
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

class test_mem_alias_data(BaseCHERITestCase):
    def test_expected_values(self):
        v0=0x0001020304050607
        v1=0x1011121314151617
        v2=0x2021222324252627
        self.assertRegisterEqual(self.MIPS.a3, v0, "a3 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.a4, v1, "a4 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.a5, v0, "a5 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.a6, v1, "a6 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.a7, v2, "a7 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.s0, v0, "s0 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.s1, v1, "s1 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.s2, v1, "s2 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.s3, v2, "s3 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.s4, v2, "s4 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.s5, 0,  "s5 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.s6, 0,  "s6 did not have correct value.")
        self.assertRegisterEqual(self.MIPS.s7, v0, "s7 did not have correct value.")

   
   
   
   
   
   
   
   
   
   
   
   
