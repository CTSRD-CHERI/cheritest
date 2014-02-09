#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2013 Robert M. Norton
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

class test_cp0_ri(BaseCHERITestCase):
    @attr('nofloat')
    def test_interrupt_fired(self):
        '''Test that ri triggered exception'''
        self.assertRegisterEqual(self.MIPS.a2, 1, "Exception didn't fire")

    @attr('nofloat')
    def test_eret_happened(self):
        '''Test that eret occurred'''
        self.assertRegisterEqual(self.MIPS.a1, 1, "Exception didn't return")

    @attr('nofloat')
    def test_cause_code(self):
        '''Test that exception code is set to "ri" in cause register.'''
        self.assertRegisterEqual((self.MIPS.a4 >> 2) & 0x1f, 10, "Cause not set to RI.")

    @attr('nofloat')
    def test_exl_in_handler(self):
        '''Test EXL set in status register.'''
        self.assertRegisterEqual((self.MIPS.a3 >> 1) & 0x1, 1, "EXL not set in exception handler")

    @attr('nofloat')
    def test_epc_in_handler(self):
        '''Test that EPC matches desired value.'''
        self.assertRegisterEqual(self.MIPS.a5, self.MIPS.a0, "EPC not correct in exception handler")


