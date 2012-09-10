#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2012 Robert M. Norton
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
# Test for a control flow problem with a particular version of Cheri2.
# A CP2 instruction followed by a jump caused the jump to be skipped.
#

class test_cp2_cmove_j(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_cmove_uperms(self):
        '''Test that cmove retained u, perms fields correctly'''
        self.assertRegisterEqual(self.MIPS.a0, 0xff, "cmove failed to retain correct u, perms fields")

    @attr('capabilities')
    def test_cp2_cmove_type(self):
        '''Test that cmove retained the ctype field correctly'''
        self.assertRegisterEqual(self.MIPS.a1, 0x5, "cmove failed to retain correct ctype")

    @attr('capabilities')
    def test_cp2_cmove_base(self):
        '''Test that cmove retained the base field correctly'''
        self.assertRegisterEqual(self.MIPS.a2, 0x100, "cmove failed to retain correct base address")

    @attr('capabilities')
    def test_cp2_cmove_length(self):
        '''Test that cmove retained the length field correctly'''
        self.assertRegisterEqual(self.MIPS.a3, 0x200, "cmove failed to retain correct length")

    def test_branch_delay(self):
        '''Test that branch delay was executed.'''
        self.assertRegisterEqual(self.MIPS.a4, 0x1, "branch delay not executed")

    def test_jump_taken(self):
        '''Test jump taken.'''
        self.assertRegisterEqual(self.MIPS.a5, 0x0, "jump did not skip over instruction.")

    def test_jump_dest(self):
        '''Test jump destination reached.'''
        self.assertRegisterEqual(self.MIPS.a6, 0x1, "jump did not reach destination.")
