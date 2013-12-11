#!/usr/bin/env python
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

# Script to export a fuzz test as a regression test.

import tools.gxemul, tools.sim
import os

def export_test(test_name, options):
    uncached_gxemul_log    = open(os.path.join("gxemul_log", test_name + '_gxemul.log'), 'rt')
    uncached_gxemul_status = tools.gxemul.MipsStatus(uncached_gxemul_log)
    cached_gxemul_log      = open(os.path.join("gxemul_log", test_name + '_gxemul_cached.log'), 'rt')
    cached_gxemul_status   = tools.gxemul.MipsStatus(cached_gxemul_log)

    new_name=options.name if options.name else test_name
    attrs = ""
    if test_name.find('tlb') != -1:
        attrs=attrs + "@attr('tlb')"
    print """from cheritest_tools import BaseCHERITestCase
from nose.plugins.attrib import attr
import os
import tools.sim
expected_uncached=["""
    for reg in xrange(len(tools.gxemul.MIPS_REG_NUM2NAME)):
        print "    0x%x," % uncached_gxemul_status[reg]
    print """  ]
expected_cached=["""
    for reg in xrange(len(tools.gxemul.MIPS_REG_NUM2NAME)):
        print "    0x%x," % cached_gxemul_status[reg]
    print """  ]
class %(testname)s(BaseCHERITestCase):
  %(attrs)s
  def test_registers_expected(self):
    cached=bool(int(os.getenv('CACHED',False)))
    expected=expected_cached if cached else expected_uncached
    for reg in xrange(len(tools.sim.MIPS_REG_NUM2NAME)):
      self.assertRegisterExpected(reg, expected[reg])
""" % {'attrs':attrs, 'testname':new_name}

if __name__=="__main__":
    from optparse import OptionParser
    parser = OptionParser(usage="Usage: %prog [options] test_name")
    parser.add_option("-d", "--test-dir",help="Directory to put the exported test.", default="tests/fuzz_regressions")
    parser.add_option("-n", "--name",help="New name for the test (optional but recommended).", default="")
    (options, args) = parser.parse_args()
    if len(args) != 1:
        raise Exception("Please give exactly one test name.")
    test_name=args[0]
    export_test(test_name, options)

