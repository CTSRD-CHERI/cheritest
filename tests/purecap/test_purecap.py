# -
# Copyright (c) 2011 Robert M. Norton
# All rights reserved.
#
# @BERI_LICENSE_HEADER_START@
#
# Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  BERI licenses this
# file to you under the BERI Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://www.beri-open-systems.org/legal/license-1-0.txt
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @BERI_LICENSE_HEADER_END@
#
# A nose test which returns a generator to iterate over clang tests.
# Performs a test for every .c file in the TEST_DIR which matches TEST_FILE_RE.
# Just checks that the test produced the appropriate pass value in v0 to indicate
# that all c asserts passed. Cribbed from tests/fuzz/fuzz.py.

import tools.gxemul, tools.sim
import os, re, itertools
from nose.plugins.attrib import attr

# Parameters from the environment
# Cached or uncached mode.
CACHED = bool(int(os.environ.get("CACHED", "0")))
MULTI = bool(int(os.environ.get("MULTI1", "0")))
# Pass to restrict to only a particular test
ONLY_TEST = os.environ.get("ONLY_TEST", None)

TEST_FILE_RE = re.compile('test_.+\.c')
TEST_DIR = os.path.dirname(os.path.abspath(__file__))

LOG_DIR = os.environ.get("LOGDIR", "log")


# Not derived from unittest.testcase because we wish test_clang to
# return a generator.
class TestClang(object):
    @attr('clang')
    @attr('capabilities')
    def test_purecap(self):
        if ONLY_TEST:
            yield ('check_answer', ONLY_TEST)
        else:
            for test in filter(lambda f: TEST_FILE_RE.match(f),
                               os.listdir(TEST_DIR)):
                test_name = os.path.splitext(os.path.basename(test))[0]
                yield ('check_answer', test_name)

    def check_answer(self, test_name):
        if MULTI and CACHED:
            suffix = "_cachedmulti"
        elif MULTI:
            suffix = "_multi"
        elif CACHED:
            suffix = "_cached"
        else:
            suffix = ""
        with open(os.path.join(LOG_DIR, test_name + suffix + ".log"),
                  'rt') as sim_log:
            sim_status = tools.sim.MipsStatus(sim_log)
            exit_code = sim_status[2]  # load the assertion failure kind from $v0
            line_number = sim_status[4]  # load the assertion line number from $a0
            exception_count = sim_status[26] # exception count should be in $k0
            exception_message = ""
            if exit_code != 0:
                # -1/0xdead0000 -> general assertion failure
                if exit_code == 0xffffffffffffffff or exit_code == 0xdead0000:
                    exception_message = "clang assert failed at line %d: %s" % (
                        line_number, self.get_line(test_name, line_number))
                elif exit_code == 0xdead0001:
                    # the values are stored in a1 and a2 (registers 5 and 6)
                    exception_message = "clang assert_eq long failed at line %d: %s" % (line_number, self.get_line(test_name, line_number))
                    dec_and_hex = lambda value: "0x%016x (%d)" % (value, value)
                    exception_message += "\n>>>> Expected: " + dec_and_hex(sim_status[5])
                    exception_message += "\n>>>> Actual:   " + dec_and_hex(sim_status[6])
                elif exit_code == 0xdead000c:
                    # the values are stored in c3 and c4
                    exception_message = "clang assert_eq cap failed at line %d: %s" % (line_number, self.get_line(test_name, line_number))
                    exception_message += "\n>>>> Expected: " + str(sim_status.threads[0].cp2[3])
                    exception_message += "\n>>>> Actual:   " + str(sim_status.threads[0].cp2[4])
                else:
                    exception_message = "unknown test exit status %d" % (exit_code)
                if exception_count != 0:
                    exception_message += "\nNOTE: %d exceptions occurred, check test log!" % exception_count
                assert False, exception_message

    def get_line(self, test_name, line_number):
        with open(os.path.join(TEST_DIR, test_name + '.c')) as src_file:
            return src_file.readlines()[line_number - 1].strip()
