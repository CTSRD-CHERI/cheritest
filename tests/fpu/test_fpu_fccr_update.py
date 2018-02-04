#-
# Copyright (c) 2017 Michael Roe
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer
# Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
# project, funded by EPSRC grant EP/K008528/1.
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

class test_fpu_fccr_update(BaseBERITestCase):

    @attr('floatcc')
    def test_fpu_fccr_update_1(self):
        '''Test C.EQ.S $fcc0, $f0, $f0 sets $fcc0'''
        self.assertRegisterMaskEqual(self.MIPS.a0, 0xfe800000, 1 << 23, "Floating point compare did not set $fcc0")

    @attr('floatcc')
    def test_fpu_fccr_update_2(self):
        '''Test C.EQ.S $fcc1, $f0, $f0 sets $fcc1 and leaves $fcc0 unchanged'''
        self.assertRegisterMaskEqual(self.MIPS.a1, 0xfe800000, 0x02800000, "Floating point compare did not set $fcc1 and leave $fcc0 set")

    @attr('floatcc')
    def test_fpu_fccr_update_3(self):
        '''Test C.EQ.S $fcc2, $f0, $f0 sets $fcc2 and leaves $fcc0 and $fcc1 unchanged'''
        self.assertRegisterMaskEqual(self.MIPS.a2, 0xfe800000, 0x06800000, "Floating point compare did not set $fcc2 and leave $fcc0 and $fcc1 set")
