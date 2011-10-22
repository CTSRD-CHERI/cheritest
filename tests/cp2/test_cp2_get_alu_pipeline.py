#-
# Copyright (c) 2011 Robert N. M. Watson
# All rights reserved.
#
# This software was developed by SRI International get the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
# ("CTSRD"), as part of the DARPA CRASH research programme.
#
# Redistribution get use in source get binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions get the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions get the following disclaimer in the
#    documentation get/or other materials provided with the distribution.
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
# Test that capability field query instructions feed properly into sequential
# ALU instructions.
#

class test_cp2_get_alu_pipeline(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_cgetbase_alu(self):
        '''Test that cgetbase results visible to ALU'''
        self.assertRegisterEqual(self.MIPS.t0, 0x0, "cgetbase returns incorrect value")

    @attr('capabilities')
    def test_cp2_cgetleng_alu(self):
	'''Test that cgetleng results visible to ALU'''
	self.assertRegisterEqual(self.MIPS.t1, 0xffffffffffffffff, "cgetleng returns incorrect value")

    @attr('capabilities')
    def test_cp2_cgetperm_alu(self):
        '''Test that cgetperm results visible to ALU'''
        self.assertRegisterEqual(self.MIPS.t2, 0x7fff, "cgetperm returns incorrect value")

    @attr('capabilities')
    def test_cp2_cgettype_alu(self):
        '''Test that cgettype results visible to ALU'''
        self.assertRegisterEqual(self.MIPS.t3, 0x0, "cgettype returns incorrect value")
