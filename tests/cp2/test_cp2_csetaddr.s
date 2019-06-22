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

.include "macros.s"
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test CSetAddr in some basic cases
#

BEGIN_TEST

		cgetdefault $c1

		# Test 1.1: Near 0
		dli $t0, 0x123
		csetaddr $c2, $c1, $t0

		# Test 1.2: Near top
		dsub $t1, $zero, $t0
		csetaddr $c3, $c1, $t1

		# Test 1.3: Near the top of a CheriBSD process
		dli $t1, 0x7fff02403e
		csetaddr $c4, $c1, $t1

		# c5 through c7, inclusive, are still available

		# Test 2.0, derive a restricted capability and try again
		dli $t0, 0x80000
		cincoffset $c8, $c1, $t0
		csetbounds $c8, $c8, $t0

		# Test 2.1: take the address just out of bounds below
		dsubi $t1, $t0, 1
		csetaddr $c9, $c8, $t1

		# Test 2.2: take the address just above the base
		daddi $t1, $t0, 1
		csetaddr $c10, $c8, $t1

		# Test 2.3: take the address just out of bounds above
		dadd $t1, $t1, $t0
		csetaddr $c11, $c8, $t1

		# Test 2.4: take the address just below the limit
		dsubi $t1, $t1, 2
		csetaddr $c12, $c8, $t1

		# c13 and up are still available
		

END_TEST
