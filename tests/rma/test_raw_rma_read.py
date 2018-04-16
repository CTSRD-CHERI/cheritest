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

class test_raw_rma_read(BaseBERITestCase):

    @attr('counterdev')
    def test_t0(self):
        self.assertRegisterEqual(self.MIPS.t0, 0x900000007f800000, "Unexpected counter address")

    @attr('counterdev')
    def test_a0_a1(self):
        self.assertRegisterNotEqual(self.MIPS.a0, self.MIPS.a1, "First and second loads from counter equal")

    @attr('counterdev')
    def test_a1_a2(self):
        self.assertRegisterNotEqual(self.MIPS.a1, self.MIPS.a2, "Second and third loads from counter equal")

    @attr('counterdev')
    def test_a0_a2(self):
        self.assertRegisterNotEqual(self.MIPS.a0, self.MIPS.a2, "First and third loads from counter equal")

    @attr('counterdev')
    def test_a0_a3(self):
        self.assertRegisterNotEqual(self.MIPS.a0, self.MIPS.a3, "Counter incorrectly reset")

    @attr('counterdev')
    def test_a1_a3(self):
        self.assertRegisterNotEqual(self.MIPS.a1, self.MIPS.a3, "Counter incorrectly reset")
