#-
# Copyright (c) 2012 Michael Roe
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

#
# Test capability jump register
#
class test_cp2_cjr_overwrite_target_in_delay_slot(BaseBERITestCase):
    @attr('capabilities')
    def test_no_exceptions(self):
        assert self.MIPS.v0 == 0, "Wrong number of exceptions"

    def test_initial_pcc_perms(self):
        assert self.MIPS.c1.perms & self.permission_bits.LoadCap.value, "Initial $pcc should allow load_cap"

    def test_change_offset(self):
        assert self.MIPS.a1 == 0x1, "Wrong jump (change $c12 offset)"

    def test_change_base(self):
        assert self.MIPS.a2 == 0x1, "Wrong jump (change $c12 base)"

    def test_change_null(self):
        assert self.MIPS.a3 == 0x1, "Wrong jump (change $c12 to NULL)"

    def test_change_perms(self):
        assert self.MIPS.a4 == 0x1, "Wrong branch taken when changing perms in delay slot"
        assert (self.MIPS.c6.perms & self.permission_bits.LoadCap.value) == 0, "change $c12 perms in delay slot should not change resulting $pcc perms"
