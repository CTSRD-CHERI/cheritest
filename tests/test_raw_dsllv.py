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

class test_raw_dsllv(BaseCHERITestCase):
        def test_a1(self):
		'''Test a DSLLV of zero'''
		self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a1, 0xfedcba9876543210, "Shift of zero failed")

	def test_a2(self):
		'''Test a DSLLV of one'''
		self.assertRegisterEqual(self.MIPS.a2, 0xfdb97530eca86420, "Shift of one failed")

	def test_a3(self):
		'''Test a DSLLV of sixteen'''
		self.assertRegisterEqual(self.MIPS.a3, 0xba98765432100000, "Shift of sixteen failed")

	def test_a4(self):
		'''Test a DSLLV of 32'''
		self.assertRegisterEqual(self.MIPS.a4, 0x7654321000000000, "Shift of thirty-two failed")

	def test_a5(self):
		'''Test a DSLLV of 43'''
		self.assertRegisterEqual(self.MIPS.a5, 0xa190800000000000, "Shift of fourty-three failed")

	def test_a6(self):
		'''Test a DSLLV pf 63(max)'''
		self.assertRegisterEqual(self.MIPS.a6, 0x0000000000000000, "Shift of sixty-three failed")
