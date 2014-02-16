#-
# Copyright (c) 2014 Michael Roe
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

class test_cp2_x_clc_tlb(BaseCHERITestCase):

    @attr('capabilities')
    def test_cp2_clc_tlb_base(self):
        '''Test that capability load failed when TLB entry prohibited load'''
        self.assertRegisterEqual(self.MIPS.a3, 0x0, "clc loaded c1.base even though capbility load inhibit bit was set in the TLB")

    @attr('capabilities')
    def test_cp2_clc_tlb_length(self):
        '''Test that capability load failed when TLB entry prohibited load'''
        self.assertRegisterEqual(self.MIPS.a4, 0xffffffffffffffff, "clc loaded c1.length even though capbility load inhibit bit was set in the TLB")

    @attr('capabilities')
    def test_cp2_clc_tlb_progress(self):
        '''Test that test reaches the end of stage 4'''
        self.assertRegisterEqual(self.MIPS.a5, 4, "Test did not make it to the end of stage 4")

    @attr('capabilities')
    def test_cp2_clc_tlb_cause(self):
        '''Test that CP0 cause register is set correctly'''
        self.assertRegisterEqual((self.MIPS.a7 >> 2) & 0x1f, 16, "CP0.Cause.ExcCode was not set correctly when capability load failed due to capability load inhibited in the TLB entry")

