#-
# Copyright (c) 2011 William M. Morland
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

class test_raw_lwl(BaseBERITestCase):
    def test_offset_zero(self):
        self.assertRegisterEqual(self.MIPS.a1, 0xfffffffffedcba98, "LWL with zero offset failed")

    def test_offset_one(self):
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffdcba98b0, "LWL with one offset failed")

    def test_offset_two(self):
        self.assertRegisterEqual(self.MIPS.a3, 0xffffffffba98b1b0, "LWL with two offset failed")

    def test_offset_three(self):
        self.assertRegisterEqual(self.MIPS.a4, 0xffffffff98b2b1b0, "LWL with three offset failed")

    def test_offset_four(self):
        self.assertRegisterEqual(self.MIPS.a5, 0x0000000076543210, "LWL with four offset (skip word) failed")
