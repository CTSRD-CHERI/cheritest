#-
# Copyright (c) 2018 Alex Richardson
# Copyright (c) 2018 Michael Roe
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
# Test that the capability cursor is bytes 8-15 in memory for all implementations.
# Clang will always emit an untagged __intcap_t value in this way so all C
# code that uses globals depends on this representation.
#

@attr('capabilities')
class test_cp2_memory_cursor_location(BaseBERITestCase):

# This test uses load-linked/store conditional, and so is not expected to
# work when run in uncached memory. A LL/SC to uncached memory might halt
# the test (and will when running in the L3 model), so in the uncached case
# we can't rely on any of the registers having their expected value.

    @attr('cached')
    def test_load_intcap(self):
        self.assertIntCap(self.MIPS.c3, 42, "Should load an __intcap_t with value 42")

    @attr('cached')
    def test_offset_42(self):
        self.assertRegisterEqual(self.MIPS.a0, 42, "Should load an __intcap_t with value 42")

    @attr('cached')
    def test_store_load(self):
        self.assertIntCap(self.MIPS.c4, 0x1234, "The capability to store should be 0x1234")
        self.assertIntCap(self.MIPS.c5, 0x1234, "The value loaded back from memory should be 0x1234")

    @attr('cached')
    def test_store_load_ll_sc(self):
        self.assertRegisterEqual(self.MIPS.s1, 1, "cscc should have succeeded")
        self.assertIntCap(self.MIPS.c6, 0x1234, "The original cllc value should be the previous constant 0x1234")
        self.assertIntCap(self.MIPS.c7, 0x5678, "The value to store with cscc should be 0x5678")
        self.assertIntCap(self.MIPS.c8, 0x5678, "The value loaded back with cllc should be 0x5678")
        self.assertIntCap(self.MIPS.c9, 0x5678, "The value loaded back with clc should also be 0x5678")

    @attr('cached')
    @attr('cap64')
    def test_initial_raw_bytes_64(self):
        self.__check_in_memory_rep(42, "initially", 8, self.MIPS.a1, self.MIPS.a2, self.MIPS.a3, self.MIPS.a4)

    @attr('cached')
    @attr('cap128')
    def test_initial_raw_bytes_128(self):
        self.__check_in_memory_rep(42, "initially", 16, self.MIPS.a1, self.MIPS.a2, self.MIPS.a3, self.MIPS.a4)

    @attr('cached')
    @attr('cap256')
    def test_initial_raw_bytes_256(self):
        self.__check_in_memory_rep(42, "initially", 32, self.MIPS.a1, self.MIPS.a2, self.MIPS.a3, self.MIPS.a4)

    @attr('cached')
    @attr('cap64')
    def test_raw_bytes_after_csc_64(self):
        self.__check_in_memory_rep(0x1234, "after csc", 8, self.MIPS.t0, self.MIPS.t1, self.MIPS.t2, self.MIPS.t3)

    @attr('cached')
    @attr('cap128')
    def test_raw_bytes_after_csc_128(self):
        self.__check_in_memory_rep(0x1234, "after csc", 16, self.MIPS.t0, self.MIPS.t1, self.MIPS.t2, self.MIPS.t3)

    @attr('cached')
    @attr('cap256')
    def test_raw_bytes_after_csc_256(self):
        self.__check_in_memory_rep(0x1234, "after csc", 32, self.MIPS.t0, self.MIPS.t1, self.MIPS.t2, self.MIPS.t3)

    @attr('cached')
    @attr('cap64')
    def test_final_raw_bytes_64(self):
        self.__check_in_memory_rep(0x5678, "after cscc", 8, self.MIPS.s4, self.MIPS.s5, self.MIPS.s6, self.MIPS.s7)

    @attr('cached')
    @attr('cap128')
    def test_final_raw_bytes_128(self):
        self.__check_in_memory_rep(0x5678, "after cscc", 16, self.MIPS.s4, self.MIPS.s5, self.MIPS.s6, self.MIPS.s7)

    @attr('cached')
    @attr('cap256')
    def test_final_raw_bytes_256(self):
        self.__check_in_memory_rep(0x5678, "after cscc", 32, self.MIPS.s4, self.MIPS.s5, self.MIPS.s6, self.MIPS.s7)

    def __check_in_memory_rep(self, cursor, msg_prefix, cheribytes, r1, r2, r3, r4):
        self.assertRegisterEqual(self.MIPS.s0, cheribytes, "bounds of load should be " + str(cheribytes))
        if cheribytes == 8:
            self.assertRegisterEqual(r1, cursor, msg_prefix + "bytes 0-8 should contain cursor")
        if (cheribytes == 16) or (cheribytes == 32):
            self.assertRegisterEqual(r1, 0, msg_prefix + " bytes 0-7 should be zero")
            self.assertRegisterEqual(r2, cursor, msg_prefix + "bytes 8-15 should contain cursor")
        if cheribytes == 32:
            self.assertRegisterEqual(r3, 0, msg_prefix + "bytes 16-23 should be zero")
            self.assertRegisterEqual(r4, 0, msg_prefix + "bytes 24-31 should be zero")
        if (cheribytes != 8) and (cheribytes != 16) and (cheribytes != 32):
            self.fail("Capabilities have a representation not supported by this test")
