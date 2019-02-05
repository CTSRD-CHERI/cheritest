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

.include "statcounters_macros.s"
.include "macros.s"


BEGIN_TEST

	# Set hwrena so that all statcounters are accessible in userspace
	li $2, (1 << 8) | (1 << 9) | (1 << 10) | (1 << 11) | (1 << 12) | (1 << 13) | (1 << 14)
	dmtc0	$2, $7
	jump_to_usermode userspace_test
END_TEST

#
.balign 4096
.ent userspace_test
userspace_test:

	# Read all statcounters in usermode:

	getstatcounter 6, ICACHE, WRITE_HIT
	getstatcounter 6, ICACHE, WRITE_MISS
	getstatcounter 6, ICACHE, READ_HIT
	getstatcounter 6, ICACHE, READ_MISS
	getstatcounter 6, ICACHE, PFTCH_HIT
	getstatcounter 6, ICACHE, PFTCH_MISS
	getstatcounter 6, ICACHE, EVICT
	getstatcounter 6, ICACHE, PFTCH_EVICT

	getstatcounter 6, DCACHE, WRITE_HIT
	getstatcounter 6, DCACHE, WRITE_MISS
	getstatcounter 6, DCACHE, READ_HIT
	getstatcounter 6, DCACHE, READ_MISS
	getstatcounter 6, DCACHE, PFTCH_HIT
	getstatcounter 6, DCACHE, PFTCH_MISS
	getstatcounter 6, DCACHE, EVICT
	getstatcounter 6, DCACHE, PFTCH_EVICT

	getstatcounter 6, L2CACHE, WRITE_HIT
	getstatcounter 6, L2CACHE, WRITE_MISS
	getstatcounter 6, L2CACHE, READ_HIT
	getstatcounter 6, L2CACHE, READ_MISS*2
	getstatcounter 6, L2CACHE, PFTCH_HIT
	getstatcounter 6, L2CACHE, PFTCH_MISS
	getstatcounter 6, L2CACHE, EVICT
	getstatcounter 6, L2CACHE, PFTCH_EVICT

	getstatcounter 6, MIPSMEM, BYTE_READ
	getstatcounter 6, MIPSMEM, BYTE_WRITE
	getstatcounter 6, MIPSMEM, HWORD_READ
	getstatcounter 6, MIPSMEM, HWORD_WRITE
	getstatcounter 6, MIPSMEM, WORD_READ
	getstatcounter 6, MIPSMEM, WORD_WRITE
	getstatcounter 6, MIPSMEM, DWORD_READ
	getstatcounter 6, MIPSMEM, DWORD_WRITE
	getstatcounter 6, MIPSMEM, CAP_READ
	getstatcounter 6, MIPSMEM, CAP_WRITE

	getstatcounter 6, TAGCACHE, WRITE_HIT
	getstatcounter 6, TAGCACHE, WRITE_MISS
	getstatcounter 6, TAGCACHE, READ_HIT
	getstatcounter 6, TAGCACHE, READ_MISS
	getstatcounter 6, TAGCACHE, PFTCH_HIT
	getstatcounter 6, TAGCACHE, PFTCH_MISS
	getstatcounter 6, TAGCACHE, EVICT
	getstatcounter 6, TAGCACHE, PFTCH_EVICT

	getstatcounter 6, L2CACHEMASTER, READ_REQ
	getstatcounter 6, L2CACHEMASTER, WRITE_REQ
	getstatcounter 6, L2CACHEMASTER, WRITE_REQ_FLIT
	getstatcounter 6, L2CACHEMASTER, READ_RSP
	getstatcounter 6, L2CACHEMASTER, READ_RSP_FLIT
	getstatcounter 6, L2CACHEMASTER, WRITE_RSP

	getstatcounter 6, TAGCACHEMASTER, READ_REQ
	getstatcounter 6, TAGCACHEMASTER, WRITE_REQ
	getstatcounter 6, TAGCACHEMASTER, WRITE_REQ_FLIT
	getstatcounter 6, TAGCACHEMASTER, READ_RSP
	getstatcounter 6, TAGCACHEMASTER, READ_RSP_FLIT
	getstatcounter 6, TAGCACHEMASTER, WRITE_RSP

	# Trigger a syscall to exit the test
	EXIT_TEST_WITH_COUNTING_CHERI_TRAP_HANDLER
.end userspace_test
