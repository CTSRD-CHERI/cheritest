#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2013 Alexandre Joannou
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
from cheritest_tools import BaseICacheCHERITestCase
from nose.plugins.attrib import attr

#
# XXX: our test code saves the CP0 config register in self.MIPS.s1 so that
# we can determine how this test should behave. Our test cases don't
# currently check that, so may return undesired failures. The third check
# below should be conditioned on (DC > 0) || (SC == 1) -- i.e., a cache is
# present, which might cause it not to incorrectly fire for gxemul.
#

class test_cache_instruction_instruction(BaseICacheCHERITestCase):

    @attr('cache')
    def test_completion(self):
        self.assertTagInvalid ( 10  , "icache line index 10  was not invalidated" )
        self.assertTagValid   ( 20  , "icache line index 20  was not fetched"     )
        self.assertTagInvalid ( 132 , "icache line index 132 was not invalidated" )
        self.assertTagValid   ( 227 , "icache line index 227 was not fetched"     )
        self.assertTagValid   ( 83  , "icache line index 83  was not fetched"     )
        self.assertTagValid   ( 500 , "icache line index 500 was not fetched"     )
        self.assertTagInvalid ( 404 , "icache line index 404 was not invalidated" )
