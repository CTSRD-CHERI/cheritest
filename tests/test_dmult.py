#-
# Copyright (c) 2011 William Morland
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

class test_dmult(BaseCHERITestCase):
	def test_pos_pos(self):
		'''Test of positive number multiplied by positive number'''
		self.assertRegisterEqual(self.MIPS.a0, 0xffdc972fa5fa2, "Load from hi or mult failed")
		self.assertRegisterEqual(self.MIPS.a1, 0xc3b3c5fa50c96421, "Load from lo or mult failed")

	def test_neg_neg(self):
		'''Test of negative number multiplied by negative number'''
		self.assertRegisterEqual(self.MIPS.a2, 0xffdc972fa5fa2, "Load from hi or mult failed")
		self.assertRegisterEqual(self.MIPS.a3, 0xc3b3c5fa50c96421, "Load from lo or mult failed")

	def test_neg_pos(self):
		'''Test of negative number multiplied by positive number'''
		self.assertRegisterEqual(self.MIPS.a4, 0xfff002368d05a05d, "Load from hi or mult failed")
		self.assertRegisterEqual(self.MIPS.a5, 0x3c4c3a05af369bdf, "Load from lo or mult failed")

	def test_pos_neg(self):
		'''Test of positive number multiplied by negative number'''
		self.assertRegisterEqual(self.MIPS.a6, 0xfff002368d05a05d, "Load from hi or mult failed")
		self.assertRegisterEqual(self.MIPS.a7, 0x3c4c3a05af369bdf, "Load from lo or mult failed")
