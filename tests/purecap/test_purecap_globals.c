/*-
 * Copyright (c) 2017 Alex Richardson
 * All rights reserved.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * @BERI_LICENSE_HEADER_START@
 *
 * Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
 * license agreements.  See the NOTICE file distributed with this work for
 * additional information regarding copyright ownership.  BERI licenses this
 * file to you under the BERI Hardware-Software License, Version 1.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at:
 *
 *   http://www.beri-open-systems.org/legal/license-1-0.txt
 *
 * Unless required by applicable law or agreed to in writing, Work distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * @BERI_LICENSE_HEADER_END@
 */
#include "../c/assert.h"

#define EXPECTED_VALUE 42

int global_int = EXPECTED_VALUE;
int* global_cap = &global_int;
int global_int2 = EXPECTED_VALUE + 1;


int test(void)
{
	assert_eq(global_int, EXPECTED_VALUE);

	int* local_cap = &global_int;
	// compare the two capabilities
	// XXXAR: not sure this will actually always be true (depends on DDC)
	assert_eq_cap(global_cap, local_cap);

	// check the tag bit
	assert(__builtin_cheri_tag_get(local_cap));
	assert(__builtin_cheri_tag_get(global_cap));
	// Check virtual address makes sense
	assert((vaddr_t)local_cap != 0);
	assert((vaddr_t)global_cap != 0);
	assert_eq((vaddr_t)local_cap, (vaddr_t)global_cap);



	// actually load the values and compare
	assert_eq(*local_cap, EXPECTED_VALUE);
	assert_eq(*global_cap, EXPECTED_VALUE);

	// Check that we load the correct value also for the second/third global
	assert_eq(global_int2, EXPECTED_VALUE + 1);


	return 0;
}
