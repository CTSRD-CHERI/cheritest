#-
# Copyright (c) 2013 Michael Roe
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
# Test that floating point store raises a C2E exception if c0 does not grant
# Permit_Store.
#

class test_cp2_x_swc1_perm(BaseCHERITestCase):
    @attr('capabilities')
    @attr('float')
    def test_cp2_x_swc1_perm_1(self):
        '''Test swc1 did not store without Permit_Store permission'''
        self.assertRegisterEqual(self.MIPS.a4, 0x01234567,
            "swc1 stored without Permit_Store permission")

    @attr('capabilities')
    @attr('float')
    def test_cp2_x_swc1_perm_2(self):
        '''Test swc1 raises an exception when doesn't have Permit_Store permission'''
        self.assertRegisterEqual(self.MIPS.a2, 1,
            "swc1 did not raise an exception when didn't have Permit_Store permission")

    @attr('capabilities')
    @attr('float')
    def test_cp2_x_swc1_perm_3(self):
        '''Test capability cause is set correctly when doesn't have Permit_Store permission'''
        self.assertRegisterEqual(self.MIPS.a3, 0x1300,
            "Capability cause was not set correctly when didn't have Permit_Store permission")

