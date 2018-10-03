#-
# Copyright (c) 2017 Michael Roe
# All rights reserved.
#
# @BERI_LICENSE_HEADER_START@
#
# This software was developed by the University of Cambridge Computer
# Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
# project, funded by EPSRC grant EP/K008528/1.
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

# With the removal of CCallFast delay slot, the instruction after CCallFast
# should not be run and should not trigger any exceptions (including ITLB, CP2
# PCC len and interrupts).

# This test checks if DTLB or CP2 PCC len will fire. If the architecture still
# has a delay slot, one of the exceptions will fire.

BEGIN_TEST
  # Initialise $t2. The test fails if $v0 is not 0x44 (i.e. exception triggered).
  dli             $v0, 0x44
  clear_counting_exception_handler_regs	# This test should not trigger an exception


  cgetpcc         $c3
  cgetdefault     $c4
  dli             $t0, 0x12
  csetoffset      $c5, $c4, $t0
  dla             $t0, continue
  csetoffset      $c3, $c3, $t0
  cseal           $c3, $c3, $c5
  dli             $t0, -3      # clear perm execute in data cap
  candperm        $c4, $c4, $t0
  cseal           $c4, $c4, $c5

  # Construct a PCC that does not include the delay slot of CCallFast
  cgetpcc         $c6
  csetoffset      $c6, $c6, $zero
  dla             $t0, test_slot
  csetbounds      $c6, $c6, $t0
  dla             $t0, test_body
  csetoffset      $c6, $c6, $t0
  cjr             $c6
  nop

test_body:
  ccall           $c3, $c4, 1
test_slot:
  # This instruction should not fire any exceptions.
  lw              $t0, 0x123($zero)
  nop
  nop

continue:
	save_counting_exception_handler_cause $c9
  add             $t0, $zero, $zero

END_TEST
