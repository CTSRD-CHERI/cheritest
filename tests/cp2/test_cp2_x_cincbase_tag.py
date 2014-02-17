#-
# Copyright (c) 2012 Michael Roe
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
# Test that cincbase raises a C2E exception if the tag bit is not set on
# the capability register.
#

class test_cp2_x_cincbase_tag(BaseCHERITestCase):
    @attr('capabilities')
    def test_cp2_x_cincbase_tag_1(self):
        '''Test cincbase did not increment an untagged capability'''
        self.assertRegisterEqual(self.MIPS.a0, 0,
            "cincbase incremented a capability with tag bit unset")

    @attr('capabilities')
    def test_cp2_x_cincbase_tag_2(self):
        '''Test cincbase raised a C2E exception when capability tag was unset'''
        self.assertRegisterEqual(self.MIPS.a2, 1,
            "cincbase did not raise an exception when capability tag was unset")

    @attr('capabilities')
    def test_cp2_x_cincbase_tag_3(self):
        '''Test capability cause is set correctly when capability tag was unset'''
        self.assertRegisterEqual(self.MIPS.a3, 0x0201,
            "Capability cause was not set correcly when capability tag was unset")

