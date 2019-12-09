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
@attr('sentry_caps')
class test_cp2_sentry_eret(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 0

    def test_getepcc_is_sentry(self):
        assert self.MIPS.c12.ctype == self.sentry_otype

    def test_getepcc_is_same(self):
        assert self.MIPS.c1 == self.MIPS.c12

    def test_eret_pcc_unsealed(self):
        assert self.MIPS.c2.ctype == self.unsealed_otype

    def test_getpcc_same_except_otype(self):
        assert self.MIPS.c2 == self.MIPS.c11, "getpcc should be the same as the unsealed target cap $c11"

    def test_trap_handler_not_called(self):
        self.assertNullCap(self.MIPS.c3, msg="Trap handler should not be called")


