#
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
# Test that the CReturn instruction causes a trap to the CCall exception handler
#

class test_cp2_creturn_trap(BaseCHERITestCase):

    @attr('capabilities')
    def test_cp2_creturn1(self):
        '''Test that creturn causes a trap'''
        self.assertRegisterEqual(self.MIPS.a2, 2,
            "creturn did not cause the right trap handler to be run")

    @attr('capabilities')
    def test_cp_creturn2(self):
        '''Test that creturn sets the cap cause register'''
        self.assertRegisterEqual(self.MIPS.a3, 0x06ff,
            "creturn did not set capability cause correctly")

    @attr('capabilities')
    def test_cp_creturn3(self):
        '''Test that $kcc is copied to $pcc when trap handler runs'''
        self.assertRegisterEqual(self.MIPS.a4, 0x7fff,
            "$pcc was not set to $kcc on entry to trap handler")

    @attr('capabilities')
    def test_cp_creturn4(self):
        '''Test that creturn restored full perms to $pcc'''
        self.assertRegisterEqual(self.MIPS.a6, 0x7fff,
            "creturn did not restore full perms to $pcc")


