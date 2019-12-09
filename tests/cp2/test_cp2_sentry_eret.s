#-
# Copyright (c) 2019 Alex Richardson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory (Department of Computer Science and
# Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
# DARPA SSITH research programme.
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
.set noreorder

# Check that using ERET with a sentry in EPCC unseals the sentry
# This behaviour is useful to allow userspace to install sentry capabilities for
# signal handlers, etc.
BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER
	cgetnull $c3
	# create a code capability ($c7) and seal it ($c1) using the new CSealEntry instruction
	cap_from_label	$c11, label=eret_target
	csealentry $c12, $c11
	csetepcc $c12
	cgetepcc $c1	# should still be selead after getepcc
	DO_ERET
eret_target:
	cgetpcc $c2
exit_test:
	nop
END_TEST

BEGIN_CUSTOM_TRAP_HANDLER
	# Avoid inifinite loop where the eret (incorrectly) causes a trap. The
	# default trap handler will attempt to set EPC, which modifies EPCC and
	# will de-tag it if it is a sentry -> Another trap due to tag violation.
	cgetepcc $c3	# get epcc in trap handler
	collect_compressed_trap_info
	cap_from_label	$c9, label=exit_test
	cjr $c9
	nop
END_CUSTOM_TRAP_HANDLER
