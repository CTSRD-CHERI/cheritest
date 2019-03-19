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

from beritest_tools import BaseBERITestCase, xfail_on, is_feature_supported

class test_x_jalx_ri(BaseBERITestCase):
    EXPECTED_EXCEPTIONS = 1

    def test_x_jalx_ri(self):
        self.assertRegisterEqual(self.MIPS.v0, 1, "JALX isn't supported, but didn't raise an exception")

    def test_x_jalx_ri_clc_bigimm_cp2_off(self):
        have_caps = is_feature_supported("capabilities")
        have_clc_bigimm = is_feature_supported("experimental_clc") and not is_feature_supported("no_experimental_clc")
        print("have_capabilities:", have_caps, "have_clc_bigimm:", have_clc_bigimm)
        if have_caps and have_clc_bigimm:
            self.assertCompressedTrapInfo(self.MIPS.s1, mips_cause=self.MIPS.Cause.COP_Unusable, trap_count=1,
                msg="CLC (BigImm) is supported -> should raise a coprocessor disabled exception")
        else:
            # instruction should not be supported and raise RI
            self.assertCompressedTrapInfo(self.MIPS.s1, mips_cause=self.MIPS.Cause.ReservedInstruction, trap_count=1,
                msg="CLC (BigImm) is not supported -> should raise a RI exception")
