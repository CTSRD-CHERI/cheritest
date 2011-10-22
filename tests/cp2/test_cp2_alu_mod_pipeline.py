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
# Test for pipeline forwarding problems between ALU results and input to
# capability modify operations.
#

class test_cp2_alu_mod_pipeline(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_alu_cincbase(self):
        '''Test that cincbase uses ALU results in pipeline'''
        self.assertRegisterEqual(self.MIPS.a0, 0x100, "cgetbase returns incorrect value")

    @attr('capabilities')
    def test_cp2_alu_cdecleng(self):
	'''Test that cdecleng uses ALU results in pipeline'''
	self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff - 0x100, "cgetleng returns incorrect value")

    @attr('capabilities')
    def test_cp2_alu_candperm(self):
        '''Test that candperm uses ALU results in pipeline'''
        self.assertRegisterEqual(self.MIPS.a2, 0x7fff & 0x100, "cgetperm returns incorrect value")

    @attr('capabilities')
    def test_cp2_alu_csettype(self):
        '''Test that csettype uses ALU results in pipeline'''
        self.assertRegisterEqual(self.MIPS.a3, 0x100, "cgettype returns incorrect value")
