#-
# Copyright (c) 2011 Robert N. M. Watson
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
# XXX: our test code saves the CP0 config register in self.MIPS.s1 so that
# we can determine how this test should behave.  Our test cases don't
# currently check that, so may return undesired failures.  The third check
# below should be conditioned on (DC > 0) || (SC == 1) -- i.e., a cache is
# present, which might cause it not to incorrectly fire for gxemul.
#

class test_cache_instruction(BaseCHERITestCase):

    @attr('cache')
    def test_initial_uncached_read(self):
        self.assertRegisterEqual(self.MIPS.a0, 0, "Initial read of count register is incorrect")
        
    def test_initial_cached_read(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "Initial cached read failure")
        
    def test_second_cached_read(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "Second cached read failure")
        
    def test_after_L1_writeback_cached_read(self):
        self.assertRegisterEqual(self.MIPS.a3, 1, "Cached read after data L1 writeback is incorrect")
        
    def test_after_L1_writeback_invalidate_cached_read(self):
        self.assertRegisterEqual(self.MIPS.a4, 1, "Cached read after data L1 writeback/invalidate is incorrect")
        
    def test_after_L1_invalidate_cached_read(self):
        self.assertRegisterEqual(self.MIPS.a5, 1, "Cached read after data L1 invalidate is incorrect")
        
    def test_after_L1_and_L2_invalidate_cached_read(self):
        self.assertRegisterEqual(self.MIPS.a6, 2, "Cached read after data and L2 invalidate is incorrect")
        
    def test_after_L2_invalidate_cached_read(self):
        self.assertRegisterEqual(self.MIPS.a7, 2, "Cached read after L2 invalidate is incorrect")
