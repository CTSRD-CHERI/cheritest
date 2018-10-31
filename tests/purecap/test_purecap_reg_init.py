#-
# Copyright (c) 2017 Alex Richardson
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

# Check that the registers used in purecap tests are initialized to usable values
class test_purecap_reg_init(BaseBERITestCase):
    @attr('capabilities')
    def test_pcc(self):
        self.MIPS.pcc.offset = (self.MIPS.pcc.offset & 0x00FFFFFFFFFFFFFF)
        self.assertValidCap(self.MIPS.pcc, "$pcc", offset=(0x00000040000000, 0x000000400fffff),
                            length=self.max_length, perms=self.max_nostore_perms)

    @attr('capabilities')
    def test_ddc(self):
        # Default cap without permit_execute
        self.assertDefaultCap(self.MIPS.ddc, msg="ddc is wrong", perms=self.max_nonexec_perms)

    @attr('capabilities')
    def test_other_capregs(self):
        for regnum in range(1, 31):
            name = "$c" + str(regnum)
            cap = self.MIPS.cp2[regnum]
            if regnum == 11:
                self.assertValidCap(cap, name + " (stack cap)", perms=self.max_nonexec_perms,
                                    offset=self.MIPS.sp, length=self.max_length)
            elif regnum == 12:
                self.assertValidCap(cap, name + " (jump cap)", perms=self.max_nostore_perms,
                                    offset=self.MIPS.t9, length=self.max_length)
            elif regnum == 17:
                self.assertValidCap(cap, name + " (link cap)", perms=self.max_nostore_perms,
                                    offset=self.MIPS.ra, length=self.max_length)
            else:
                # All other capability registers should be null
                # Note: $c26 should also be null since _CHERI_CAPABILITY_TABLE_ will have
                # value zero because there are no global capabilities. This ensures
                # that we can reuse the same checks for both cap-table and legacy ABI
                self.assertNullCap(cap, name)
