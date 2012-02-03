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

class test_divu(BaseCHERITestCase):
	def test_pos_pos(self):
		'''Test of positive number divided by positive number'''
		self.assertRegisterEqual(self.MIPS.a0, 3, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a1, 5, "Division failed")

	def test_neg_neg(self):
		'''Test of negative number divided by negative number'''
		self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffff85, "Modulo with sign extension failed")
		self.assertRegisterEqual(self.MIPS.a3, 0, "Division failed")

	def test_neg_pos(self):
		'''Test of negative number divided by positive number'''
		self.assertRegisterEqual(self.MIPS.a4, 0x000000000000000d, "Modulo with sign extension failed")
		self.assertRegisterEqual(self.MIPS.a5, 0x000000000aaaaaa5, "Division with sign extension failed")

	def test_pos_neg(self):
		'''Test of positive number divided by negative number'''
		self.assertRegisterEqual(self.MIPS.a6, 0x7b, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a7, 0, "Division with sign extension failed")

	def test_overflow(self):
		'''Test of maximally negative number divided by negative one (signed overflow).'''
		self.assertRegisterEqual(self.MIPS.s0, 0xffffffff80000000, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.s1, 0x0, "Divide  failed")
