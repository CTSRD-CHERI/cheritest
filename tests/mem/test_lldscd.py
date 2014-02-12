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
from cheritest_tools import BaseCHERITestCase
from nose.plugins.attrib import attr

class test_lldscd(BaseCHERITestCase):

    @attr('llsc')
    @attr('cached')
    def test_lld_scd_success(self):
	'''That an uninterrupted lld+scd succeeds'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "Uninterrupted lld+scd failed")

    @attr('llsc')
    @attr('cached')
    def test_lld_scd_value(self):
	'''That an uninterrupted lld+scd stored the right value'''
	self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff, "Uninterrupted lld+scd stored wrong value")

    @attr('llsc')
    @attr('cached')
    def test_lld_ld_scd_success(self):
	'''That an uninterrupted lld+ld+scd succeeds'''
	self.assertRegisterEqual(self.MIPS.a2, 1, "Uninterrupted lld+ld+scd failed")

    @attr('llsc')
    @attr('cached')
    def test_lld_add_scd_success(self):
	'''That an uninterrupted lld+add+scd succeeds'''
	self.assertRegisterEqual(self.MIPS.a3, 1, "Uninterrupted lld+add+scd failed")

    @attr('llsc')
    @attr('cached')
    def test_lld_add_scd_value(self):
	'''That an uninterrupted lld+add+scd stored the right value'''
	self.assertRegisterEqual(self.MIPS.a4, 0, "Uninterrupted lld+add+scd stored wrong value")

    @attr('llsc')
    @attr('cached')
    def test_lld_sd_scd_failure(self):
	'''That an lld+sd+scd spanning a store to the line fails'''
	self.assertRegisterEqual(self.MIPS.t0, 0, "Interrupted lld+sd+scd succeeded")

    @attr('llsc')
    @attr('cached')
    def test_lld_sd_scd_value(self):
	'''That an lld+scd spanning a store to the line does not store'''
	self.assertRegisterNotEqual(self.MIPS.a6, 1, "Interrupted lld+sd+scd stored value")

    @attr('llsc')
    @attr('cached')
    def test_lld_tnei_scd_failure(self):
	'''That an lld+scd spanning a trap fails'''
	self.assertRegisterEqual(self.MIPS.a7, 0, "Interrupted lld+tnei+scd succeeded")
