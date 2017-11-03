#-
# Copyright (c) 2015-2017 Alexandre Joannou
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

.include "statcounters_macros.s"

.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test the counters for the l2 master interface
#

DELAY_TIME = 1000

READ_REQ_TIMES = 268

.global start
start:

    # dword address in v0
    dli             $v0,  0x9000000040000000
    # test 1 : read request
    dli             $a5, 2      # looping just to make sure no instruction miss will be counted
    1:
    delay           $at, DELAY_TIME
    resetstatcounters
    delay           $at, DELAY_TIME
    dli             $a6, READ_REQ_TIMES - 1
    2:
    flush_nops
    ld              $t0, 0($v0)
    bne             $a6, $zero, 2b
    daddi           $a6, -1
    delay           $at, DELAY_TIME
    getstatcounter  6, L2CACHEMASTER, READ_REQ  # a2 takes the value of counter READ_REQ in group L2CACHEMASTER
    bne             $a5, $zero, 1b
    daddi           $a5, -1

    # Dump registers in the simulator
    mtc0            $v0, $26
    nop
    nop

    # Terminate the simulator
    mtc0            $v0, $23
    end:
    b end
    nop
