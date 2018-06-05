#-
# Copyright (c) 2011 Steven J. Murdoch
# Copyright (c) 2017 Jonathan Woodruff
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

class test_raw_scd_uncached(BaseBERITestCase):

    @attr('llsc')
    @attr('llscuncached')
    def test_store_condiational_uncached(self):
        '''Store conditional of word to uncached address should succeed'''
        self.assertRegisterEqual(self.MIPS.s4, 1, "Store conditional of word to uncached address failed")

    @attr('llsc')
    @attr('llscuncached')
    def test_store_condiational_uncached(self):
        '''Load after store conditional to uncached address didn't match stored value'''
        self.assertRegisterEqual(self.MIPS.s5, 0xfedcba9876543210, "Store conditional with to uncached address didn't write to memory")
