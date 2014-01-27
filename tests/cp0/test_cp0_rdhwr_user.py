#-
# Copyright (c) 2011 Robert N. M. Watson
#               2012 Robert M. Norton
#               2013 Michael Roe
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

class test_cp0_rdhwr_user(BaseCHERITestCase):

    @attr('tlb')
    @attr('rdhwr')
    def test_exception_fired(self):
        '''Test that rdhwr throws an exception if don't have permission'''
        self.assertRegisterEqual(self.MIPS.a5, 1, "rdhwr did not throw an exception when didn't have permission")

    @attr('tlb')
    @attr('rdhwr')
    def test_cause_code(self):
        '''Test that rdhwr sets the exception code to "reserved instruction" if don't have permission.'''
        self.assertRegisterEqual((self.MIPS.a7 >> 2) & 0x1f, 10, "rdhwr did not set cause to reserved instruction exception.")

    @attr('tlb')
    @attr('rdhwr')
    def test_exl_in_handler(self):
        '''Test EXL set in status register.'''
        self.assertRegisterEqual((self.MIPS.a6 >> 1) & 0x1, 1, "EXL not set in exception handler")

