#-
# Copyright (c) 2012 Michael Roe
# Copyright (c) 2019 Alex Richardson
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
from beritest_tools import BaseBERITestCase, attr, HexInt


#
# Test that csc raises an exception is the address at which the capability
# is to be stored is not aligned on a 32-byte boundary.
#
@attr('capabilities')
class test_cp2_x_csc_align(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 1

    def test_cp2_x_csc_align_pre(self):
        assert self.MIPS.a0 == HexInt(0x12345678), "initial value incorrect"

    def test_cp2_x_csc_align_post(self):
        assert self.MIPS.a1 == HexInt(0x12345678), "CSC wrote to an unaligned address"

    def test_cp2_x_csc_align_trap_info(self):
        self.assertCompressedTrapInfo(self.MIPS.s1, mips_cause=self.MIPS.Cause.AdES, trap_count=1)
