#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2011 Robert M. Norton
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
# Rather complex test to check that EPCC/PCC swapping in exceptions is being
# properly implemented by CP2.  The test runs initially with a privileged PCC,
# then traps, a limited PCC is installed, traps again, and the original PCC is
# restored.  Various bits of evidence are collected along the way, all of
# which we try to check here.
#


class test_cp2_exception_pipeline(BaseCHERITestCase):
    @attr('capabilities')
    def test_cincbase(self):
        # Should be unchanged from default
        self.assertRegisterEqual(self.MIPS.c2.base, 0x0, "cincbase instruction was not properly flushed from pipeline")
    @attr('capabilities')
    def test_csetlen(self):
        # Should be unchanged from default
        self.assertRegisterEqual(self.MIPS.c3.length, 0xffffffffffffffff, "csetlen instruction was not properly flushed from pipeline")
    @attr('capabilities')
    def test_candperms(self):
        # Should be unchanged from default
        self.assertRegisterEqual(self.MIPS.c4.perms, 0x7fffffff, "candperms instruction was not properly flushed from pipeline")
    @attr('capabilities')
    def test_csettype(self):
        # Should be unchanged from default
        self.assertRegisterEqual(self.MIPS.c5.ctype, 0x0, "csettype instruction was not properly flushed from pipeline")
    @attr('capabilities')
    def test_cscr(self):
        # These registers should contain test data, NOT the stored capability register
        self.assertRegisterEqual(self.MIPS.a0, 0xfeedbeefdeadbeef, "cscr instruction was not properly flushed from pipeline")
        self.assertRegisterEqual(self.MIPS.a1, 0xfeedbeefdeadbeef, "cscr instruction was not properly flushed from pipeline")
        self.assertRegisterEqual(self.MIPS.a2, 0xfeedbeefdeadbeef, "cscr instruction was not properly flushed from pipeline")
        self.assertRegisterEqual(self.MIPS.a3, 0xfeedbeefdeadbeef, "cscr instruction was not properly flushed from pipeline")
    @attr('capabilities')
    def test_clcr(self):
        # The c7 register should be unchanged from its default value
        self.assertRegisterEqual(self.MIPS.c7.ctype, 0, "clcr instruction was not properly flushed from pipeline")
        self.assertRegisterEqual(self.MIPS.c7.perms, 0x7fffffff, "clcr instruction was not properly flushed from pipeline")
        self.assertRegisterEqual(self.MIPS.c7.base, 0, "clcr instruction was not properly flushed from pipeline")
        self.assertRegisterEqual(self.MIPS.c7.length, 0xffffffffffffffff, "clcr instruction was not properly flushed from pipeline")
