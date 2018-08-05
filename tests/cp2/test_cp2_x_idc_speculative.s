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
#
# Test that instructions in the branch delay slot of cjalr use the permissions
# of PCC before the branch, not after the branch.
#

sandbox:
  nop
  nop
  nop
  # This ccall should be the last instruction in a mispredicted sequence.
  # Note a change in the number of pipeline stages might also change this.
  ccall           $c6, $c4, 1
  nop
  

BEGIN_TEST

  jal             bev_clear
  nop
  dla             $a0, bev0_handler
  jal             bev0_handler_install
  nop

  # Initialise $t2. The test fails if $t2 is 0x33.
  dli             $t2, 0x44

  cgetdefault     $c4
  cgetpcc         $c3
  dli             $t0, 0x12
  csetoffset      $c5, $c4, $t0
  dla             $t0, continue
  csetoffset      $c3, $c3, $t0
  dla             $t0, the_loop
  csetoffset      $c6, $c3, $t0
  cseal           $c3, $c3, $c5
  cseal           $c4, $c4, $c5
  cseal           $c6, $c6, $c5

  dli             $t1, 8 # Train the branch predictor 8 times.
the_loop:
  bnez            $t1, sandbox
  daddiu          $t1, $t1, -1
  
  # This ccall should be preceded by a speculative mispredicted ccall.
  ccall           $c3, $c4, 1
  nop

continue:
  nop

END_TEST

  # Entering this exception handler means failure.
  .ent bev0_handler
bev0_handler:
  dmfc0           $k0, $14 # EPC
  daddiu          $k0, $k0, 8 # EPC += 8 to bump PC forward on ERET N.B. 8 because we wish to skip instruction after svc!
  dmtc0           $k0, $14
  nop # NOPs to avoid hazard with ERET
  nop # XXXRW: How many are actually
  nop # required here?
  dli             $t2, 0x33
  eret
  .end bev0_handler
