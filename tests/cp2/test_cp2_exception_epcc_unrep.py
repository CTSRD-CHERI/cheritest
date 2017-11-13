#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2017 Robert M. Norton
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
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

from beritest_tools import BaseBERITestCase
from nose.plugins.attrib import attr

#
# Test to ensure that EPCC is set correctly when a branch occurs to an
# offset (PC) far outside the bounds of PCC such that EPCC would not
# be representable when capability compression is used.
#

class test_cp2_exception_epcc_unrep(BaseBERITestCase):

    #
    # Check that various stages of the test did actually run.
    #
    @attr('capabilities')
    def test_exception_counter(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "CP2 exception counter not 1")

    @attr('capabilities')
    def test_insandbox(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "sandbox not recorded")

    #
    # Check that sandbox was configured roughly as expected
    #
    @attr('capabilities')
    def test_sandbox_length(self):
        self.assertRegisterEqual(self.MIPS.s0, 20, "sandbox length not 20")

    #
    # Check that exception code was CP2 fault
    #
    @attr('capabilities')
    def test_excode(self):
        self.assertRegisterMaskEqual(self.MIPS.s1, 0x1f << 2, 18 << 2, "last exception not a CP2 fault")

    #
    # Check that capcause shows length violation on PCC
    #
    @attr('capabilities')
    @attr('cap_precise')
    def test_capcause_precise(self):
        self.assertRegisterEqual(self.MIPS.s2, 0x1ff, "incorrect capcause")

    #
    # Check that capcause shows tag violation on PCC
    #
    @attr('capabilities')
    @attr('cap_imprecise')
    def test_capcause_imprecise(self):
        self.assertRegisterEqual(self.MIPS.s2, 0x2ff, "incorrect capcause")

    #
    # Check that EPC is as expected
    #
    @attr('capabilities')
    def test_epc(self):
        self.assertRegisterEqual(self.MIPS.s3, 0x10000000, "sandbox EPC unexpected")
    #
    # Check that sandbox cap is as expected
    #
    @attr('capabilities')
    def test_sandbox_pcc_tag(self):
        self.assertRegisterEqual(self.MIPS.cp2[2].t, 1, "sandbox tag incorrect")

    @attr('capabilities')
    def test_sandbox_pcc_unsealed(self):
        self.assertRegisterEqual(self.MIPS.cp2[2].s, 0, "sandbox sealed incorrect")

    @attr('capabilities')
    def test_sandbox_pcc_perms(self):
        self.assertRegisterEqual(self.MIPS.cp2[2].perms, 7,  "sandbox perms incorrect")

    @attr('capabilities')
    def test_sandbox_pcc_ctype(self):
        self.assertRegisterEqual(self.MIPS.cp2[2].ctype, 0x0, "sandbox ctype incorrect")
        
    @attr('capabilities')
    def test_sandbox_pcc_offset(self):
        self.assertRegisterEqual(self.MIPS.cp2[2].offset, 0x4, "sandbox offset incorrect")

    @attr('capabilities')
    def test_sandbox_pcc_base(self):
        self.assertRegisterEqual(self.MIPS.cp2[2].base, self.MIPS.a7, "sandbox base incorrect")

    @attr('capabilities')
    def test_sandbox_pcc_length(self):
        self.assertRegisterEqual(self.MIPS.cp2[2].length, self.MIPS.s0, "sandbox length incorrect")

    #
    # Check that the post-sandbox EPCC is as expected: sandboxed.
    #
    @attr('capabilities')
    @attr('cap_precise')
    def test_sandbox_epcc_tag_precise(self):
        self.assertRegisterEqual(self.MIPS.cp2[3].t, 1, "sandbox EPCC tag incorrect")

    @attr('capabilities')
    @attr('cap_imprecise')
    def test_sandbox_epcc_tag_imprecise(self):
        self.assertRegisterEqual(self.MIPS.cp2[3].t, 0, "sandbox EPCC tag incorrect")

    @attr('capabilities')
    def test_sandbox_epcc_unsealed(self):
        self.assertRegisterEqual(self.MIPS.cp2[3].s, 0, "sandbox EPCC unsealed incorrect")

    @attr('capabilities')
    def test_sandbox_epcc_perms_precise(self):
        self.assertRegisterEqual(self.MIPS.cp2[3].perms, 0x0007, "sandbox EPCC perms incorrect")

    @attr('capabilities')
    def test_sandbox_epcc_ctype(self):
        self.assertRegisterEqual(self.MIPS.cp2[3].ctype, 0, "sandbox EPCC ctype incorrect")
        
    @attr('capabilities')
    def test_sandbox_epcc_offset(self):
        self.assertRegisterEqual(self.MIPS.cp2[3].base + self.MIPS.cp2[3].offset, self.MIPS.a7 + 0x10000000, "sandbox EPCC offset incorrect")

    @attr('capabilities')
    @attr('cap_precise')
    def test_sandbox_epcc_base_precise(self):
        self.assertRegisterEqual(self.MIPS.cp2[3].base, self.MIPS.a7, "sandbox EPCC base incorrect")

    @attr('capabilities')
    @attr('cap_precise')
    def test_sandbox_epcc_length_precise(self):
        self.assertRegisterEqual(self.MIPS.cp2[3].length, self.MIPS.s0, "sandbox EPCC length incorrect")

    @attr('capabilities')
    @attr('cap_imprecise')
    def test_sandbox_epcc_base_imprecise(self):
        self.assertRegisterEqual(self.MIPS.cp2[3].base, 0, "sandbox EPCC base incorrect")

    @attr('capabilities')
    @attr('cap_imprecise')
    def test_sandbox_epcc_length_imprecise(self):
        self.assertRegisterEqual(self.MIPS.cp2[3].length, 0, "sandbox EPCC length incorrect")
