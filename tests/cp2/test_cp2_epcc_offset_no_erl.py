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

from beritest_tools import BaseBERITestCase, attr


@attr('capabilities')
class test_cp2_epcc_offset_no_erl(BaseBERITestCase):
    def test_epc(self):
        assert self.MIPS.s0 == 0xE9C, "Wrong EPC from dmfc0"

    def test_error_epc(self):
        assert self.MIPS.s1 == 0xE8808E9C, "Wrong ErrorEPC from dmfc0"

    def test_cgetepcc(self):
        self.assertDefaultCap(self.MIPS.c1, offset=0xE9C, msg="cgetepcc offset should be EPC if ERL is not set")

    def test_finalepcc(self):
        self.assertDefaultCap(self.MIPS.epcc, offset=0xE9C, msg="dumped EPCC offset should be EPC if ERL is not set")
