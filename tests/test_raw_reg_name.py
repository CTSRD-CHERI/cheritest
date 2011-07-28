#-
# Copyright (c) 2011 Steven J. Murdoch
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

#
# This test makes sure that the python framework agrees with the assembler as
# to what the names of various registers are.  This is important as different
# MIPS ABIs disagree on how many temporary vs. argument registers there are.
# This is not about hardware bugs, it is about test framework and assembler
# bugs/mismatches.
#

class raw_reg_name(BaseCHERITestCase):
    def test_reg_zero(self):
	'''Test register $zero'''
	self.assertRegisterEqual(self.MIPS.zero, 0, "register $zero mismatch")

    def test_reg_at(self):
	'''Test register $at'''
	self.assertRegisterEqual(self.MIPS.at, 1, "register $at mismatch")

    def test_reg_v0(self):
	'''Test register $v0'''
	self.assertRegisterEqual(self.MIPS.v0, 2, "register $v0 mismatch")

    def test_reg_v1(self):
	'''Test register $v1'''
	self.assertRegisterEqual(self.MIPS.v1, 3, "register $v1 mismatch")

    def test_reg_a0(self):
	'''Test register $a0'''
	self.assertRegisterEqual(self.MIPS.a0, 4, "register $a0 mismatch")

    def test_reg_a1(self):
	'''Test register $a1'''
	self.assertRegisterEqual(self.MIPS.a1, 5, "register $a1 mismatch")

    def test_reg_a2(self):
	'''Test register $a2'''
	self.assertRegisterEqual(self.MIPS.a2, 6, "register $a2 mismatch")

    def test_reg_a3(self):
	'''Test register $a3'''
	self.assertRegisterEqual(self.MIPS.a3, 7, "register $a3 mismatch")

    def test_reg_a4(self):
	'''Test register $a4'''
	self.assertRegisterEqual(self.MIPS.a4, 8, "register $a4 mismatch")

    def test_reg_a5(self):
	'''Test register $a5'''
	self.assertRegisterEqual(self.MIPS.a5, 9, "register $a5 mismatch")

    def test_reg_a6(self):
	'''Test register $a6'''
	self.assertRegisterEqual(self.MIPS.a6, 10, "register $a6 mismatch")

    def test_reg_a7(self):
	'''Test register $a7'''
	self.assertRegisterEqual(self.MIPS.a7, 11, "register $a7 mismatch")

    def test_reg_t0(self):
	'''Test register $t0'''
	self.assertRegisterEqual(self.MIPS.t0, 12, "register $t0 mismatch")

    def test_reg_t1(self):
	'''Test register $t1'''
	self.assertRegisterEqual(self.MIPS.t1, 13, "register $t1 mismatch")

    def test_reg_t2(self):
	'''Test register $t2'''
	self.assertRegisterEqual(self.MIPS.t2, 14, "register $t2 mismatch")

    def test_reg_t3(self):
	'''Test register $t3'''
	self.assertRegisterEqual(self.MIPS.t3, 15, "register $t3 mismatch")

    def test_reg_s0(self):
	'''Test register $s0'''
	self.assertRegisterEqual(self.MIPS.s0, 16, "register $s0 mismatch")

    def test_reg_s1(self):
	'''Test register $s1'''
	self.assertRegisterEqual(self.MIPS.s1, 17, "register $s1 mismatch")

    def test_reg_s2(self):
	'''Test register $s2'''
	self.assertRegisterEqual(self.MIPS.s2, 18, "register $s2 mismatch")

    def test_reg_s3(self):
	'''Test register $s3'''
	self.assertRegisterEqual(self.MIPS.s3, 19, "register $s3 mismatch")

    def test_reg_s4(self):
	'''Test register $s4'''
	self.assertRegisterEqual(self.MIPS.s4, 20, "register $s4 mismatch")

    def test_reg_s5(self):
	'''Test register $s5'''
	self.assertRegisterEqual(self.MIPS.s5, 21, "register $s5 mismatch")

    def test_reg_s6(self):
	'''Test register $s6'''
	self.assertRegisterEqual(self.MIPS.s6, 22, "register $s6 mismatch")

    def test_reg_s7(self):
	'''Test register $s7'''
	self.assertRegisterEqual(self.MIPS.s7, 23, "register $s7 mismatch")

    def test_reg_t8(self):
	'''Test register $t8'''
	self.assertRegisterEqual(self.MIPS.t8, 24, "register $t8 mismatch")

    def test_reg_t9(self):
	'''Test register $t9'''
	self.assertRegisterEqual(self.MIPS.t9, 25, "register $t9 mismatch")

    def test_reg_k0(self):
	'''Test register $k0'''
	self.assertRegisterEqual(self.MIPS.k0, 26, "register $k0 mismatch")

    def test_reg_k1(self):
	'''Test register $k1'''
	self.assertRegisterEqual(self.MIPS.k1, 27, "register $k1 mismatch")

    def test_reg_gp(self):
	'''Test register $gp'''
	self.assertRegisterEqual(self.MIPS.gp, 28, "register $gp mismatch")

    def test_reg_sp(self):
	'''Test register $sp'''
	self.assertRegisterEqual(self.MIPS.sp, 29, "register $sp mismatch")

    def test_reg_fp(self):
	'''Test register $fp'''
	self.assertRegisterEqual(self.MIPS.fp, 30, "register $fp mismatch")

    def test_reg_ra(self):
	'''Test register $ra'''
	self.assertRegisterEqual(self.MIPS.ra, 31, "register $ra mismatch")
