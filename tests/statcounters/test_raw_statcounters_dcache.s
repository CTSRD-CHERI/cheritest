#-
# Copyright (c) 2015 Alexandre Joannou
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

.macro getstatcounter dest, counter_group, counter_offset
    .word (0x1F << 26) | (0x0 << 21) | (\dest << 16) | (\counter_group << 11) | (\counter_offset << 6) | (0x3B)
.endm
.macro resetstatcounters
    .word (0x1F << 26) | (0x0 << 21) | (0x0 << 16) | (0xA << 11) | (0x0 << 6) | (0x3B)
.endm   

.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test the counters for the dcache
#

COUNTERS_PER_GROUP = 9
COUNTERS_GROUPS = 3
COUNTERS_GROUP_START_OFFSET = 7
THRESHOLD = 100

DCACHE = 8
READ_MISS = 2

.global start
start:

    resetstatcounters  # reset stat counters

    dli             $a4,  100
    delay:
    bne             $a4, $zero, delay
    daddi           $a4, -1

    ld              $v0,  dword

    #dli             $a0, DCACHE     # init counter group selector
    #dli             $a1, READ_MISS  # init counter offset
    getstatcounter  6, DCACHE, READ_MISS         # a2 takes the value of counter a1 in group a0 

    # Dump registers in the simulator
    mtc0 $v0, $26
    nop
    nop

    # Terminate the simulator
    mtc0 $v0, $23
    end:
    b end
    nop

.data
dword:		.dword	0xf00df00dbeefbeef
