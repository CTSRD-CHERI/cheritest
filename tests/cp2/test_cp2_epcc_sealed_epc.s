#-
# Copyright (c) 2019 Robert M. Norton
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

.include "macros.s"

#
# Test to check that writing EPC when EPCC is sealed does not result in
# modifying a sealed capability
#
BEGIN_TEST
        # Set a sealed EPCC
        cgetdefault $c1
        cgetdefault $c2
        li          $t0, 16
        cincoffset  $c2, $c2, $t0
        cseal       $c1, $c1, $c2
        csetepcc    $c1

        # change EPC which could should not result in changing offset of EPCC
        li          $t0, 0xebad
        dmtc0       $t0, $14 # attempt to set EPC

        # Obligatory nops following CP0 write
        nop
        nop
        nop
        nop
        nop
        nop

        cgetepcc    $c3
END_TEST
