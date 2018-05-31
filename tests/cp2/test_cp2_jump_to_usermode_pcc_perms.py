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
from nose.plugins.attrib import attr


#
# Test that creadhwr raises exceptions when the kernel registers are accessed
# without the appropriate permissions
#
@attr('capabilities')
class test_cp2_jump_to_usermode_pcc_perms(BaseBERITestCase):
    def test_initial_pcc(self):
        self.assertCapPermissions(self.MIPS.c13, self.max_permissions,
            "initial $pcc should have Access system registers")

    def test_after_clear(self):
        self.assertCapPermissions(self.MIPS.c14, self.max_permissions & ~1024,
            "$pcc after clear should not have Access system registers")

    def test_after_restore(self):
        self.assertCapPermissions(self.MIPS.c15, self.max_permissions,
            "$pcc after restore should have Access system registers")

    def test_in_usermoderestore(self):
        self.assertCapPermissions(self.MIPS.c16, self.max_permissions,
            "$pcc after jump to usermode should have Access system registers")

    def test_total_exception_count(self):
        self.assertRegisterEqual(self.MIPS.v0, 0, "Wrong number of exceptions triggered")

