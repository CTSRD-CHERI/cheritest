#-
# Copyright (c) 2017 Alfredo Mazzinghi
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

from beritest_tools import BaseBERITestCase, xfail_gnu_binutils
from nose.plugins.attrib import attr

@xfail_gnu_binutils
class test_cp2_rep_underflow(BaseBERITestCase):

    @attr('capabilities')
    def test_cp2_rep_underflow_pos(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "CIncOffset did not increment correctly with immediate")

    @attr('capabilities')
    def test_cp2_rep_underflow_neg(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "CIncOffset did not decrement correctly with immediate")
