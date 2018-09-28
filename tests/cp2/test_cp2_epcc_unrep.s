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
# Test to check that EPCC is set to something sensible when EPC is set to
# a location which is so far out of the bounds of EPCC that it is not
# representable with compressed capabilities. It's important to get this
# correct otherwise it could break the monotonicity of capabilities.
#
# Outputs to check:
#
#
# $a7 - saved base of sandbox

# $s3 - EPC register after made unrepresentable.

# $c1 - capability for sandbox 
# $c3 - saved EPCC that is unrepresentable
#
BEGIN_TEST
this_test:
                #
                # Prepare $c1 to point at a small "sandbox".
                #
                # Calculate desired length of $c1 into $s0, then set the length.
                #

                cgetdefault $c1
                dla         $a7, this_test
                csetoffset  $c1, $c1, $a7
                csetbounds  $c1, $c1, 20
                cgetlen     $s0, $c1

                #
                # Restrict to Non_Ephemeral, Permit_Execute
                # and Permit_Load permissions.
                #

                dli      $t0, 0x0007
                candperm $c1, $c1, $t0

                # Write the sandbox capability into EPCC
                csetepcc $c1 
                
                # Create an unrepresentable offset to place in EPC, which should
                # set the offset of EPCC to an unrepresentable value.
                dli     $t0, 0x10000000
                dmtc0   $t0, $14
                
                # Let CP0 settle out...
                nop
                nop
                nop
                nop
                nop
                nop
                
                # Pull out EPC for inspection
                dmfc0    $s3, $14
                # Observe EPCC
                cgetepcc $c3

END_TEST
