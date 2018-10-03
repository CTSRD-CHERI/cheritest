#-
# Copyright (c) 2015 Robert M. Norton
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
# Test cclear regs instruction
#

BEGIN_TEST
		# We want the inital $v0 value here and not the trap count
		dli	$v0, 0x0202020202020202 # revert the change to $v0 done by BEGIN_TEST

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
                cgetdefault		$c30
                # TODO: cgetdefault		$c31
                csetepcc		$c30

                # clear caphi16 even regs
                cclearhi	0x5555

                # Write a non-zero value to some of the cleared registers to ensure it
                # sticks.
                cgetdefault   $c18
                cgetdefault   $c22

.include        "tests/cp2/clearregs_common.s"
                
END_TEST
