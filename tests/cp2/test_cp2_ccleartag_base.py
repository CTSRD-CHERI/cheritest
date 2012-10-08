#-
# Copyright (c) 2011 Michael Roe
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
# Test that ccleartag clears the base, length, type and perms fields
#

class test_cp2_ccleartag_base(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_ccleartag_base_perm(self):
        '''Test that ccleartag clears the permissions field'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "ccleartag did not clear the permissions field")

    @attr('capabilities')
    def test_cp2_ccleartag_base_base(self):
        '''Test that ccleartag clears the base field'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "ccleartag did not clear the base field")

    @attr('capabilities')
    def test_cp2_ccleartag_base_length(self):
        '''Test that ccleartag clears the length field'''
        self.assertRegisterEqual(self.MIPS.a2, 0, "ccleartag did not clear the length field")

    @attr('capabilities')
    def test_cp2_ccleartag_base_type(self):
        '''Test that ccleartag clears the type field'''
        self.assertRegisterEqual(self.MIPS.a3, 0, "ccleartag did not clear the type field")

