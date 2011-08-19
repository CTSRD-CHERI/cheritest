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

class test_raw_swr(BaseCHERITestCase):
	def test_a0(self):
		'''Test SWR with zero offset'''
		self.assertRegisterEqual(self.MIPS.a0, 0x9800000000000000, "SWR with zero offset failed")

	def test_a1(self):
		'''Test SWR with full word offset'''
		self.assertRegisterEqual(self.MIPS.a1, 0x9800000098000000, "SWR with full word offset failed")

	def test_a2(self):
		'''Test SWR with half word offset'''
		self.assertRegisterEqual(self.MIPS.a2, 0xdcba980098000000, "SWR with half word offset failed")

	def test_a3(self):
		'''Test SWR with one byte offset'''
		self.assertRegisterEqual(self.MIPS.a3, 0xdcba9800fedcba98, "SWR with three byte offset failed")

	def test_a4(self):
		'''Test SWR with three byte offset'''
		self.assertRegisterEqual(self.MIPS.a4, 0xdcba9800ba98ba98, "SWR with one byte offset failed")
