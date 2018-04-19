#-
# Copyright (c) 2018 Michael Roe
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer
# Laboratory as part of the Rigorous Engineering of Mainstream Systems (REMS)
# project, funded by EPSRC grant EP/K008528/1.
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
# Short block comment describing the test: what instruction/behaviour are we
# investigating; what properties are we testing, what properties are deferred
# to other tests?  What might we want to test as well in the future?
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		dli	$a0, 0
		dli	$a1, 2
		dli	$a2, 0
		dli	$a3, 2

		#
		# $c1 contains a capability for the array 'data'
		#

		cgetdefault $c1
		dla	$t0, data
		csetoffset $c1, $c1, $t0
		dli	$t0, 8
		csetbounds $c1, $c1, $t0

		#
		# Clear the tag on $c1, as would happen if it was saved to
		# disk and restored
		#

		ccleartag $c2, $c1

		#
		# Read the otype of the untagged capability in $c2.
		# This should be -1, as $c1 wasn't sealed.
		#

		cgetdefault $c3
		ccopytype $c3, $c3, $c2

		#
		# Find out what the otype was
		#

		cgetoffset $a0, $c3
		cgettag    $a1, $c3

		#
		# Put a capbility we can seal (even with compression) in $c1
		#

		cgetdefault $c1
		dli	$t0, 0x9800001234567000
		csetoffset $c1, $c1, $t0
		dli	$t0, 0x10000
		csetbounds $c1, $c1, $t0

		#
		# Seal $c1 with an otype of 1, putting the result in $c3
		#

		cgetdefault $c2
		dli	$t0, 1
		csetoffset $c2, $c2, $t0

		cseal	$c3, $c1, $c2

		#
		# ... and clear the tag to simulate save/restore from disk
		#

		ccleartag $c3, $c3

		#
		# Read the otype of the untagged capability in $c3
		#

		cgetdefault $c4
		ccopytype $c4, $c4, $c3

		#
		# Find out what the otype was
		#

		cgetoffset $a2, $c4
		cgettag $a3, $c4

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

		.data
data:		.dword 0
