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

.include "macros.s"
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Macro test that checks whether we can save and restore the complete
# capability register file.  All loads and stores are performed via $c30
# ($kdc).  This replicates the work an operating system would perform in
# order to ensure that an OS would work!
#
BEGIN_TEST
		# make $c30/kdc a full address-space capability (will be null on CPU reset)
		cgetdefault $c30
		# Ensure all capability registers are set to the default.
		cgetdefault		$c1
		cgetdefault		$c2
		cgetdefault		$c3
		cgetdefault		$c4
		cgetdefault		$c5
		cgetdefault		$c6
		cgetdefault		$c7
		cgetdefault		$c8
		cgetdefault		$c9
		cgetdefault		$c10
		cgetdefault		$c11
		cgetdefault		$c12
		cgetdefault		$c13
		cgetdefault		$c14
		cgetdefault		$c15
		cgetdefault		$c16
		cgetdefault		$c17
		cgetdefault		$c18
		cgetdefault		$c19
		cgetdefault		$c20
		cgetdefault		$c21
		cgetdefault		$c22
		cgetdefault		$c23
		cgetdefault		$c24
		cgetdefault		$c25
		cgetdefault		$c26
		cgetdefault		$c27
		cgetdefault		$c28
		cgetdefault		$c29
		# make EPCC full addr space too:
		csetepcc		$c29
		#
		# Save out all capability registers but $kcc and $kdc.
		#
		dla	$t0, data

		daddiu	$t0, $t0, 32
		csc 	$c1, $t0, 0($c30)

		# now that $c1 has been saved use it to save $ddc
		cgetdefault $c1
		csc 	$c1, $t0, -32($c30)

		daddiu	$t0, $t0, 32
		csc 	$c2, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c3, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c4, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c5, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c6, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c7, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c8, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c9, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c10, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c11, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c12, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c13, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c14, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c15, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c16, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c17, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c18, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c19, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c20, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c21, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c22, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c23, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c24, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c25, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c26, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c27, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		cgetepcc $c27
		csc 	$c27, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		csc 	$c28, $t0, 0($c30)


		#
		# Now reverse the process.
		#
		dla	$t0, data
		clc 	$c1, $t0, 0($c30)
		csetdefault $c1

		daddiu	$t0, $t0, 32
		clc 	$c1, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c2, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c3, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c4, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c5, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c6, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c7, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c8, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c9, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c10, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c11, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c12, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c13, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c14, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c15, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c16, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c17, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c18, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c19, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c20, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c21, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c22, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c23, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c24, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c25, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c26, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c27, $t0, 0($c30)

		daddiu	$t0, $t0, 32
		clc 	$c28, $t0, 0($c30)
		csetepcc $c28

		daddiu	$t0, $t0, 32
		clc 	$c28, $t0, 0($c30)

END_TEST

		#
		# 32-byte aligned storage for 30 adjacent capability
		# registers.
		#
		.data
		.align 5
data:		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c0
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c1
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c2
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c3
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c4
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c5
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c6
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c7
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c8
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c9
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c10
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c11
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c12
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c13
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c14
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c15
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c16
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c17
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c18
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c19
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c20
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c21
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c22
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c23
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c24
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c25
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c26
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c27
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# epcc
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c28
		.dword	0x0011223344556677, 0x8899aabbccddeeff
