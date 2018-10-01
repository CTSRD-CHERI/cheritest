#-
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

.include "macros.s"
#
# Test that overwriting the cjr jump target register does not affect the
# value of $pcc after the cjr instruction
#

BEGIN_TEST
		dli $v0, 0		# exception count == 0
		dli $a1, 0xbad		# Should be set to 1 on success
		dli $a2, 0xbad		# Should be set to 1 on success
		dli $a3, 0xbad		# Should be set to 1 on success
		dli $a4, 0xbad		# Should be set to 1 on success

		cgetpcc	$c1
		dla	$t0, return
		csetoffset $c2, $c1, $t0

		# Check that cincoffset in the delay slot works
incoffset_test:
		dla	$t0, .Lincoffset_jump_target
		csetoffset $c12, $c1, $t0	# actual jump target
		dli $t0, 4
		cjr	$c12
		cincoffset $c12, $c12, 4	# skip the ori instruction
		teq $zero, $zero	# Should not be reached

		b change_base_test
		nop
.Lincoffset_jump_target:
		ori $a1, $zero, 0x1
		b change_base_test
		nop

		# Check changing the base in the delay slot works as expected
change_base_test:
		dla	$t0, .Lchange_base_jump_target
		csetoffset $c12, $c1, $t0	# actual jump target
		dli $t0, 4
		cincoffset $c3, $c12, 4	# skip the ori instruction
		csetbounds $c3, $c3, 0	# and make zero length
		cjr	$c12
		cmove	$c12, $c3
		teq $zero, $zero	# Should not be reached

		b null_test
		nop
.Lchange_base_jump_target:
		ori $a2, $zero, 0x1
		b null_test
		nop

		# Check that setting a NULL cap in the delay slot works
null_test:
		dla	$t0, .Lnull_jump_target
		csetoffset $c12, $c1, $t0	# actual jump target
		cgetnull	$c3

		cjr	$c12
		cmove	$c12, $c3	# change $c12 to NULL in delay slot

		teq $zero, $zero	# Should not be reached
		b change_perms_test
		nop
.Lnull_jump_target:
		dli $a3, 0x1
		b change_perms_test
		nop

change_perms_test:
		# Check that cincoffset in the delay slot does works
		dla	$t0, .Lchange_perms_jump_target
		csetoffset $c12, $c1, $t0	# actual jump target
		dli	$t1, ~CHERI_PERM_LOAD_CAP
		# the resulting PCC should no longer have permit_load_cap
		candperm	$c12, $c12, $t1

		dla	$t1, .Lchange_perms_bad_target
		csetoffset	$c3, $c1, $t0	# wrong jump target (full perms)
		csetbounds	$c3, $c3, 12

		cjr	$c12
		cmove	$c12, $c11	# change $c12 to full perms+bad targetin delay slot
		teq $zero, $zero	# Should not be reached
		b finally
		nop

.Lchange_perms_jump_target:
		dli $a4, 0x1
		cgetpcc $c6
		b finally
		nop
.Lchange_perms_bad_target:
		dli $a4, 0xbad2
		cgetpcc $c6
		teq $zero, $zero	# Cause a trap to fail the test
		b finally
		nop

finally:
		cjr	$c2	# restore full address space $pcc
		nop
return:
		nop
END_TEST
