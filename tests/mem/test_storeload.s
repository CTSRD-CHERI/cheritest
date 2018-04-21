#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2012 Robert M. Norton
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
# Test that a store followed immediately by a load gets the correct value.
#

BEGIN_TEST
		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a0, 0
		dli	$a1, 0
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0
		dli	$a6, 0
		dli	$a7, 0


                dla     $a0, bytes
                dli     $a1, 0x5656565656565656
                li      $t0, 0

                # exeucte the test in a loop to pre-cache the instructions
loop:
                nop
                nop
                ld      $a2, 0($a0)
                ld      $a3, 0($a0)
                ld      $a4, 0($a0)
                sd      $a1, 0($a0)
                ld      $a5, 0($a0)
                ld      $a6, 0($a0)
                ld      $a7, 0($a0)
                nop
                nop
                sd      $a1, 0($a0)
                # change the stored value second time round to actually do the test
                dli     $a1, 0xfeedbeefdeadbeef
                beqz    $t0, loop
                add     $t0, 1
        
END_TEST

		.data
		.align	5
bytes:		.dword	0x5656565656565656
