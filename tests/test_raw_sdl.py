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

class raw_sdl(BaseCHERITestCase):
	def test_a1(self):
		self.assertRegisterEqual(self.MIPS.a1, 0xfedcba9876543210, "SDL with zero offset failed")

	def test_a2(self):
		self.assertRegisterEqual(self.MIPS.a2, 0xfefedcba98765432, "SDL with one byte offset failed")

	def test_a3(self):
		self.assertRegisterEqual(self.MIPS.a3, 0xfefefedcba987654, "SDL with two byte offset failed")

	def test_a4(self):
		self.assertRegisterEqual(self.MIPS.a4, 0xfefefefedcba9876, "SDL with three byte offset failed")

	def test_a5(self):
		self.assertRegisterEqual(self.MIPS.a5, 0xfefefefefedcba98, "SDL with four byte offset failed")

	def test_a6(self):
		self.assertRegisterEqual(self.MIPS.a6, 0xfefefefefefedcba, "SDL with five byte offset failed")

	def test_a7(self):
		self.assertRegisterEqual(self.MIPS.a7, 0xfefefefefefefedc, "SDL with six byte offset failed")

	def test_t0(self):
		self.assertRegisterEqual(self.MIPS.t0, 0xfefefefefefefefe, "SDL with seven byte offset failed")

	def test_t1(self):
		self.assertRegisterEqual(self.MIPS.t1, 0xfedcba9876543210, "SDL with full doubleword offset failed")
