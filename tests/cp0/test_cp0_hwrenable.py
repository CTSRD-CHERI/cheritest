#
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


class test_cp0_hwrenable(BaseCHERITestCase):

    @attr('rdhwr')
    def test_cp0_hwrenable_1(self):
        '''Test can write and read 0 from CP0.HWREna'''
        self.assertRegisterEqual(self.MIPS.a0, 0x0, "Did not read 0 from CP0.HWREna")

    @attr('rdhwr')
    def test_cp0_hwrenable_2(self):
        '''Test can set and read bit 2 (cycle counter) from CP0.HWREna'''
        self.assertRegisterEqual(self.MIPS.a1, 0x4, "Cycle counter enable was not set in CP0.HWREna")

    @attr('rdhwr')
    @attr('userlocal')
    def test_cp0_hwrenable_3(self):
        '''Test can set and read bit 29 (user local) from CP0.HWREna'''
        self.assertRegisterEqual(self.MIPS.a2, 1 << 29, "User local enable was not set in CP0.HWREna")

