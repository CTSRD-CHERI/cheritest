#-
# Copyright (c) 2018 Alex Richardson
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

.include "macros.s"

#
# Test whether the cjalr/jalr output register is accessible in the branch delay slot
#
BEGIN_TEST
		move $s0, $ra	# save return address

		dla $t0, target1
		cgetpccsetoffset $c12, $t0
		cgetnull	$c17
		cjalr	$c12, $c17
		cmove	$c4, $c17
		nop
		nop
target1:
		# $c17.offset == $t0 - 8 (skip the two nops)
		cmove	$c5, $c17  # get return address after delay slot
		cmove	$c6, $c12  # get jump address after delay slot

		# see what jalr does
		dli	$ra, -1
		dla	$t9, target2
		jalr	$t9
		move	$a0, $ra	# get $ra value in delay slot
		nop
		nop
target2:
		move	$a1, $ra	# get $ra value after delay slot
		move	$a2, $t9	# get jump value after delay slot

		b return
		nop
return:
		move $ra, $s0	# restore return address
END_TEST
