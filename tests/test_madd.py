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

class test_madd(BaseCHERITestCase):
	def test_zero(self):
		'''Test that hi and lo are zeroed'''
		self.assertRegisterEqual(self.MIPS.a0, 0, "Hi was not zeroed")
		self.assertRegisterEqual(self.MIPS.a1, 0, "Lo was not zeroed")

	def test_madd_zeroed(self):
		'''Test of MADD into zeroed hi and lo registers'''
		self.assertRegisterEqual(self.MIPS.a2, 0xffffffffff1d3b59, "Hi was incorrect or not properly sign extended")
		self.assertRegisterEqual(self.MIPS.a3, 0x6a4c2e10, "Lo was incorrect")

	def test_madd_pos(self):
		'''Test MADD of a positive result'''
		self.assertRegisterEqual(self.MIPS.a4, 0xffffffffff1d3b59, "Hi was changed incorrectly")
		self.assertRegisterEqual(self.MIPS.a5, 0x6a4c3827, "An incorrect amount was added to lo")

	def test_pos_neg(self):
		'''Test MADD of a negative result'''
		self.assertRegisterEqual(self.MIPS.a6, 0xffffffffff1d3ad9, "An incorrect amount was subtracted from hi")
		self.assertRegisterEqual(self.MIPS.a7, 0x6a4c3827, "Lo was changed incorrectly")
