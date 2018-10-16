#-
# Copyright (c) 2018 Alexandre Joannou
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

# Check that swr doesn't clear two tag bigs

BEGIN_TEST
		# store two valid caps
		cgetdefault $c2
		dla	$s0, cap_after_page - (CAP_SIZE/8)	# first cap address
		csetoffset $c3, $c2, $s0
		# store one cap just before the page
		csc	$c2, $zero, 0($c3)
		dli	$t0, CAP_SIZE
		cincoffset $c4, $c3, $t0
		# and one cap just after the page
		csc	$c2, $zero, 0($c4)


		cgetaddr	$s1, $c3	# second cap address
		# load both caps for comparison
		clc	$c6, $zero, 0($c3)
		clc	$c7, $zero, 0($c4)

		# expected to work
		move	$k1, $zero
		dli	$a0, 0xffffaaaabbbbcccc
		swr	$a0, (CAP_SIZE/8) - 3($s0)	# should clear first cap tag bit but not second

		# load both caps for comparison after swr (first should be cleared, second not
		clc	$c8, $zero, 0($c3)
		clc	$c9, $zero, 0($c4)


		# also check sdr:
		csc	$c2, $zero, 0($c3)
		csc	$c2, $zero, 0($c4)
		dli	$a0, 0xffffaaaabbbbcccc
		sdr	$a0, (CAP_SIZE/8) - 5($s0)	# should clear first cap tag bit but not second
		# load both caps for comparison after sdr (first should be cleared, second not)
		clc	$c10, $zero, 0($c3)
		clc	$c11, $zero, 0($c4)


		# and the left variants (swl)
		csc	$c2, $zero, 0($c3)
		csc	$c2, $zero, 0($c4)
		dli	$a0, 0xffffaaaabbbbcccc
		swl	$a0, (CAP_SIZE/8) - 3($s0)	# should clear first cap tag bit but not second
		# load both caps for comparison after sdr (first should be cleared, second not)
		clc	$c12, $zero, 0($c3)
		clc	$c13, $zero, 0($c4)

		# and the left variants (sdl)
		csc	$c2, $zero, 0($c3)
		csc	$c2, $zero, 0($c4)
		dli	$a0, 0xffffaaaabbbbcccc
		sdl	$a0, (CAP_SIZE/8) - 5($s0)	# should clear first cap tag bit but not second
		# load both caps for comparison after sdr (first should be cleared, second not)
		clc	$c14, $zero, 0($c3)
		clc	$c15, $zero, 0($c4)

END_TEST


		.data
# Make the data cross a page boundary
		.balign 4096
cap_after_page:
		.chericap 0x123
