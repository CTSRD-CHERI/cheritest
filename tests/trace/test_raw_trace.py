#-
# Copyright (c) 2013 Colin Rothwell
# All rights reserved.
#
# This software was developed by and Colin Rothwell as part of his summer
# internship.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 1.
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.  2. Redistributions in binary
# form must reproduce the above copyright notice, this list of conditions and
# the following disclaimer in the documentation and/or other materials provided
# with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
import sys
from cheritest_tools import BaseCHERITestCase


def read_trace_records(trace_file_name, record_count, record_width=32):
    with open(trace_file_name, 'rb') as trace_file:
        return trace_file.read(record_count * record_width)

class test_raw_trace(BaseCHERITestCase):
    def test_uncached(self):
        '''Test trace from uncached memory is as expected'''
        actual = read_trace_records('log/test_raw_trace.trace', 5)
        expected = read_trace_records('tests/trace/uncached_expected.trace', 5)
        self.assertEqual(actual, expected, 'Uncached trace mismatch. Use the '
                         'readtrace program to debug.')

    def test_cached(self):
        '''Test trace from cached memory is as expected'''
        actual = read_trace_records('log/test_raw_trace_cached.trace', 7)
        expected = read_trace_records('tests/trace/cached_expected.trace', 7)
        self.assertEqual(actual, expected, 'Cached trace mismatch. Use the '
                         'readtrace program to debug.')
