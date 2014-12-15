#-
# Copyright (c) 2014 Michael Roe
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

#
# Test that we can read the CP0 TagLo registwr.
#
# CP0 Config1 is used to determine how many cache sets there are, then
# a loop runs through all index values in range and reads the corresponding
# tag.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		dli	$a2, 0			# Set to 1 when test completes

		#
		# Set $a0 to the number of Dcache sets per way
		# (64 * 2^$a1 gives the number of sets per way)
		#

		mfc0	$a0, $16, 1		# Config1
		srl	$a0, $a0, 13
		andi	$a0, $a0, 0x7

		#
		# Set $a1 to the L2 cache sets per waT
		#

		mfc0	$a1, $16, 2		# Config2
		srl	$a1, $a1, 8
		andi	$a1, $a1, 0xf

		#
		# Set $t0 to the number of Dcache sets per way - 1
		#

		dli	$t0, 64
		sllv	$t0, $t0, $a0
		daddi	$t0, $t0, -1
loop1:
		mtc0	$t0, $0			# Index
		cache	0x5, 0($zero)		# Index Load Tag, L1 data
		mfc0	$t1, $28		# TagLo
		daddi	$t0, $t0, -1
		bgez	$t0, loop1
		nop				# Branvh delay

		#
		# Set $t0 to the number of L2 sets per way - 1
		#

		dli	$t0, 64
		sllv	$t0, $t0, $a1
		daddi	$t0, $t0, -1
loop2:
		mtc0	$t0, $0			# Index
		cache	0x7, 0($zero)		# Index Load Tag, L2 cache
		mfc0	$t1, $28		# TagLo
		daddi	$t0, $t0, -1
		bgez	$t0, loop2
		nop				# Branvh delay


end:
		dli	$a2, 1

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
