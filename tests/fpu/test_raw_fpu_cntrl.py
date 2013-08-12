#-
# Copyright (c) 2013-2013 Ben Thorner, Colin Rothwell
# All rights reserved.
#
# This software was developed by Ben Thorner as part of his summer internship
# and Colin Rothwell as part of his final year undergraduate project.
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

class test_raw_fpu_cntrl(BaseCHERITestCase):
    def test_movc(self):
        '''Test to ensure we can move 32 bits between COP1 and GPR registers'''
        self.assertRegisterEqual(self.MIPS.s0, 9, "MOVC failed")
        
    def test_dmovc(self):
        '''Test to ensure we can move 64 bits between COP1 and GPR registers'''
        self.assertRegisterEqual(self.MIPS.s1, (18 << 32) + 7, "DMOVC failed")
        
    @attr('floatfcsr')
    def test_cmovc_fcsr(self):
        '''Test to ensure FCSR is correctly read and written'''
        self.assertRegisterEqual(self.MIPS.s2, 0x3F, "ctc1/cfc1 failed for $f25")
        self.assertRegisterEqual(self.MIPS.a0, 0x0, "cfc1 failed to interpret $f31 for $f25")

    @attr('floatfexr')
    def test_cmovc_fexr(self):
        '''Test to ensure FEXR is correctly read and written'''
        self.assertRegisterEqual(self.MIPS.s3, 0xF070, "ctc1/cfc1 failed for $f26")
        self.assertRegisterEqual(self.MIPS.s7, 0x0003F07C, "cfc1 failed to interpret $f31 for $f26")

    @attr('floatfenr')
    def test_cmovc_fenr(self):
        '''Test to ensure FENR is correctly read and written'''
        self.assertRegisterEqual(self.MIPS.s4, 0xF86, "ctc1/cfc1 failed for $f28")
        self.assertRegisterEqual(self.MIPS.s6, 0x00000F83, "cfc1 failed to interpret $f31 for $f28")

    def test_cmovc_f31(self):
        '''Test to ensure $f31 is correctly read and written'''
        self.assertRegisterEqual(self.MIPS.s5, 0x0003FFFF, "ctc1/cfc1 failed for $f31")
        
    @attr('floatpaired')
    def test_fir(self):
        '''Test that we get the correct value out of the FIR'''
        self.assertRegisterEqual(self.MIPS.t9, 0x470000, "Incorrect value from FIR")
        # I've left Impl, ProcessorID and Revision to be 0.
        
    def test_cmov_single(self):
        '''Test to ensure we can move values between FPRs'''
        self.assertRegisterEqual(self.MIPS.t8, 0x41000000, "CMOV failed for single precision")

    @attr('float64')
    def test_cmov_double(self):
        self.assertRegisterEqual(self.MIPS.t3, 0x4000000000000000, "CMOV failed for double precision")


    @attr('floatpaired')
    def test_cmov_paired(self):
        self.assertRegisterEqual(self.MIPS.t2, 0x4000000041000000, "CMOV failed for paired single precision")

    def test_register_name_collisions(self):
        '''Test that a register name referring to a control register doesn't
        prevent the use of data registers with that name.'''
        self.assertRegisterEqual(self.MIPS.t0, 0xFFFFFFFFDEADBEEF, "Can't use f0")
        self.assertRegisterEqual(self.MIPS.t1, 0xFEED000000000000, "Can't use f25")
        self.assertRegisterEqual(self.MIPS.a1, 0xFFFFABCD00000000, "Can't use f26")
        self.assertRegisterEqual(self.MIPS.a2, 0xFFFFFFFFDEAF0000, "Can't use f28")
        self.assertRegisterEqual(self.MIPS.a3, 0x0000000000004321, "Can't use f31")
