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
from bsim_utils import BaseBsimTestCase

class raw_ldl(BaseBsimTestCase):
	def test_offset_zero(self):
		self.assertRegisterEqual(self.MIPS.a1, 0xfedcba9876543210, "LDL with zero offset failed")

	def test_offset_one(self):
		self.assertRegisterEqual(self.MIPS.a2, 0xdcba987654321000, "LDL with one offset failed")

	def test_offset_two(self):
		self.assertRegisterEqual(self.MIPS.a3, 0xba98765432100000, "LDL with two offset failed")

	def test_offset_three(self):
		self.assertRegisterEqual(self.MIPS.a4, 0x9876543210000000, "LDL with three offset failed")

	def test_offset_four(self):
		self.assertRegisterEqual(self.MIPS.a5, 0x7654321000000000, "LDL with four offset failed")

	def test_offset_five(self):
		self.assertRegisterEqual(self.MIPS.a6, 0x5432100000000000, "LDL with five offset failed")

	def test_offset_six(self):
		self.assertRegisterEqual(self.MIPS.a7, 0x3210000000000000, "LDL with six offset failed")

	def test_offset_seven(self):
		self.assertRegisterEqual(self.MIPS.t0, 0x1000000000000000, "LDL with seven offset failed")

	def test_offset_eight(self):
		self.assertRegisterEqual(self.MIPS.t1, 0x0000000000000000, "LDL with eight offset (skip double word) failed")
