#-
# Copyright (c) 2014 Michael Roe
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
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

from cheritest_tools import BaseCHERITestCase
from nose.plugins.attrib import attr

#
# Test that cfromptr creates a null capability when given the NULL pointer
# as input.
#

class test_cp2_cfromptr_null(BaseCHERITestCase):

    @attr('capabilities')
    def test_cp2_cfromptr_null_perm(self):
        '''Test that cfromptr of a NULL pointer clears the permissions field'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "cfromptr did not clear the permissions field")

    @attr('capabilities')
    def test_cp2_cfromptr_null_base(self):
        '''Test that cfromptr of a NULL pointer clears the base field'''
        self.assertRegisterEqual(self.MIPS.a1, 0, "cfromptr did not clear the base field")

    @attr('capabilities')
    def test_cp2_cfromptr_null_length(self):
        '''Test that cfromptr of a NULL pointer clears the length field'''
        self.assertRegisterEqual(self.MIPS.a2, 0, "cfromptr did not clear the length field")

    @attr('capabilities')
    def test_cp2_cfromptr_null_type(self):
        '''Test that cfromptr of a NULL pointer clears the type field'''
        self.assertRegisterEqual(self.MIPS.a3, 0, "cfromptr did not clear the type field")

    @attr('capabilities')
    def test_cp2_cfromptr_null_tag(self):
        '''Test that cfromptr of a NULL pointer sets the tag bit'''
        self.assertRegisterEqual(self.MIPS.a4, 1, "cfromptr did not set the tag bit")

    @attr('capabilities')
    def test_cp2_cfromptr_null_unsealed(self):
        '''Test that cfromptr of a NULL pointer clears the unsealed bit'''
        self.assertRegisterEqual(self.MIPS.a5, 0, "cfromptr did not clear the unsealed bit")

