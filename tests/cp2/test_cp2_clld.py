#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2013 Michael Roe
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

class test_cp2_clld(BaseCHERITestCase):

    @attr('llsc')
    @attr('cached')
    @attr('capabilities')
    def test_cp2_clld_1(self):
	'''That an uninterrupted clld+cscd succeeds'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "Uninterrupted clld+cscd failed")

    @attr('llsc')
    @attr('cached')
    @attr('capabilities')
    def test_cp2_clld_2(self):
	'''That an uninterrupted clld+cscd stored the right value'''
	self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff, "Uninterrupted clld+cscd stored wrong value")

    @attr('llsc')
    @attr('cached')
    @attr('capabilities')
    def test_cp2_clld_3(self):
	'''That an uninterrupted clld+cld+cscd succeeds'''
	self.assertRegisterEqual(self.MIPS.a2, 1, "Uninterrupted clld+cld+cscd failed")

    @attr('llsc')
    @attr('cached')
    @attr('capabilities')
    def test_cp2_clld_4(self):
	'''That an uninterrupted clld+add+cscd succeeds'''
	self.assertRegisterEqual(self.MIPS.a3, 1, "Uninterrupted clld+add+cscd failed")

    @attr('llsc')
    @attr('cached')
    @attr('capabilities')
    def test_cp2_clld_5(self):
	'''That an uninterrupted clld+add+cscd stored the right value'''
	self.assertRegisterEqual(self.MIPS.a4, 0, "Uninterrupted clld+add+cscd stored wrong value")

    @attr('llsc')
    @attr('cached')
    @attr('capabilities')
    def test_cp2_clld_6(self):
	'''That an clld+csd+cscd spanning fails'''
	self.assertRegisterEqual(self.MIPS.t0, 0, "Interrupted clld+csd+cscd succeeded")

    @attr('llsc')
    @attr('cached')
    @attr('capabilities')
    def test_cp2_clld_7(self):
	'''That an clld+cscd spanning a store to the line does not store'''
	self.assertRegisterNotEqual(self.MIPS.a6, 1, "Interrupted clld+csd+cscd stored value")

    @attr('llsc')
    @attr('cached')
    @attr('capabilities')
    def test_cp2_clld_8(self):
	'''That an clld+cscd spanning a trap fails'''
	self.assertRegisterEqual(self.MIPS.a7, 0, "Interrupted clld+tnei+cscd succeeded")
