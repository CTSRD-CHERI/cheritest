#-
# Copyright (c) 2013 Alan A. Mujumdar
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

class test_raw_coherent_sync(BaseCHERITestCase):
    def test_coreid_register(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "Initial read of coreID register failed")

    def test_cache_coherent_memory(self):
        self.assertRegisterEqual(self.MIPS.a1, 0, "Core Zero has failed a write to memory")

    def test_cache_coherent_write(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "Core One produced incoherent data")

    def test_core_0_branch(self):
        self.assertRegisterEqual(self.MIPS.a3, 0, "Core Zero failed to execute the branch")

    def test_core_1_branch(self):
        self.assertRegisterEqual(self.MIPS.a4, 1, "Core One failed to execute the branch")

    def test_core_0_sync(self):
        self.assertRegisterEqual(self.MIPS.a5, 0, "Core Zero failed to sync")

    def test_core_1_sync(self):
        self.assertRegisterEqual(self.MIPS.a6, 1, "Core One failed to sync")

