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

class test_llsc(BaseBsimTestCase):

    def test_ll_sc_success(self):
	'''That an uninterrupted ll+sc succeeds'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "Uninterrupted ll+sc failed")

    def test_ll_sc_value(self):
	'''That an uninterrupted ll+sc stored the right value'''
	self.assertRegisterEqual(self.MIPS.a1, 0xffffffff, "Uninterrupted ll+sc stored wrong value")

    def test_ll_ld_sc_success(self):
	'''That an uninterrupted ll+ld+sc succeeds'''
	self.assertRegisterEqual(self.MIPS.a2, 1, "Uninterrupted ll+ld+sc failed")

    def test_ll_add_sc_success(self):
	'''That an uninterrupted ll+add+sc succeeds'''
	self.assertRegisterEqual(self.MIPS.a3, 1, "Uninterrupted ll+add+sc failed")

    def test_ll_add_sc_value(self):
	'''That an uninterrupted ll+add+sc stored the right value'''
	self.assertRegisterEqual(self.MIPS.a4, 0, "Uninterrupted ll+add+sc stored wrong value")

    def test_ll_sw_sc_failure(self):
	'''That an ll+sw+sc spanning fails'''
	self.assertRegisterEqual(self.MIPS.t0, 0, "Interrupted ll+sw+sc succeeded")

    def test_ll_sw_sc_value(self):
	'''That an ll+sc spanning a store to the line does not store'''
	self.assertRegisterNotEqual(self.MIPS.a6, 1, "Interrupted ll+sw+sc stored value")

    def test_ll_tnei_sc_failure(self):
	'''That an ll+sc spanning a trap fails'''
	self.assertRegisterEqual(self.MIPS.a7, 0, "Interrupted ll+tnei+sc succeeded")
