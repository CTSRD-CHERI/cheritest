#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2017 Robert M. Norton
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
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test to ensure that EPCC is set correctly when offset (PC) goes just
# outside the bounds of PCC, which should be representable even with
# compressed capabilities
#

# Outputs to check:
#
# $a0 - exception counter (should be 1)
# $a1 - set to 1 in sandbox (should be 1)

#
# $a7 - saved base of sandbox

# $s0 - saved length of sandbox (should be roughly 20)
# $s1 - cause register from exception (should be CP2)
# $s2 - Saved cap cause from exception
# $s3 - EPC register from exception

# $c1 - capability for sandbox 
# $c2 - saved PCC from sandbox
# $c3 - saved EPCC from exception
#
BEGIN_TEST
                #
                # Set up 'handler' as the RAM exception handler.
                #
                jal     bev_clear
                nop
                dla     $a0, exception_handler
                jal     bev0_handler_install
                nop

                #
                # Initialise trap counter.
                #
                dli     $a0, 0

                #
                # Prepare $c1 to point at the space between 'sandbox_begin'
                # and 'sandbox_end'.
                #
                # Calculate desired length of $c1 into $s0, then set the length.
                #

                cgetdefault $c1
                dla        $a7, sandbox_begin
                csetoffset $c1, $c1, $a7
                dla        $t0, sandbox_end
                dsubu      $s0, $t0, $a7
                csetbounds $c1, $c1, $s0

                #
                # Restrict to Non_Ephemeral, Permit_Execute
                # and Permit_Load permissions.
                #

                dli      $t0, 0x0007
                candperm $c1, $c1, $t0

                # Jump into the sandbox
                cjr    $c1
                nop

                # Should not end up here.
                b      .
                nop

                #
                # In this window, working with a modified PCC.  We cannot
                # rely on any linker-calculated addresses as a result.
                #
                # NOTE: the number of instructions in this window is
                # hard-coded into test_cp2_exception_epcc.py.  If you change
                # it here, remember to change it there!
                #
sandbox_begin:
                dli     $a1, 1          # 0x0: Address space transformed

                #
                # To confirm we are running with a modified PCC, query PC
                # using a minimalist JALR.
                #
                cgetpcc $c2

                # Allow PC to run off end of sandbox
sandbox_end:
                # Should not end up here
                b       .
                nop

return:
END_TEST
#
# Exception handler, which relies on the installation of KCC into PCC in order
# to run.  This code assumes that the trap was not in a branch delay slot.
#
                .ent exception_handler
exception_handler:
                daddiu  $a0, $a0, 1     # Increment trap counter
                # Capture cause register so we can make sure that an
                # exception was thrown for the right reason!
                mfc0    $s1, $13        # Get cause register
                cgetcause $s2

                # Save sandbox EPC for later inspection
                dmfc0   $s3, $14
                # Save EPCC
                cgetepcc	$c3

                # Remove sandboxing
                csetepcc	$c0       # Move $c0 into $epcc
                # Set EPC to continue after exception return
                dla     $k0, return
                dmtc0   $k0, $14
exception_done:
                nop                     # Avoid CP0 hazards with ERET
                nop                     # XXXRW: How many are actually
                nop                     # required here?
                nop
                nop
                nop
                nop
                eret
                .end exception_handler
