#-
# Copyright (c) 2011 Robert N. M. Watson
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

pattern = 0x0000E7A5

class test_cp2_cloadtags(BaseBERITestCase):

    @attr('capabilities')
    def test_cp2_cloadtags(self):

        # When there were no tags, we got zeros
        self.assertRegisterEqual(self.MIPS.a0, 0x00000000, "CLoadTags initial pattern")

        # When we stored tags, we got a right-aligned mask with a power of
        # two bits.  While other reaches are possible, that would be very
        # strange and I don't thing we intend to have such strangely aligned
        # caches.
        assert self.MIPS.a1 in \
          [ 0x01, 0x03, 0x0F, 0xFF, 0xFFFF, 0xFFFFFFFF, 0xFFFFFFFFFFFFFFFF ], \
            ("CLoadTags reach %x not expected" % (self.MIPS.a1,))

        self.assertRegisterEqual(self.MIPS.a2, pattern & self.MIPS.a1,
            "CLoadTags updated pattern through DDC")

        self.assertRegisterEqual(self.MIPS.a3, pattern & self.MIPS.a1,
            "CLoadTags updated pattern through length-bounded cap")
