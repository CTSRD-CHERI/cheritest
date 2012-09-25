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
# Test that storing a capability to memory works.
#

class test_cp2_cscr(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_cscr_underflow(self):
        '''Test that cscr didn't overwrite dword before requested addr'''
        self.assertRegisterEqual(self.MIPS.a4, 0x0123456789abcdef, "cscr underflow")

    @attr('capabilities')
    def test_cp2_cscr_dword0(self):
        '''Test that cscr stored perms, u fields correctly'''
        self.assertRegisterEqual(self.MIPS.a0, 0x00000000000003ff, "cscr stored incorrect u, perms fields")

    @attr('capabilities')
    def test_cp2_cscr_dword1(self):
        '''Test that cscr stored the otype field correctly'''
        self.assertRegisterEqual(self.MIPS.a1, 0x0000000000000001, "cscr stored incorrect otype")

    @attr('capabilities')
    def test_cp2_cscr_dword2(self):
        '''Test that cscr stored the base field correctly'''
        self.assertRegisterEqual(self.MIPS.a2, 0x0000000000000000, "cscr stored incorrect base address")

    @attr('capabilities')
    def test_cp2_cscr_dword3(self):
        '''Test that cscr stored the length field correctly'''
        self.assertRegisterEqual(self.MIPS.a3, 0xffffffffffffffff, "cscr stored incorrect length")

    @attr('capabilities')
    def test_cp2_csr_overflow(self):
        '''Test that cscr didn't overwrite dword before requested addr'''
        self.assertRegisterEqual(self.MIPS.a5, 0x0123456789abcdef, "cscr underflow")

