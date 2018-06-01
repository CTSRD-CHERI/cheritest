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

# See test_cp2_x_reg0_is_ddc_common.s for the real implementation
TESTING_LOAD = 1
TESTING_STORE = 0
TESTING_LLSC = 1

.macro do_cap_load_store kind, dstreg, srcreg
	cll\()\kind \dstreg, \srcreg
.endm

.macro do_mips_load_store kind, dstreg, srcreg
	ll\()\kind \dstreg, 0(\srcreg)
.endm

.include "tests/cp2/test_cp2_x_reg0_is_ddc_common.s"
