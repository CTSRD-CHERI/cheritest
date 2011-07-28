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

class test_cp0_compare(BaseCHERITestCase):
    def test_compare_readback(self):
        '''Test that CP0 compare register write succeeded'''
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a1, "CP0 compare register write failed")

    def test_cycle_count(self):
        ''' Test that cycle counter interrupted CPU at the right moment'''
	self.assertRegisterInRange(self.MIPS.a2, self.MIPS.a0 - 10, self.MIPS.a0 + 10, "Unexpected CP0 count cycle register value on reset")

    def test_interrupt_fired(self):
        '''Test that compare register triggered interrupt'''
        self.assertRegisterEqual(self.MIPS.a5, 1, "Exception didn't fire")

    def test_eret_happened(self):
        '''Test that eret occurred'''
        self.assertRegisterEqual(self.MIPS.a3, 1, "Exception didn't return")

#    def test_cause_bd(self):
#        '''Test that branch-delay slot flag in cause register not set in exception'''
#        self.assertRegisterEqual((self.MIPS.a7 >> 31) & 0x1, 0, "Branch delay (BD) flag set")

    def test_cause_ip(self):
        '''Test that interrupt pending (IP) bit set in cause register'''
        self.assertRegisterEqual((self.MIPS.a7 >> 8) & 0xff, 0x80, "IP7 flag not set")

    def test_cause_code(self):
        '''Test that exception code is set to "interrupt"'''
        self.assertRegisterEqual((self.MIPS.a7 >> 2) & 0x1f, 0, "Code not set to Int")

    def test_exl_in_handler(self):
        self.assertRegisterEqual((self.MIPS.a6 >> 1) & 0x1, 1, "EXL not set in exception handler")

    def test_cause_ip_cleared(self):
	'''Test that writing to the CP0 compare register cleared IP7'''
	self.assertRegisterEqual((self.MIPS.s0 >> 8) & 0xff, 0, "IP7 flag not cleared")

    def test_not_exl_after_handler(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 1) & 0x1, 0, "EXL still set after ERET")

