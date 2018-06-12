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

.include "macros.s"
.set mips64
.set noreorder
.set nobopt
.set noat

#
# Test the initial values for the capability registers (this is a raw test
# since init.s changes various capability registers
#
.global start
.ent start
start:
	# enable cp2:
	mfc0	$at, $12
	# Enable 64-bit mode (KX, SX)
	# (no effect on cheri, but required for gxemul)
	or	$at, $at, 0xe0
	# Enable CP1 and CP2
	dli	$t1, 3 << 29
	or	$at, $at, $t1

	# TODO: this should be macro in macros.s

	# run a few some nops in case this is needed
	ssnop
	ssnop
	mtc2 $k0, $0, 6	# dump CHERI regs
	mtc0 $at, $26	# Dump MIPS registers
	nop
	nop
	mtc0 $at, $23	# Terminate the simulator
	nop
.global end
end:
	ori $0, $0, 0xdead	# stop tracing on QEMU
	b end
	daddiu $zero, $zero, 0  # load zero nop to indicate core 0
.end start

