#-
# Copyright (c) 2017 Michael Roe
# Copyright (c) 2018 Alex Richardson
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

@attr('capabilities')
class test_cp2_x_cclearreg_reg(BaseBERITestCase):

    def test_after_clear(self):
        # 0x18ff mask -> 27,28 + 16-23
        for i in range(16, 29):
            if i not in (16, 17, 18, 19, 20, 21, 22, 23, 27, 28):
                assert self.MIPS.cp2[i].t, "c" + str(i) + " register should not have changed"
                continue
            # now the changed ones:
            if self.MIPS.CHERI_C27_TO_31_INACESSIBLE:
                assert self.MIPS.cp2[i].t, "c" + str(i) + " register should not have changed"
                assert self.MIPS.cp2[i].offset == 0x1234, "c" + str(i) + " register should not have changed"
            else:
                self.assertNullCap(self.MIPS.cp2[i], msg="c" + str(i))

