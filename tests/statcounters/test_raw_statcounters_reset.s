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
# Test the reset values of the stat counters
#

COUNTERS_PER_GROUP = 9
COUNTERS_GROUPS = 3
COUNTERS_GROUP_START_OFFSET = 7
THRESHOLD = 100

.global start
start:

    resetstatcounters  # reset stat counters

    move    $v0, $zero # init result bit vector to all 0s

    dli     $a0, (COUNTERS_GROUP_START_OFFSET + COUNTERS_GROUPS - 1) # init counter group selector
    foreach_group:

        dli $a1, (COUNTERS_PER_GROUP - 1) # init counter offset
        foreach_counter:

            getstatcounter 6, 4, 5      # a2 takes the value of counter a1 in group a0 
            sltiu   $a5, $a2, THRESHOLD # a5 <= 1 if a2 less than threshold, 0 otherwise
            or      $v0, $v0, $a5       # or a5 in the lsb of v0
            sll     $v0, $v0, 1         # shift v0 left by one

            bne     $a1, $zero, foreach_counter 
            daddiu  $a1, $a1, -1

        daddiu  $a4, $a0, -COUNTERS_GROUP_START_OFFSET
        bne     $a4, $zero, foreach_group
        daddiu  $a0, $a0, -1

    # Dump registers in the simulator
    mtc0 $v0, $26
    nop
    nop

    # Terminate the simulator
    mtc0 $v0, $23
    end:
    b end
    nop
