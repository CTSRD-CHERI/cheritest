#-
# Copyright (c) 2017 Alex Richardson
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

@attr('capabilities')
class test_cp2_x_csc_bigimm(BaseBERITestCase):
    def test_cp2_x_clc_bigimm(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "CLC bigimm with bad address didn't raise an exception")

    @attr(no_experimental_clc=True)
    def test_cp2_x_csc_bigimm_not_implemented(self):
        self.assertRegisterEqual(self.MIPS.a3, 10, "CSC bigimm not implemented but didn't raise RESERVED INSTR")

    @attr(no_experimental_clc=False)
    def test_cp2_x_csc_bigimm_bad_addr(self):
        self.assertRegisterEqual(self.MIPS.a3, 5, "CSC bigimm didn't raise ADDRS (Store to an illegal address)")
