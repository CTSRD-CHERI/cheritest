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

#
# Test the reset values of the stat counters
#

.include "statcounters_macros.s"

THRESHOLD = 100

.macro checkstatcounter counter_group, counter_offset, threshold
    getstatcounter 6, \counter_group, \counter_offset # a2 gets the counter's value
    sltiu   $a5, $a2, \threshold # a5 <= 1 if a2 less than threshold, 0 otherwise
    sll     $v0, $v0, 1          # shift v0 left by one
    or      $v0, $v0, $a5        # or a5 in the lsb of v0
.endm

.set mips64
.set noreorder
.set nobopt
.set noat

.global start
start:

    resetstatcounters  # reset stat counters

    move    $v0, $zero # init result bit vector to all 0s

    checkstatcounter ICACHE, WRITE_HIT, THRESHOLD
    checkstatcounter ICACHE, WRITE_MISS, THRESHOLD
    checkstatcounter ICACHE, READ_HIT, THRESHOLD
    checkstatcounter ICACHE, READ_MISS, THRESHOLD*2
    checkstatcounter ICACHE, PFTCH_HIT, THRESHOLD
    checkstatcounter ICACHE, PFTCH_MISS, THRESHOLD
    checkstatcounter ICACHE, EVICT, THRESHOLD
    checkstatcounter ICACHE, PFTCH_EVICT, THRESHOLD

    checkstatcounter DCACHE, WRITE_HIT, THRESHOLD
    checkstatcounter DCACHE, WRITE_MISS, THRESHOLD
    checkstatcounter DCACHE, READ_HIT, THRESHOLD
    checkstatcounter DCACHE, READ_MISS, THRESHOLD*2
    checkstatcounter DCACHE, PFTCH_HIT, THRESHOLD
    checkstatcounter DCACHE, PFTCH_MISS, THRESHOLD
    checkstatcounter DCACHE, EVICT, THRESHOLD
    checkstatcounter DCACHE, PFTCH_EVICT, THRESHOLD

    checkstatcounter L2CACHE, WRITE_HIT, THRESHOLD
    checkstatcounter L2CACHE, WRITE_MISS, THRESHOLD
    checkstatcounter L2CACHE, READ_HIT, THRESHOLD
    checkstatcounter L2CACHE, READ_MISS, THRESHOLD*2
    checkstatcounter L2CACHE, PFTCH_HIT, THRESHOLD
    checkstatcounter L2CACHE, PFTCH_MISS, THRESHOLD
    checkstatcounter L2CACHE, EVICT, THRESHOLD
    checkstatcounter L2CACHE, PFTCH_EVICT, THRESHOLD

    checkstatcounter MIPSMEM, BYTE_READ, THRESHOLD
    checkstatcounter MIPSMEM, BYTE_WRITE, THRESHOLD
    checkstatcounter MIPSMEM, HWORD_READ, THRESHOLD
    checkstatcounter MIPSMEM, HWORD_WRITE, THRESHOLD
    checkstatcounter MIPSMEM, WORD_READ, THRESHOLD
    checkstatcounter MIPSMEM, WORD_WRITE, THRESHOLD
    checkstatcounter MIPSMEM, DWORD_READ, THRESHOLD
    checkstatcounter MIPSMEM, DWORD_WRITE, THRESHOLD
    checkstatcounter MIPSMEM, CAP_READ, THRESHOLD
    checkstatcounter MIPSMEM, CAP_WRITE, THRESHOLD

    checkstatcounter TAGCACHE, WRITE_HIT, THRESHOLD
    checkstatcounter TAGCACHE, WRITE_MISS, THRESHOLD
    checkstatcounter TAGCACHE, READ_HIT, THRESHOLD
    checkstatcounter TAGCACHE, READ_MISS, THRESHOLD*2
    checkstatcounter TAGCACHE, PFTCH_HIT, THRESHOLD
    checkstatcounter TAGCACHE, PFTCH_MISS, THRESHOLD
    checkstatcounter TAGCACHE, EVICT, THRESHOLD
    checkstatcounter TAGCACHE, PFTCH_EVICT, THRESHOLD

    checkstatcounter L2CACHEMASTER, READ_REQ, THRESHOLD*2
    checkstatcounter L2CACHEMASTER, WRITE_REQ, THRESHOLD
    checkstatcounter L2CACHEMASTER, WRITE_REQ_FLIT, THRESHOLD
    checkstatcounter L2CACHEMASTER, READ_RSP, THRESHOLD*2
    checkstatcounter L2CACHEMASTER, READ_RSP_FLIT, THRESHOLD*2
    checkstatcounter L2CACHEMASTER, WRITE_RSP, THRESHOLD

    checkstatcounter TAGCACHEMASTER, READ_REQ, THRESHOLD*2
    checkstatcounter TAGCACHEMASTER, WRITE_REQ, THRESHOLD
    checkstatcounter TAGCACHEMASTER, WRITE_REQ_FLIT, THRESHOLD
    checkstatcounter TAGCACHEMASTER, READ_RSP, THRESHOLD*2
    checkstatcounter TAGCACHEMASTER, READ_RSP_FLIT, THRESHOLD*2
    checkstatcounter TAGCACHEMASTER, WRITE_RSP, THRESHOLD

    # Dump registers in the simulator
    mtc0 $v0, $26
    nop
    nop

    # Terminate the simulator
    mtc0 $v0, $23
    end:
    b end
    nop
