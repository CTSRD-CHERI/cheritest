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
# Test to check that jumping to capability with negative offset
# causes a trap.
#

BEGIN_TEST
        # Create a capability to jump to (although we hopefully won't get there)
        cgetdefault $c1
        dla         $t0, the_end_my_friend
        cincoffset  $c1, $c1, $t0
        dli         $t1, 4
        csetbounds  $c1, $c1, $t1

        # set offset to -1
        cincoffset  $c1, $c1, -1
        
        check_instruction_traps $s0, cjr $c1

the_end_my_friend:
END_TEST
