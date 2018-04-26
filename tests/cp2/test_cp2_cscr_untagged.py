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
from nose.plugins.attrib import attr

#
# FIXME
# These are tests for a particular representation of capabilities, and
# should be tagged as such.
#

class test_cp2_cscr_untagged(BaseBERITestCase):

    @attr('capabilities')
    @attr('cap256')
    def test_cp2_cscr_untagged_256_1(self):
        self.assertRegisterEqual(self.MIPS.a0, 0, "CSCR did not store the otype/perms correcty (256 bit representation)")

    @attr('capabilities')
    @attr('cap256')
    def test_cp2_cscr_untagged_256_2(self):
        self.assertRegisterEqual(self.MIPS.a1, 42, "CSCR did not store the cursor correcty (256 bit representation)")

    @attr('capabilities')
    @attr('cap256')
    def test_cp2_cscr_untagged_256_3(self):
        self.assertRegisterEqual(self.MIPS.a2, 0, "CSCR did not store the base correcty (256 bit representation)")

    @attr('capabilities')
    @attr('cap256')
    def test_cp2_cscr_untagged_256_4(self):
        self.assertRegisterEqual(self.MIPS.a3, 0, "CSCR did not store the length correcty (256 bit representation)")

    @attr('capabilities')
    @attr('cap128')
    def test_cp2_cscr_untagged_128_1(self):
        self.assertRegisterEqual(self.MIPS.a0, 0, "CSCR did not store the bounds/perms correctly (128 bit representation)")

    @attr('capabilities')
    @attr('cap128')
    def test_cp2_cscr_untagged_128_2(self):
        self.assertRegisterEqual(self.MIPS.a1, 42, "CSCR did not store the cursor correctly (128 bit representation)")

