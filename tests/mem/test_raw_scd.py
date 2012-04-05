#-
# Copyright (c) 2011 Steven J. Murdoch
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

class test_raw_scd(BaseCHERITestCase):
    @attr('llsc')
    def test_store(self):
        '''Store conditional of word to double word'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "Store conditional of word to double word failed")

    @attr('llsc')
    def test_load(self):
        '''Load of conditionally stored word from double word'''
        self.assertRegisterEqual(self.MIPS.a1, 0xfedcba9876543210, "Load of conditionally stored word from double word failed")

    @attr('llsc')
    def test_store_positive(self):
        '''Store conditional of positive word'''
        self.assertRegisterEqual(self.MIPS.a2, 1, "Store conditional of positive word failed")

    @attr('llsc')
    def test_load_positive(self):
        '''Load of conditionally stored positive word'''
        self.assertRegisterEqual(self.MIPS.a3, 1, "Load of conditionally stored positive word failed")

    @attr('llsc')
    def test_store_negative(self):
        '''Store conditional of negative word'''
        self.assertRegisterEqual(self.MIPS.a4, 1, "Store conditional of negative word failed")

    @attr('llsc')
    def test_load_negative(self):
        '''Load of conditionally stored negative word'''
        self.assertRegisterEqual(self.MIPS.a5, 0xffffffffffffffff, "Load of conditionally stored negative word failed")

    @attr('llsc')
    def test_store_pos_offset(self):
        '''Store conditional of word at positive offset'''
        self.assertRegisterEqual(self.MIPS.a6, 1, "Store conditional of word at positive offset failed")

    @attr('llsc')
    def test_load_pos_offset(self):
        '''Load of conditionally stored word from positive offset'''
        self.assertRegisterEqual(self.MIPS.a7, 2, "Load of conditionally stored word at positive offset failed")

    @attr('llsc')
    def test_store_neg_offset(self):
        '''Store conditional of word at negative offset'''
        self.assertRegisterEqual(self.MIPS.s0, 1, "Store conditional of word at negative offset failed")

    @attr('llsc')
    def test_load_neg_offset(self):
        '''Load of conditionally stored word from negative offset'''
        self.assertRegisterEqual(self.MIPS.s1, 1, "Load of conditionally stored word at negative offset failed")
        
    @attr('llsc')
    def test_store_load_linked_not_matching(self):
        '''Store conditional of word which should fail due to unmatching load linked address'''
        self.assertRegisterEqual(self.MIPS.s2, 0, "Store conditional of word to a different address than the link register succeeded")

    @attr('llsc')
    def test_load_load_linked_not_matching(self):
        '''Load of conditionally stored word from negative offset'''
        self.assertRegisterEqual(self.MIPS.s3, 0xfedcba9876543210, "Load of failed conditionally stored word returned an unexpected value")
