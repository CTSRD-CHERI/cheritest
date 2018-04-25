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
# Test that the capability cursor is bytes 8-15 in memory for all implementations.
# Clang will always emit an untagged __intcap_t value in this way so all C
# code that uses globals depends on this representation.
#

BEGIN_TEST
		#
		# Set up $c1 to point at data.
		# We want $c1.length to be 8.
		#
		cgetdefault $c1
		dla	$t0, cap_buffer
		csetoffset $c1, $c1, $t0
		dli	$s0, (CAP_SIZE / 8)
		csetbounds $c1, $c1, $s0

		# Load __intcap_t clc:
		clc	$c3, $zero, 0($c1)
		# Get the
		cgetoffset	$a0, $c3

		# now load the raw bytes into a1-a4
		cld	$a1, $zero, 0($c1)
.if CAP_SIZE > 8
		cld	$a2, $zero, 8($c1)
.endif
.if CAP_SIZE > 16
		cld	$a3, $zero, 16($c1)
		cld	$a4, $zero, 24($c1)
.endif

		# check that storing int __intcap_t value and loading it back works
		CFromIntImm $c4, 0x1234
		csc	$c4, $zero, 0($c1)
		clc	$c5, $zero, 0($c1)

		# Check that cllc+cscc also work
		CFromIntImm $c7, 0x5678
		cllc 	$c6, $c1	# start a ll so the sc succeeds
		cscc	$s1, $c7, $c1
		cllc	$c8, $c1	# load back again using ll
END_TEST

		.data
		.balign (CAP_SIZE / 8)	# ensure this is a valid target for clc
cap_buffer:
# FIXME: once we drop binutils we could just use .chericap 42 here...
.if CAP_SIZE < 16
.error "This test probably needs adjusting for CHERI64"
		.8byte 42	# FIXME: is this correct?
.else
		.8byte 0	# compressed info (128)/ permissions (256)
		.8byte 42	# untagged __intcap_t 42 cursor
.endif
.if CAP_SIZE > 16
		.8byte 0
		.8byte 0
.endif


