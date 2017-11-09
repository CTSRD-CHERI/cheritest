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


// Compile this as two separate objects so the compiler can't inline the results
#ifdef COMPILE_SWITCH_FN
int switch_test(int arg) {
	// Pick some random numbers and lots of cases so that the compiler
	// actually generates a jump table
	switch(arg) {
	case 1: return 31;
	case 3: return 0x1234;
	case 4: return 44;
	case 5: return 5010;
	case 7: return 7777;
	default: return 0;
	}
}
#else
extern int switch_test(int arg);
int test(void)
{
	assert_eq(switch_test(-1), 0);
	assert_eq(switch_test(0), 0);
	assert_eq(switch_test(1), 31);
	assert_eq(switch_test(2), 0);
	assert_eq(switch_test(3), 0x1234);
	assert_eq(switch_test(4), 44);
	assert_eq(switch_test(5), 5010);
	assert_eq(switch_test(6), 0);
	assert_eq(switch_test(7), 7777);
	assert_eq(switch_test(8), 0);
	return 0;
}
#endif
