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
from nose.plugins.attrib import attr

#
# Full capability context switch test.
#

class test_cp2_cscr_clcr_context(BaseCHERITestCase):
    @attr('capabilities')
    def test_unsealed(self):
        for i in range(0, 28):
            self.assertRegisterEqual(self.MIPS.cp2[i].u, 1, "u bit incorrect after context switch")
        self.assertRegisterEqual(self.MIPS.c31.u, 1, "u bit incorrect after context switch")

    @attr('capabilities')
    def test_perms(self):
        for i in range(0, 28):
            self.assertRegisterEqual(self.MIPS.cp2[i].perms, 0x7fff, "perms incorrect after context switch")
        self.assertRegisterEqual(self.MIPS.c31.perms, 0x7fff, "perms incorrect after context switch")

    @attr('capabilities')
    def test_base(self):
        for i in range(0, 28):
            self.assertRegisterEqual(self.MIPS.cp2[i].base, 0x0, "base incorrect after context switch")
        self.assertRegisterEqual(self.MIPS.c31.base, 0x0, "base incorrect after context switch")

    @attr('capabilities')
    def test_length(self):
        for i in range(0, 28):
            self.assertRegisterEqual(self.MIPS.cp2[i].length, 0xffffffffffffffff, "length incorrect after context switch")
        self.assertRegisterEqual(self.MIPS.c31.length, 0xffffffffffffffff, "length incorrect after context switch")

    @attr('capabilities')
    def test_ctype(self):
        for i in range(0, 28):
            self.assertRegisterEqual(self.MIPS.cp2[i].ctype, 0x0, "ctype incorrect after context switch")
        self.assertRegisterEqual(self.MIPS.c31.ctype, 0x0, "ctype incorrect after context switch")
