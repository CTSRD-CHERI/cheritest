#
# Copyright (c) 2018 Alex Richardson
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

from beritest_tools import BaseBERITestCase, attr

@attr('capabilities')
class test_cp2_ccall_fast_pcc_perms(BaseBERITestCase):
    def test_sandbox_run(self):
        assert self.MIPS.a1 == 0x42, "sanbox should run"

    def test_pre_sandbox_pcc(self):
        assert self.MIPS.c5.s == 0, "pre-sandbox pcc should not be sealed"
        assert self.MIPS.c5.t, "pre-sandbox pcc should not be tagged"
        assert self.MIPS.c5.perms == self.max_permissions
        assert self.MIPS.c5.ctype == self.unsealed_otype

    def test_in_sandbox_pcc(self):
        assert self.MIPS.c6.s == 0, "in sandbox pcc should not be sealed"
        assert self.MIPS.c6.t, "in sandbox pcc should not be tagged"
        assert self.MIPS.c6.perms == self.permission_bits.Execute | self.permission_bits.CCall
        assert self.MIPS.c6.ctype == self.unsealed_otype

    def test_post_sandbox_pcc(self):
        assert self.MIPS.c7.s == 0, "post-sandbox pcc should not be sealed"
        assert self.MIPS.c7.t, "post-sandbox pcc should not be tagged"
        assert self.MIPS.c7.perms == self.max_permissions
        assert self.MIPS.c7.ctype == self.unsealed_otype
        assert self.MIPS.c7.t

    def test_idc(self):
        assert self.MIPS.idc.s == 0, "idc should not be sealed"
        assert self.MIPS.idc.t, "idc should not be tagged"
        assert self.MIPS.idc.ctype == self.unsealed_otype
        assert self.MIPS.idc.perms == self.max_nonexec_perms
        assert self.MIPS.idc.base == 0x10000
        assert self.MIPS.idc.length == 0x1000
        assert self.MIPS.idc.offset == 0
