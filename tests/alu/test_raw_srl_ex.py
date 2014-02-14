#-
# Copyright (c) 2011 William M. Morland
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

class test_raw_srl_ex(BaseCHERITestCase):

        @attr('ignorebadex')
        def test_a1(self):
		'''Test a SRL of zero'''
		self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a1, 0x0000000076543210, "Shift of zero resulting in truncation failed")

        @attr('ignorebadex')
	def test_a2(self):
		'''Test a SRL of one'''
		self.assertRegisterEqual(self.MIPS.a2, 0x000000003b2a1908, "Shift of one failed")

        @attr('ignorebadex')
	def test_a3(self):
		'''Test a SRL of sixteen'''
		self.assertRegisterEqual(self.MIPS.a3, 0x0000000000007654, "Shift of sixteen failed")

        @attr('ignorebadex')
	def test_a4(self):
		'''Test a SRL of 31(max)'''
		self.assertRegisterEqual(self.MIPS.a4, 0x0000000000000000, "Shift of thirty-one (max) failed")

        @attr('ignorebadex')
	def test_a6(self):
		'''Test a SRL of zero with sign extension'''
		self.assertRegisterEqual(self.MIPS.a5, 0x00000000ffffffff, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a6, 0xffffffffffffffff, "Shift of zero with sign extension failed")