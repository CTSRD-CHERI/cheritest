#
# Copyright (c) 2012 Michael Roe
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
# Test csealdata
#

class test_cp2_csealdata(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_csealdata1(self):
        '''Test that csealdata clears the unsealed bit'''
        self.assertRegisterEqual(self.MIPS.a0, 0,
            "csealdata did not clear the u bit")

    @attr('capabilities')
    def test_cp2_sealdata2(self):
        '''Test that csealdata sets the otype field'''
        self.assertRegisterEqual(self.MIPS.a1, 0,
            "csealdata did not set the otype field correctly")

    @attr('capabilities')
    def test_cp2_sealdata3(self):
        '''Test that csealdata sets the base field'''
        self.assertRegisterEqual(self.MIPS.a2, 0,
            "csealdata did not set the base field correctly")

    @attr('capabilities')
    def test_cp2_sealdata4(self):
        '''Test that csealdata sets the length field'''
        self.assertRegisterEqual(self.MIPS.a3, 8,
            "csealdata did not set the length field correctly")

    @attr('capabilities')
    def test_cp2_sealdata5(self):
        '''Test that csealdata sets the perms field'''
        self.assertRegisterEqual(self.MIPS.a4, 0xd,
            "csealdata did not set the perms field correctly")

