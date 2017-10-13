#-
# Copyright (c) 2011 Robert N. M. Watson
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
# Test that capability field query instructions feed properly into sequential
# ALU instructions.
#

class test_cp2_get_alu_pipeline(BaseBERITestCase):
    @attr('capabilities')
    def test_cp2_cgetbase_alu(self):
        '''Test that cgetbase results visible to ALU'''
        self.assertRegisterEqual(self.MIPS.t0, 0x0, "cgetbase returns incorrect value")

    @attr('capabilities')
    def test_cp2_cgetlen_alu(self):
        '''Test that cgetlen results visible to ALU'''
        self.assertRegisterEqual(self.MIPS.t1, 0xffffffffffffffff, "cgetlen returns incorrect value")

    @attr('capabilities')
    def test_cp2_cgetperm_alu(self):
        '''Test that cgetperm results visible to ALU'''
        self.assertRegisterAllPermissions(self.MIPS.t2, "cgetperm returns incorrect value")

    @attr('capabilities')
    def test_cp2_cgettype_alu(self):
        '''Test that cgettype results visible to ALU'''
        self.assertRegisterEqual(self.MIPS.t3, 0xffffffffffffffff, "cgettype returns incorrect value")
