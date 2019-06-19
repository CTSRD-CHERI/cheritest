#-
# Copyright (c) 2019 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory (Department of Computer Science and
# Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
# DARPA SSITH research programme.
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


@attr('capabilities')
class test_cp2_qemu_representable_regression(BaseBERITestCase):
    def test_value_tagged(self):
        assert self.MIPS.a1 == 1, "cgettag should return 1"

    def test_input_cap(self):
        assert self.MIPS.c1.t, "should be tagged"
        assert self.MIPS.c1.offset == HexInt(0), "offset wrong"
        assert self.MIPS.c1.base == HexInt(0xb7fcc), "base wrong"
        assert self.MIPS.c1.length == HexInt(0xe1), "base wrong"

    def test_result_cap(self):
        assert self.MIPS.c2.t, "should be tagged"
        assert self.MIPS.c2.offset == HexInt(0x34), "offset wrong"
        assert self.MIPS.c2.base == HexInt(0xb7fcc), "base wrong"
        assert self.MIPS.c2.length == HexInt(0xe1), "base wrong"




