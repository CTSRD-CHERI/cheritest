#-
# Copyright (c) 2018 Alex Richardson
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

.set noreorder
.set nobopt
.set noat
.include "macros.s"

.set CAP_SIZE, 32
.set ex_vector, 0x9800000000000180


	.text
	.global start
	.ent start
start:

	# Enable capability coprocessor.

	mfc0		$t0, $12

	li		$t1, 0x40000000

	or		$t0, $t0, $t1
	# Clear ERL, EXL, BEV and IE
	li		$t1, 0x7 | (1 << 22)
	nor		$t1, $t1, $t1
	and		$t0, $t0, $t1

    # Set KSU = 0
    li      $t1, (0b11 << 3)
    not     $t1, $t1
    and      $t0, $t0, $t1

    # Set UX, SX, and KSX
    li      $t1, (0b111 << 5)
    or      $t0, $t0, $t1

    mtc0		$t0, $12

	# Wait for capability coprocessor to be enabled for real
	nop; nop; nop; nop; nop; nop; nop; nop;

	# Clear registers
	CClearLo	0xfffe
	CClearHi	0xffff

    # Install a trampoline for exceptions

    dla     $t0, tramp_start
    dli     $t1, ex_vector

    cgetdefault $c3
    cincoffset  $c4, $c3, $t0 # source
    cincoffset  $c5, $c3, $t1 # dest

    li      $t2, (0x4 * 10) # copy  instrs

1:  clw     $t0, $t2, (-4)($c4)
    daddiu  $t2, $t2, -0x4
    bnez    $t2, 1b
    csw     $t0, $t2, 0($c5)


    # The test setup

    dla     $t0, exception_test
    cgetpccsetoffset $c17, $t0
    dli     $t0, 8
    csetbounds  $c17, $c17, $t0
    cgetdefault $c18

    csetbounds  $c8, $c18, $zero

    cincoffset  $c5, $c18, 0x77
    cseal       $c1, $c17, $c5
    cseal       $c2, $c18, $c5

    # Call exception_test

    cjalr       $c17, $c6
    li          $a0, 0


success: # Success
    b           test_end
    li          $v0, 0xbabe

exception_test:
    cjr     $c17 # or ccall $c1, $c2, 1
    cld     $t0, $zero, 0($c8)


handle_exception:
    mfc0        $k0, $14
    bnez        $k0, 1f         # epc should not be in delay slot
    cgetepcc    $c7
    cgetoffset  $k0, $c7
    bnez        $k0, 1f         # epcc should not be in delay slot
    nop
    bnez        $a0, 1f         # only one exception
    li          $a0, 1
    csetepcc    $c6             # try setting epcc for eret but not epc
    DO_ERET
    nop

1:  # Fail
    b           test_end
    li          $v0, 0xbad
    nop
    nop
    nop



tramp_start:
    dla $k0, handle_exception
    jr  $k0
    nop
    nop
    nop
tramp_end:


test_end:
	ssnop
	ssnop
	mtc2 $k0, $0, 6	# dump CHERI regs
	mtc0 $at, $26	# Dump MIPS registers
	nop
	nop
	mtc0 $at, $23	# Terminate the simulator
	nop
.global end
end:
	ori $0, $0, 0xdead	# stop tracing on QEMU
	b end
	daddiu $zero, $zero, 0  # load zero nop to indicate core 0
.end start
