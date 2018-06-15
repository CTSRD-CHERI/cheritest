#-
# Copyright (c) 2018 Alex Richardson
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
from beritest_tools import attr


@attr('capabilities')
class test_cp2_x_qemu_length_broken(BaseBERITestCase):
    def test_num_traps(self):
        self.assertRegisterEqual(self.MIPS.v0, 8, "Expected 8 traps")

    def test_first_cap_0(self):
        self.assertCompressedTrapInfo(self.MIPS.c5,
            mips_cause=self.MIPS.Cause.TLB_Load,
            trap_count=1, msg="accessing address 0 should generate a TLB fault")

    def test_first_cap_minus_1(self):
        self.assertCompressedTrapInfo(self.MIPS.c6,
            mips_cause=self.MIPS.Cause.TLB_Load,
            trap_count=2, msg="accessing -1 should generate a TLB fault")

    def test_first_cap_minus_2(self):
        self.assertCompressedTrapInfo(self.MIPS.c7,
            mips_cause=self.MIPS.Cause.TLB_Load,
            trap_count=3, msg="accessing -2 should generate a TLB fault")

    def test_first_cap_minus_3(self):
        self.assertCompressedTrapInfo(self.MIPS.c8,
            mips_cause=self.MIPS.Cause.TLB_Load,
            trap_count=4, msg="accessing -3 should generate a TLB fault")

    def test_first_cap_minus_4(self):
        self.assertCompressedTrapInfo(self.MIPS.c9,
            mips_cause=self.MIPS.Cause.TLB_Load,
            trap_count=5, msg="accessing -4 should generate a TLB fault")


    def test_second_cap_minus_7(self):
        self.assertCompressedTrapInfo(self.MIPS.c10,
            mips_cause=self.MIPS.Cause.TLB_Load,
            trap_count=6, msg="accessing address 0 should generate a TLB fault")

    def test_second_cap_minus_8(self):
        self.assertCompressedTrapInfo(self.MIPS.c11,
            mips_cause=self.MIPS.Cause.TLB_Load,
            trap_count=7, msg="accessing address 0 should generate a TLB fault")

    def test_second_cap_0(self):
        self.assertCompressedTrapInfo(self.MIPS.c12,
            mips_cause=self.MIPS.Cause.TLB_Load,
            trap_count=8, msg="accessing address 0 should generate a TLB fault")
