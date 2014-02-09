#-
# Copyright (c) 2011 William M. Morland
# Copyright (c) 2012 Jonathan Woodruff
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

class test_msub(BaseCHERITestCase):
	def test_initial(self):
		'''Test that lo is full'''
		self.assertRegisterEqual(self.MIPS.a0, 0, "Hi is incorrect")
		self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff, "Lo is not full")

	def test_msub_zeroed(self):
		'''Test that the bits correctly overflow from lo into hi'''
		self.assertRegisterEqual(self.MIPS.a2, 1, "Hi was incorrect")
		self.assertRegisterEqual(self.MIPS.a3, 0, "Lo was incorrect")

	def test_msub_pos(self):
		'''Test msub with a positive number'''
		self.assertRegisterEqual(self.MIPS.a4, 0, "Subtraction incorrect")
		self.assertRegisterEqual(self.MIPS.a5, 0xfffffffffffff5e9, "Subtraction incorrect")

	def test_msub_neg(self):
		'''Test msub with a negative number'''
		self.assertRegisterEqual(self.MIPS.a6, 0x80, "Subtraction of negative number incorrect")
		self.assertRegisterEqual(self.MIPS.a7, 0xfffffffffffff5e9, "Lo incorrectly affected by addition in the higher range")
		
	def test_msub_after_mtlo(self):
		'''Test msub following mtlo'''
		self.assertRegisterEqual(self.MIPS.s0, 0, "Multiply subtract immediatly after mtlo had the wrong hi register")
		self.assertRegisterEqual(self.MIPS.s1, 1024, "Multiply subtract immediatly after mtlo had the wrong lo register")
