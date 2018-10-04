#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2018 Robert M. Norton
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

#
# Test that clearing tag on EPCC before ERET will cause an exception.
#
#

BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER
.set at
    li         $s1, 0 # for trap info
    li         $s2, 0 # for EPC

    cgetepcc   $c1
    # Set the EPCC.offset to expected_epc so that we should end up there
    dla        $s0, expected_epc
    csetoffset $c1, $c1, $s0

    # invalidate EPCC in some way according to particular test
    invalidate_epcc $c1

    csetepcc   $c1
    # some nops for good measure since above should write CP0 EPC
    DO_ERET
    nop
expected_epc:
    nop
end_test:
END_TEST

.global default_trap_handler
default_trap_handler:
    collect_compressed_trap_info $s1
    dmfc0	$s2, $14        # Get EPC
    cgetepcc	$c2             # ...and EPCC

    # End the test
    dla         $t0, end_test
    jr          $t0
    nop
