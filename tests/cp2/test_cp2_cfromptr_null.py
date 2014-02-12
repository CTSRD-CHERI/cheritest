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
# Test that cfromptr creates a null capability when given the NULL pointer
# as input.
#

class test_cp2_cfromptr_null(BaseCHERITestCase):

    @attr('capabilities')
    def test_cp2_cfromptr_null_perm(self):
        '''Test that cfromptr of a NULL pointer clears the permissions field'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "cfromptr did not clear the permissions field")

    @attr('capabilities')
    def test_cp2_cfromptr_null_base(self):
        '''Test that cfromptr of a NULL pointer clears the base field'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "cfromptr did not clear the base field")

    @attr('capabilities')
    def test_cp2_cfromptr_null_length(self):
        '''Test that cfromptr of a NULL pointer clears the length field'''
        self.assertRegisterEqual(self.MIPS.a2, 0, "cfromptr did not clear the length field")

    @attr('capabilities')
    def test_cp2_cfromptr_null_type(self):
        '''Test that cfromptr of a NULL pointer clears the type field'''
        self.assertRegisterEqual(self.MIPS.a3, 0, "cfromptr did not clear the type field")

    @attr('capabilities')
    def test_cp2_cfromptr_null_tag(self):
        '''Test that cfromptr of a NULL pointer sets the tag bit'''
        self.assertRegisterEqual(self.MIPS.a4, 1, "cfromptr did not set the tag bit")

    @attr('capabilities')
    def test_cp2_cfromptr_null_unsealed(self):
        '''Test that cfromptr of a NULL pointer clears the unsealed bit'''
        self.assertRegisterEqual(self.MIPS.a5, 0, "cfromptr did not clear the unsealed bit")

