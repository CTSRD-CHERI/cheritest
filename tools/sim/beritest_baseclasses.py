#-
# Copyright (c) 2018 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
# ("CTSRD"), as part of the DARPA CRASH research programme.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-11-C-0249
# ("MRC2"), as part of the DARPA MRC research programme.
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

from tools.sim.beritest_tools import BaseBERITestCase, attr

# Various subclasses of BaseBERITestCase that can be used for very similar tests
# such as the branch-out-of bounds or unaligned load/store tests

# Wrap the test base classes inside another class to avoid running them
# See https://stackoverflow.com/a/25695512/894271
class BERITestBaseClasses:
    class UnalignedLoadStoreTestCase(BaseBERITestCase):
        is_load_or_store = None
        expected_load_value = None

        def _do_setup(self):
            self.assertIsNotNone(self.is_load_or_store, "Must define class variable is_load_or_store")
            self.assertIn(self.is_load_or_store, ("load", "store"),
                          "Class variable is_load_or_store must be 'load' or 'store'")
            if self.is_load_or_store == "load":
                self.assertIsNotNone(self.expected_load_value, "Must define class variable expected_load_value")
            super(BERITestBaseClasses.UnalignedLoadStoreTestCase, self)._do_setup()

        def test_returned(self):
            self.assertRegisterEqual(self.MIPS.a1, 1, "flow broken by " + self.is_load_or_store + " instruction")

        @attr('trap_unaligned_ld_st')
        def test_epc(self):
            self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a5, "Unexpected EPC")

        @attr('trap_unaligned_ld_st')
        def test_handled(self):
            self.assertRegisterEqual(self.MIPS.a2, 1, "sd exception handler not run")

        @attr('trap_unaligned_ld_st')
        def test_exl_in_handler(self):
            self.assertRegisterEqual((self.MIPS.a3 >> 1) & 0x1, 1, "EXL not set in exception handler")

        @attr('trap_unaligned_ld_st')
        def test_cause_bd(self):
            self.assertRegisterEqual((self.MIPS.a4 >> 31) & 0x1, 0, "Branch delay (BD) flag improperly set")

        @attr('trap_unaligned_ld_st')
        def test_cause_code(self):
            if self.is_load_or_store == "load":
                kind = "AdEL"
                code = 4
            elif self.is_load_or_store == "store":
                kind = "AdES"
                code = 5
            else:
                self.fail("not initialized correctly")
            self.assertRegisterEqual((self.MIPS.a4 >> 2) & 0x1f, code, "Code not set to " + kind)

        @attr('trap_unaligned_ld_st')
        def test_not_exl_after_handler(self):
            self.assertRegisterEqual((self.MIPS.a6 >> 1) & 0x1, 0, "EXL still set after ERET")

        @attr('trap_unaligned_ld_st')
        def test_badvaddr(self):
            self.assertRegisterEqual(self.MIPS.a7, self.MIPS.s0, "BadVAddr equal to Unaligned Address")

        @attr('allow_unaligned')
        def test_unaligned_loads_ok(self):
            if self.is_load_or_store == "load":
                self.assertRegisterEqual(self.MIPS.a7, self.expected_load_value, "Loaded value is wrong!")
            else:
                self.assertRegisterEqual(self.MIPS.a7, 42, "BadVAddr should not have been set")
            # Check that a2 - a6 haven't changed
            self.assertRegisterEqual(self.MIPS.a2, 0, "exception should not have been triggered")
            self.assertRegisterEqual(self.MIPS.a3, 0, "exception should not have been triggered")
            self.assertRegisterEqual(self.MIPS.a4, 0, "exception should not have been triggered")
            self.assertRegisterEqual(self.MIPS.a5, 0, "exception should not have been triggered")
            # TODO: should we really be testing this?
            self.assertRegisterEqual(self.MIPS.a6, 0x640080e1, "Wrong status value")

