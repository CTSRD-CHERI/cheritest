#
# Copyright (c) 2019 Alex Richardson
# Copyright (c) 2019 Robert M. Norton
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

@attr('capabilities')
@attr('sentry_caps')
class test_cp2_sentry_cunseal(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 3

    def test_sentry_no_unseal1(self):
        self.assertCp2Fault(self.MIPS.a1, cap_cause=self.MIPS.CapCause.Type_Violation,
            cap_reg=1, trap_count=1, msg="Should not be able to unseal sentry cap using cunseal")

    def test_sentry_no_unseal2(self):
        self.assertCp2Fault(self.MIPS.a2, cap_cause=self.MIPS.CapCause.Type_Violation,
            cap_reg=1, trap_count=2, msg="Should not be able to unseal sentry cap using cunseal")

    def test_sentry_no_unseal3(self):
        self.assertCp2Fault(self.MIPS.a3, cap_cause=self.MIPS.CapCause.Type_Violation,
            cap_reg=1, trap_count=3, msg="Should not be able to unseal sentry cap using cunseal")
