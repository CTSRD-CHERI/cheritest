#-
# Copyright (c) 2019 Alex Richardson
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
.include "macros_extra.s"

.macro make_sentry out, in
	cheri_2arg_insn 0x1d, \out, \in
.endm

# Check that cunseal does not permit unsealing sentry caps
# even if the address is set to -2 (with various plausible widths)
BEGIN_TEST
        cgetdefault $c1
        make_sentry 1, 1

        cgetdefault $c2

        # 64 bits
        dli         $t0, 0xfffffffffffffffe
        csetoffset  $c2, $c2, $t0
        check_instruction_traps $a1, cunseal $c1, $c1, $c2 # trap #1

        # 18 bits
        dli         $t0, 0x3fffe
        csetoffset  $c2, $c2, $t0
        check_instruction_traps $a2, cunseal $c1, $c1, $c2 # trap #2

        # 24 bits
        dli         $t0, 0xfffffe
        csetoffset  $c2, $c2, $t0
        check_instruction_traps $a3, cunseal $c1, $c1, $c2 # trap #3
END_TEST
