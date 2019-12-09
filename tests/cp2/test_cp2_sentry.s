#-
# Copyright (c) 2019 Alex Richardson
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
.include "macros_extra.s"


BEGIN_TEST

	dli $a7, 0	# number of sandbox calls

	# create a code capability ($c7) and seal it ($c1) using the new CSealEntry instruction
	cap_from_label	$c12, label=sandbox
	check_instruction_traps $s0, csealentry $c1, $c12		# should not trap

	# This should trap since $c3 does not have permit_execute
	dli	$t0, 0
	candperm	$c4, $c12, $t0
	cgetnull	$c5	# should still be null
	# csealcode	$c1, $c5, $c4
	check_instruction_traps $s1, csealentry $c5, $c4		# trap #1

	# check that we can't use CSealEntry with sealed caps
	# create a seal cap for otyp 1234
	dli		$t0, 0x1234
	cgetdefault	$c16
	csetoffset	$c16, $c16, $t0
	check_instruction_traps  $s2, cseal	$c7, $c12, $c16		# should not trap
	# sealed caps can't be sentries:
	# csealcode	$c1, $c8, $c7
	check_instruction_traps $s3, csealentry $c8, $c7		# trap #2


	# no check that we can't modify the sentry cap
	check_instruction_traps $s4, cincoffset	$c18, $c1, 1	# trap #3
	# TODO: should candperm be allowed?
	check_instruction_traps $s5, candperm	$c18, $c1, $zero	# trap #4
	# Check that we can move the value
	check_instruction_traps $s6, cmove	$c19, $c1		# no trap
	check_instruction_traps $s7, cincoffset	$c20, $c1, $zero	# no trap


	# Now check properties of the sentry cap
	cgetsealed $a1, $c1
	cgetperm $a2, $c1
	cgetbase $a3, $c1
	cgetoffset $a4, $c1
	cgetlen $a5, $c1
	cgettag $a6, $c1
	cgettype $t8, $c1

	# Check that we can call the sandbox with the unsealed cap:
	cjalr	$c12, $c17
	CFromInt $c21, $t0	# Check that we loaded the "0x1234" with a normal call


	# Check that we can call but not load the value if PERM_LOAD is missing
	dli	$t0, ~CHERI_PERM_LOAD
	candperm	$c13, $c12, $t0
	cjalr	$c13, $c17
	CFromInt $c22, $t0	# Check that we didn't load 0x1234


	# Check that we can call the sandbox with the sentry cap:
	cjalr	$c1, $c17
	CFromInt $c23, $t0	# Check that we loaded the "0x1234" with a sentry cjalr

	# test a sentry cap without permit_load
	csealentry	$c14, $c13
	cjalr	$c14, $c17
	CFromInt $c24, $t0	# Check that didn't load "0x1234" with a no_load sentry cjalr

	# Finally check that cjr works with sentry caps:
	cap_from_label	$c17, label=return_result_1
	cjr	$c1
	nop
return_result_1:
	CFromInt $c25, $t0	# Check that we loaded the "0x1234" with a sentry cjr

	cap_from_label	$c17, label=return_result_2
	cjr	$c14
	nop
return_result_2:
	CFromInt $c26, $t0	# Check that didn't load "0x1234" with a no_load sentry cjr


	# finally check that we can't load via the sentry cap:
	dli $t3, 0xbad
	check_instruction_traps $t2, clb $t3, $zero, 0($c1) # trap #8

	dla $a0, 42	# success
return_fail:
END_TEST

.balign 1024	# add some padding
.ent sandbox
sandbox:
		daddiu $a7, $a7, 1
		dli	$t0, 0xbad	# ensure we don't accidentally keep the old value
		cgetpcc $c18
		cld	$t0, $zero, 16($c18)	# this should load 0x1234
		cjr $c17
		nop
		.8byte 0x1234	# cgetpcc + 16
.end sandbox
