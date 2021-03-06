#
# Copyright (c) 2013 Michael Roe
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
from beritest_tools import attr, xfail_on

#
# Test that the RDHWR instruction can be used to read the cycle counter.
# RDHWR is a MIPS32r2 instruction, so this test is not expected to pass on
# earlier MIPS revisions.
#

class test_cp0_counter(BaseBERITestCase):

    @attr('rdhwr')
    @attr('count_register_is_icount')
    def test_cp0_counter_1(self):
        '''Test that the count register gives almost the same value when it is read two different ways'''
        assert self.MIPS.a1 > 0, "Expected a non-zero value"
        self.assertRegisterInRange(self.MIPS.a2, self.MIPS.a1, self.MIPS.a1 + 100,
            "rdhwr and mfc0 did not give nearly the same value for the count register")

    @attr('rdhwr')
    @attr('count_register_is_time')
    def test_cp0_counter_qemu_1(self):
        # QEMU uses host time for the count register, so it can increment a lot
        # between instructions (especially when using QEMU instrumented with
        # ASAN on a server under a lot of load). Therefore, we simply check that
        # the value is greater than the previous one.
        # Note: In some cases it can also be equal depending on how QEMU queries
        # the host clock. This happens more frequently now that QEMU runs faster.
        assert self.MIPS.a1 > 0, "Expected a non-zero value"
        assert self.MIPS.a2 >= self.MIPS.a1, "rdhwr and mfc0 did not give nearly the same value for the count register"
