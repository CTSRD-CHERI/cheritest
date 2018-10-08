#-
# Copyright (c) 2012, 2015 Michael Roe
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
.include "macros.s"
#
# Test that an exception is raised if a jump register instruction goes
# outside the range of PCC.
#

.ent sandbox
sandbox:
		# add some nops to ensure epcc.offset doesn't happen to be correct by chance
		nop
		nop
		branch_out_of_bounds	$a0
		ori	$a5, $zero, 0xbad	# delay slot should not execute
		nop
		cjr	$c24
		nop
		nop
limit:
		nop
out_of_bounds:
		nop
.end sandbox

BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER

# 		ori $0, $0, 0xdead	# stop tracing on QEMU

		# $a2 will be set to 1 if the exception handler is called
		dli	$a1, 0	# used by trap handler
		dli	$a2, 0	# used by trap handler
		dli	$a3, 0	# used by trap handler
		dli	$a4, 0 	# compressed trap info
		# $a5 will be set to 0xbad if the branch delay slot executes
		dli	$a5, 1

		cgetdefault $c1
		dla     $t0, sandbox
		cincoffset $c1, $c1, $t0
		dla     $t2, limit - sandbox
		csetbounds $c1, $c1, $t2

		#
		# Make $a0 outside the sandbox
		#

		dli	$a0, 1
		dsll	$a0, $a0, 32

		cjalr	$c1, $c24
		nop			# Branch delay slot
finally:
		move	$s0, $ra	# save $ra (to check that jalr didn't change it)
		dla	$s1, sandbox	# to check the trap address
END_TEST

BEGIN_CUSTOM_TRAP_HANDLER
		cgetepcc $c25
		# FIXME: fetch status and cause
		cgetcause $a1		# a1 = CapCause
		daddiu	$a2, $a2, 1	# a2 = trap count
		dmfc0 	$a3, $13	# a3 = Cause
		# create compressed info for testing purposes in $a4+$v0 (clobbering $k0)
		collect_compressed_trap_info compressed_info_reg=$a4
		dla	$k0, finally
		cgetdefault $c27
		csetoffset $c27, $c27, $k0
		csetepcc $c27
		dmtc0	$k0, $14
		DO_ERET
END_CUSTOM_TRAP_HANDLER
