# -
# Copyright (c) 2017 Alex Richardson
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

from beritest_tools import TestClangBase
import os
import pytest
import re
from beritest_tools import attr

# Parameters from the environment
# Cached or uncached mode.
CACHED = bool(int(os.environ.get("CACHED", "0")))
MULTI = bool(int(os.environ.get("MULTI1", "0")))
# Pass to restrict to only a particular test
ONLY_TEST = os.environ.get("ONLY_TEST", None)

TEST_FILE_RE = re.compile('test_[\w_]*clang_\w+\.c')
TEST_DIR = os.path.dirname(os.path.abspath(__file__))

LOG_DIR = pytest.config.option.LOGDIR


def check_answer(test_name, test_file):
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
        TestClangBase.verify_clang_test(sim_log, test_name, test_file)


def _is_xfail(test_name):
    # L3 doesn't implement the statcounters instructions
    if os.getenv("TEST_MACHINE", "").lower() in ("l3", "sail"):
        if test_name in ("test_purecap_statcounters",):
            return True
    return False


def _get_tests_function(test_name):
    return pytest.mark.xfail(_is_xfail(test_name))(check_answer)


def get_all_tests():
    if ONLY_TEST:
        return ONLY_TEST
    return filter(lambda f: TEST_FILE_RE.match(f), os.listdir(TEST_DIR))


@pytest.mark.parametrize("test", get_all_tests())
@attr('clang')
@attr('capabilities')
def test_clang_dma(test):
    test_name = os.path.splitext(os.path.basename(test))[0]
    test_file = os.path.join(TEST_DIR, test)
    test_func = _get_tests_function(test_name)
    test_func(test_name, test_file)
