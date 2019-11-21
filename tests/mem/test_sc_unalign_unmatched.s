#-
# Copyright (c) 2011 Robert N. M. Watson
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
# Unaligned sc, firing an address exception.
#
BEGIN_TEST
		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a0, 0
		dli	$a1, 0
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0
		dli	$a6, 0
		dli	$a7, 0

		#
		# Save the desired EPC value for this exception so we can
		# check it later.
		#
		dla	$a0, desired_epc

		#
		# Trigger exception.
		#
		# The result is "unpredictable" according to the MIPS
		# specification, because there is no matching LL.
		# BERI will raise an exception due to the unaligned address.
		#
		# However:
		# The effective address must be naturally-aligned. If any of the
		# 3 least-significant bits of the address is non-zero, an
		# Address Error exception occurs.

		dla	$s0, bytes
		ld	$s1, 0($s0)	# load value before sc
desired_epc:
		li	$a7, 0x12345
		check_instruction_traps $s5, sc	$a7, -1($s0)
		daddi	$s3, $s0, -1

		#
		# Exception return.
		#
		li	$a1, 1
		# Even if the scd didn't trap (due to mismatched LL),
		# the value of the bytes should not have changed
		ld	$s2, 0($s0)
		mfc0	$a6, $12	# Status register after ERET

return:
END_TEST

		.data
		.align	5
bytes:		.dword	0x5656565656565656
		.dword	0x7878787878787878
