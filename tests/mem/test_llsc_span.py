#-
# Copyright (c) 2011 Robert N. M. Watson
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


# Note: MIPS64 QEMU cannot detect a store of the loaded value before the sc
# since LL/SC is implemented using CAS. It works for CHERI since we can use the
# tag invalidate event to clear the linked flag
class test_llsc_span(BaseBERITestCase):

    @attr('llsc')
    @attr('cached')
    @attr('llscspan')
    def test_ll_ld_sc_success(self):
        '''That ll+ld+sc succeeds'''
        self.assertRegisterEqual(self.MIPS.a2, 1, "ll+ld+sc failed")

    @attr('llsc')
    @attr('cached')
    @attr('llscspan')
    @attr('llscspan_same_value')
    def test_ll_sw_sc_failure(self):
        '''That an ll+sw+sc spanning a store to the line fails'''
        self.assertRegisterEqual(self.MIPS.t0, 0, "ll+sw+sc succeeded")

    @attr('llsc')
    @attr('cached')
    @attr('llscspan')
    @attr('llscspan_same_value')
    def test_ll_sw_sc_value(self):
        '''That an ll+sc spanning a store to the line does not store'''
        self.assertRegisterNotEqual(self.MIPS.a6, 1, "ll+sw+sc stored value")
