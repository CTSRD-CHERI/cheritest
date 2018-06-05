#-
# Copyright (c) 2018 Michael Roe
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
from beritest_tools import attr

class test_div_zero_ex(BaseBERITestCase):

    @attr('divide_by_zero')
    def test_div_zero_ex_remainder(self):
        '''Test the remainder after division by zero'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "Division by zero did not give a remainder of zero (unpredictable value in the MIPS ISA)")

    @attr('divide_by_zero')
    def test_div_zero_ex_quotient(self):
        '''Test the quotient after division by zero'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "Division by zero did not give a quotient of zero (unpredictable value in the MIPS ISA)")


