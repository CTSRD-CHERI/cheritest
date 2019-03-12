#-
# Copyright (c) 2019 Robert M. Norton-Wright
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

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"

#
# Test cheri concentrate corner cases.
#

BEGIN_TEST
        cgetdefault $c1
        # base=0, length=0
        csetbounds  $c1, $c1, $0
        # set address to -1
        cincoffset  $c2, $c1, -1
        cgetbase    $s0, $c2
        cgetlen     $s1, $c2
        cgettag     $s2, $c2
        #check_instruction_traps  $s3,
        #clb $0, $0, 0($c1)

        cgetdefault $c3
        # base=2**64-1, length=1
        cincoffset  $c3, $c3, -1
        csetbounds  $c3, $c3, 1
        # set address to 0
        cincoffset  $c4, $c3, 1
        cgetbase    $a0, $c4
        cgetlen     $a1, $c4
        cgettag     $a2, $c4
        #clb         $0, $0, 0($c4)
END_TEST

