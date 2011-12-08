#-
# Copyright (c) 2011 Robert M. Norton
# All rights reserved.
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
# A nose test which returns a generator to iterate over fuzz test cases.
# Performs a test for every .s file in the TEST_DIR which matches TEST_FILE_RE.
# Compare the log files from gxemul and bluesim to check that the registers
# ended up the same.

import tools.gxemul, tools.sim
import os, re, itertools

# Parameters from the environment
# Cached or uncached mode.
CACHED = bool(int(os.environ.get("CACHED", "0")))
# Pass to restrict to only a particular test
ONLY_TEST = os.environ.get("ONLY_TEST", None)

TEST_FILE_RE=re.compile('test_fuzz_\d+.s')
TEST_DIR ='tests/fuzz'

#Not derived from unittest.testcase because we wish test_fuzz to
#return a generator.
class TestFuzz(object):
    def test_fuzz(self):
        if ONLY_TEST:
            yield ('check_answer', ONLY_TEST)
        else:
            for test in itertools.ifilter(lambda f: TEST_FILE_RE.match(f) ,os.listdir(TEST_DIR)):
                test_name=os.path.splitext(os.path.basename(test))[0]
                yield ('check_answer', test_name)
                
    def check_answer(self, test_name):
        if CACHED:
            cached="_cached"
        else:
            cached=""
        sim_log = open(os.path.join("log",test_name+cached+".log"), 'rt')
        sim_status=tools.sim.MipsStatus(sim_log)

        gxemul_log = open(os.path.join("gxemul_log", test_name + '_gxemul' +cached + ".log"), 'rt')
        gxemul_status= tools.gxemul.MipsStatus(gxemul_log)
        
        for reg in xrange(len(tools.gxemul.MIPS_REG_NUM2NAME)):
            assert sim_status[reg] == gxemul_status[reg], "%s: (sim) 0x%016x != 0x%016x (gxemul) " % (tools.gxemul.MIPS_REG_NUM2NAME[reg], sim_status[reg], gxemul_status[reg])
