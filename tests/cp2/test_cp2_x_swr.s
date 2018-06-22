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

BEGIN_TEST
		# save ddc
		cgetdefault $c2
		# prepare new restricted ddc
		cgetdefault $c1
		dla	$t0, data
		csetoffset $c1, $c1, $t0
		dli	$t1, 2
		csetbounds $c1, $c1, $t1
		csetdefault $c1
		# perform swr operations
		dli	$t1, -1

		daddiu	$a4, $t1, 0
		lb      $a4, 0($zero)

		# expected to work
		move	$k1, $zero
		daddiu	$a0, $t1, 0
		swr	$a0, 0($zero)
		move	$s0, $k1

		# expected to work
		move	$k1, $zero
		daddiu	$a1, $t1, 0
		swr	$a1, 1($zero)
		move	$s1, $k1

		# expected to throw a length exception
		move	$k1, $zero
		daddiu	$a2, $t1, 0
		swr	$a2, 2($zero)
		move	$s2, $k1

		# expected to throw a length exception
		move	$k1, $zero
		daddiu	$a3, $t1, 0
		swr	$a3, 3($zero)
		move	$s3, $k1

		# restore ddc
		csetdefault $c2
END_TEST


		.data
		.balign 16
data:		.word 0x01020304
		.word 0x01020304
