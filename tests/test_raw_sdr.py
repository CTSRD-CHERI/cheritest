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
from bsim_utils import BaseBsimTestCase

class raw_sdr(BaseBsimTestCase):
	def test_a1(self):
		self.assertRegisterEqual(self.MIPS.a1, 0x1000000000000000, "SDR with zero offset failed")

	def test_a2(self):
		self.assertRegisterEqual(self.MIPS.a2, 0x3210000000000000, "SDR with one byte offset failed")

	def test_a3(self):
		self.assertRegisterEqual(self.MIPS.a3, 0x5432100000000000, "SDR with two byte offset failed")

	def test_a4(self):
		self.assertRegisterEqual(self.MIPS.a4, 0x7654321000000000, "SDR with three byte offset failed")

	def test_a5(self):
		self.assertRegisterEqual(self.MIPS.a5, 0x9876543210000000, "SDR with four byte offset failed")

	def test_a6(self):
		self.assertRegisterEqual(self.MIPS.a6, 0xba98765432100000, "SDR with five byte offset failed")

	def test_a7(self):
		self.assertRegisterEqual(self.MIPS.a7, 0xdcba987654321000, "SDR with six byte offset failed")

	def test_t0(self):
		self.assertRegisterEqual(self.MIPS.t0, 0xfedcba9876543210, "SDR with seven byte offset failed")

	def test_t1(self):
		self.assertRegisterEqual(self.MIPS.t1, 0x1000000000000000, "SDR with full doubleword offset failed")
