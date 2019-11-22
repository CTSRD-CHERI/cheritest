#-
# Copyright (c) 2014 Michael Roe
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

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"
#
# Test that jalr raises an exception if the destination is not aligned.
#

BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER
		dli	$a0, 0
		dli	$a1, 0	# $ra set by jalr
		dli	$a2, 0	# should be one at end
		dli	$a3, 0	# addr of subroutine + 1
		dli	$a4, 0	# BadVADDR
		dli	$a5, 0	# EPC
		dli	$a6, 0	# should zero one at end
		dli	$a7, 0	# should be one at end


		dla	$a3, subroutine
		daddi	$a3, $a3, 1
		# Note: this should not switch to microMIPS mode!
		dli $s1, 0
		dli $ra, 0x12345
		clear_counting_exception_handler_regs
		jalr $a3	# This should raise an exception
		nop		# branch delay slot
exit:
		dli $a2, 1
END_TEST

BEGIN_CUSTOM_TRAP_HANDLER
		# Save the information on the trap handler in $k1 and trap count in $v0
		collect_compressed_trap_info
		dmfc0	$a0, $13	# CP0.Cause
		dmfc0	$a4, $8		# BadVAddr
		dmfc0	$a5, $14	# EPC
		# load ~3
		dli	$t0, 3
		not	$t0
		daddiu	$t1, $a5, 4	# EPC += 4 to bump PC forward on ERET
		and	$t1, $t1, $t0	# clear low bits
		dmtc0	$t1, $14
		DO_ERET
END_CUSTOM_TRAP_HANDLER

		.balign 32
		.ent subroutine
subroutine:
		dli $a6, 1	# this one should be skipped
		dli $a7, 1	# But not this one
		move $a1, $ra
		move $s1, $k1
		clear_counting_exception_handler_regs

		dla	$s2, exit
		jr	$s2
		nop
		.end subroutine
