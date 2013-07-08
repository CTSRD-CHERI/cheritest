#
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

#
# Test that a floating point store clears the tag bit
#

class test_cp2_floatstore(BaseCHERITestCase):
    @attr('capabilities')
    @attr('float')
    def test_cp2_floatstore_1(self):
        '''Test that store float can be read back'''
        self.assertRegisterEqual(self.MIPS.a0, 0x01234567,
            "floating point load of floating point value returned incorrect result")

    @attr('capabilities')
    @attr('float')
    def test_cp2_floatstore_2(self):
        '''Test FP store followed by integer load'''
        self.assertRegisterEqual(self.MIPS.a1, 0x01234567,
            "integer load of floating point value returned incorrect result")

    @attr('capabilities')
    @attr('float')
    def test_cp2_floatstore_3(self):
        '''Test FP store followed by capability read'''
        self.assertRegisterEqual(self.MIPS.a2, 0x01234567,
            "capability load of floating point value returned incorrect result")

    @attr('capabilities')
    @attr('float')
    def test_cp2_floatstore_4(self):
        '''Test that floating point store clears the tag bit'''
        self.assertRegisterEqual(self.MIPS.a3, 0,
            "floating point store did not clear the tag bit")

