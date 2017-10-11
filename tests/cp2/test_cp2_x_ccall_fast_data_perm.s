#-
# Copyright (c) 2017 Alfredo Mazzinghi
# Copyright (c) 2017 Hongyan Xia
# Copyright (c) 2012 Michael Roe
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

# Test whether it is possible to perform a fast ccall without the Permit_CCall
# permission set on the sealed data capability.
# Test conditions:
# t1 must be set to 0x0: sandbox not entered.
# t3 must be set to 0x1902: permit ccall violation on register $c2


	.global test
test:	.ent test
	daddu 	$sp, $sp, -32
	sd	$ra, 24($sp)
	sd	$fp, 16($sp)
	daddu	$fp, $sp, 32

	#
	# Set up 'handler' as the RAM exception handler.
	#
	jal	bev_clear
	nop
	dla	$a0, exception_handler
	jal	bev0_handler_install
	nop

        #
        # Make $c4 a template capability for user-defined type
        # number 0x1234.
        #

        dli         $t0, 0x1234
        csetoffset  $c4, $c0, $t0

        #
        # Make $c3 a data capability for the array at address data
        #

        dla         $t0, data
        cincoffset  $c3, $c0, $t0
        dli         $t0, 0x1000
        csetbounds  $c3, $c3, $t0
        # Permissions Non_Ephemeral, Permit_Load, Permit_Store,
        # Permit_Store, Permit_CCall.
        # NB: Permit_Execute must not be included in the set of
        # permissions used here.
        dli         $t0, 0xd
        candperm    $c3, $c3, $t0

        #
        # Seal data capability $c3 to the offset of $c4, and store
        # result in $c2.
        #

        cseal       $c2, $c3, $c4

        #
        # Make $c1 a code capability for sandbox
        #

        cgetpcc     $c1
	dli         $t0, 0x1ff
	candperm    $c1, $c1, $t0
	dla         $t0, sandbox
        csetoffset  $c1, $c1, $t0
        cseal       $c1, $c1, $c4

        li          $t1, 0      # clear $t1, a change in $t1 means failure.

        # do the ccallfast 
	ccall	    $c1, $c2, 1
	nop

restored_ra:
	ld	$fp, 16($sp)
	ld	$ra, 24($sp)
	jr	$ra
	daddiu  $sp, $sp, 32	# branch-delay slot
	.end	test

        .ent sandbox
sandbox:
        dla     $t0, restored_ra
        jr      $t0
        li      $t1, 0xbeef     # this sandbox should not be entered
        .end sandbox


#
# Exception handler, which relies on the installation of KCC into PCC in order
# to run.
#
	.ent exception_handler
exception_handler:
        dmfc0   $k0, $14
        daddiu  $k0, $k0, 8 # advance the EPC by two instructions
        		    # and return to restored_ra
	cgetcause $t3	# store exception cause to t3 for the test suite to check.
        dmtc0   $k0, $14
        nop
        nop
	eret
	.end exception_handler


        .data
        .align  12
data:   .dword  0x0102030405060708
        .dword  0xffffffffffffffff
