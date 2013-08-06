#-
# Copyright (c) 2011 Steven J. Murdoch
# Copyright (c) 2012 Robert M. Norton
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

# Test for a sequence of instructions on Cheri2 that triggered a bug.
# Problem occurs when a branch is already past execute when an exception
# occurs which lands on a branch.

class test_raw_tlb_j(BaseCHERITestCase):

    @attr('tlb')
    def test_before_jr(self):
        '''Test that instruction before TLB miss is executed'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before TLB miss was not executed")

    @attr('tlb')
    def test_after_miss1(self):
        self.assertRegisterEqual(self.MIPS.a1, 0, "instruction after exception executed")

    @attr('tlb')
    def test_after_miss2(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "instruction after exception executed")

    @attr('tlb')
    def test_after_miss3(self):
        self.assertRegisterEqual(self.MIPS.a3, 0, "instruction after exception executed")

    @attr('tlb')
    def test_jr_target(self):
        '''Test that execute instruction after returning from TLB miss handler'''
        self.assertRegisterEqual(self.MIPS.a4, 5, "instruction at jump target not executed")

    @attr('tlb')
    def test_miss_vector(self):
        self.assertRegisterEqual(self.MIPS.a5, 6, "instruction at miss vector not executed")

    @attr('tlb')
    def test_miss_vector_wrongpath(self):
        self.assertRegisterNotEqual(self.MIPS.a6, 7, "took wrong path in exception vector.")
