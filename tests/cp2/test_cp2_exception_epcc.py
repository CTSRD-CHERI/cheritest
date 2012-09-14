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
# Rather complex test to check that EPCC/PCC swapping in exceptions is being
# properly implemented by CP2.  The test runs initially with a privileged PCC,
# then traps, a limited PCC is installed, traps again, and the original PCC is
# restored.  Various bits of evidence are collected along the way, all of
# which we try to check here.
#

class test_cp2_exception_epcc(BaseCHERITestCase):

    #
    # Check that various stages of the test did actually run.
    #
    @attr('capabilities')
    def test_exception_counter(self):
        self.assertRegisterEqual(self.MIPS.a0, 2, "CP2 exception counter not 2")

    @attr('capabilities')
    def test_presandbox(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "pre-sandbox not recorded")

    @attr('capabilities')
    def test_insandbox(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "sandbox not recorded")

    @attr('capabilities')
    def test_postsandbox(self):
        self.assertRegisterEqual(self.MIPS.a4, 1, "post-sandbox not recorded")

    #
    # Check that sandbox was configured roughly as expected
    #
    @attr('capabilities')
    def test_sandbox_length(self):
        self.assertRegisterEqual(self.MIPS.s0, 24, "sandbox length not 24")

    #
    # Check that we only entered the last exception because of an explicit
    # software trap.
    #
    @attr('capabilities')
    def test_trap_excode(self):
        self.assertRegisterEqual((self.MIPS.s1 >> 2) & 0x1f, 13, "last exception not a trap")

    #
    # Check that the exception handler is returning PCC-relative PCs rather
    # than absolute virtual PCs.
    #
    @attr('capabilities')
    def test_trap_epc(self):
        self.assertRegisterEqual(self.MIPS.s2, 0x14, "incorrect EPC for last trap")

    #
    # Check that in-sandbox $pc is roughly as expected
    #
    @attr('capabilities')
    def test_sandbox_pc(self):
        self.assertRegisterEqual(self.MIPS.a3, 0x10, "sandbox PC unexpected")

    #
    # Check that post-sandbox, $pc is roughly as expected
    #
    @attr('capabilities')
    def test_postsandbox_pc(self):
        self.assertRegisterEqual(self.MIPS.a5, self.MIPS.a6, "post-sandbox PC unexpected")

    #
    # Check that the pre-sandbox EPCC is as expected: default on reset.
    #
    @attr('capabilities')
    def test_presandbox_epcc_unsealed(self):
        self.assertRegisterEqual(self.MIPS.c2.u, 1, "pre-sandbox EPCC unsealed incorrect")

    @attr('capabilities')
    def test_presandbox_epcc_perms(self):
        self.assertRegisterEqual(self.MIPS.c2.perms, 0x7fff, "pre-sandbox EPCC perms incorrect")

    @attr('capabilities')
    def test_presandbox_epcc_ctype(self):
        self.assertRegisterEqual(self.MIPS.c2.ctype, 0x0, "pre-sandbox EPCC ctype incorrect")

    @attr('capabilities')
    def test_presandbox_epcc_base(self):
        self.assertRegisterEqual(self.MIPS.c2.base, 0x0, "pre-sandbox EPCC base incorrect")

    @attr('capabilities')
    def test_presandbox_epcc_length(self):
        self.assertRegisterEqual(self.MIPS.c2.length, 0xffffffffffffffff, "pre-sandbox EPCC length incorrect")

    #
    # Check that the post-sandbox EPCC is as expected: sandboxed.
    #
    @attr('capabilities')
    def test_sandbox_epcc_unsealed(self):
        self.assertRegisterEqual(self.MIPS.c3.u, 1, "sandbox EPCC unsealed incorrect")

    @attr('capabilities')
    def test_sandbox_epcc_perms(self):
        self.assertRegisterEqual(self.MIPS.c3.perms, 0x0007, "sandbox EPCC perms incorrect")

    @attr('capabilities')
    def test_sandbox_epcc_ctype(self):
        self.assertRegisterEqual(self.MIPS.c3.ctype, 0x0, "sandbox EPCC ctype incorrect")

    @attr('capabilities')
    def test_sandbox_epcc_base(self):
        self.assertRegisterEqual(self.MIPS.c3.base, self.MIPS.a7, "sandbox EPCC base incorrect")

    @attr('capabilities')
    def test_sandbox_epcc_length(self):
        self.assertRegisterEqual(self.MIPS.c3.length, self.MIPS.s0, "sandbox EPCC length incorrect")
