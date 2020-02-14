#-
# Copyright (c) 2019 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory (Department of Computer Science and
# Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
# DARPA SSITH research programme.
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
.set noreorder

BEGIN_TEST
		# Make $c1-4 differemt from $pcc
		cgetnull $c1
		cgetnull $c2
		cgetnull $c3
		cgetnull $c4
		dla $s0, .Lfirst_getpcc
		dla $s1, .Lsecond_getpcc
		dla $s2, .Lthird_getpcc
		dla $s3, .Lfourth_getpcc

.Lfirst_getpcc:
		cgetpccincoffset $c1, $zero  # equivalent to getpcc

		b .Lcontinue
.Lsecond_getpcc:
		cgetpccincoffset $c2, $zero # equivalent to getpcc in brach delay slot
.Lcontinue:
		ori $4, $zero, 1
.Lthird_getpcc:
		cgetpccincoffset $c3, $4

		b .Lcontinue2
.Lfourth_getpcc:
		cgetpccincoffset $c4, $4  # branch delay slot
.Lcontinue2:
		# Create an a $pcc with a nonzero base and try cgetpccincoffset
		cap_from_label $c12, .Lnonzero_base, tmpgpr=$s5
		cap_from_label $c17, .Lend_test
		li $5, -1
		li $6, 0x10000000	# large enough to make it unrepresentable
		csetbounds $c12, $c12, 116	# create a restricted sandbox
		cincoffset $c12, $c12, 100	# Ensure $pcc has a non-zero offset
		cjr $c12
		nop
.Lnonzero_base:
		.space 100	# This padding should be skipped
		cgetpccincoffset $c5, $5 # getpcc and add -1
		cgetpccincoffset $c6, $6 # getpcc and add 0x10000000
		cjr	$c17  # return to .Lend_test
		nop	# delay slot
.Lend_test:
		nop
END_TEST

