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

#
# Test that ctoptr raises a C2E exception if the capability to be converted
# does not lie within the range of $ct.
#

class test_cp2_x_ctoptr_length(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_x_ctoptr_length_1(self):
        '''Test ctoptr did not change destination register when an exception was raised'''
        self.assertRegisterEqual(self.MIPS.a1, 1,
            "ctoptr changed the destination register when an exception was raised")

    @attr('capabilities')
    def test_cp2_x_ctoptr_length_2(self):
        '''Test ctoptr raised a C2E exception cb.base < ct.base'''
        self.assertRegisterEqual(self.MIPS.a2, 1,
            "ctoptr did not raise an exception when cb.base < ct.base")

    @attr('capabilities')
    def test_cp2_x_ctoptr_length_4(self):
        '''Test ctoptr sets capability cause when cb.base < ct.base'''
        self.assertRegisterEqual(self.MIPS.a3, 0x0102,
            "ctoptr did not set Capability cause correcly when cb.base < ct.base")

