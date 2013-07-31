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

class test_raw_fpu_abs(BaseCHERITestCase):
    def test_abs_single(self):
        '''Test we can take absolute value of a float'''
        self.assertRegisterEqual(self.MIPS.s1, 0x0FFF0000, "Failed to take absolute of single")

    @attr('float64')
    def test_abs_double(self):
        '''Test we can take absolute value of a double'''
        self.assertRegisterEqual(self.MIPS.s0, 0x07FF000000000000, "Failed to take absolute of double")

    @attr('floatpaired')
    def test_abs_paired(self):
        '''Test we can take absolute values of paired single'''
        self.assertRegisterEqual(self.MIPS.s2, 0x3F80000040000000, "Failed to take absolute of paired single")

    @attr('floatpaired')
    def test_abs_paired_qnan(self):
        '''Test abs of a paired single where one element is QNaN'''
        self.assertRegisterEqual(self.MIPS.s3, 0x7F81000040000000, "abs.ps failed to echo QNaN")

    def test_abs_single_denorm(self):
        '''Test that sub.s flushes denormalized results to zero'''
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "sub.s failed to flush denormalised result")
