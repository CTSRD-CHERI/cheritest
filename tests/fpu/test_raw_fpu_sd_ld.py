#-
# Copyright (c) 2013-2013 Ben Thorner, Colin Rothwell
# All rights reserved.
#
# This software was developed by Ben Thorner as part of his summer internship
# and Colin Rothwell as part of his final year undergraduate project.
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

class test_raw_fpu_sd_ld(BaseCHERITestCase):

    @attr('float64')
    def test_preloaded(self):
        '''Test can load double from memory'''
        self.assertRegisterEqual(self.MIPS.s0, 0x0123456789abcdef, 'Failed to load preloaded double.')

    @attr('float64')
    def test_offset(self):
        '''Test we can store doubles at location offsets.'''
        self.assertRegisterEqual(self.MIPS.s1, 0xBED0000000000000, 'Failed to save and load offset 0.')
        self.assertRegisterEqual(self.MIPS.s2, 0x1212000000000000, 'Failed to save and load offset 4.')
