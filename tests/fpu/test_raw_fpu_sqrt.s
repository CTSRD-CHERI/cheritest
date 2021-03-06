#-
# Copyright (c) 2012 Ben Thorner
# Copyright (c) 2013 Colin Rothwell
# All rights reserved.
#
# This software was developed by Ben Thorner as part of his summer internship
# and Colin Rothwell as part of his final year undergraduate project.
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

.set mips64
.set noreorder
.set nobopt
.set noat
.include "macros.s"
#
# Tests to exercise the square root ALU instruction.
#

		.text
		.global start
		.ent start
start:     
		# First enable CP1 
		mfc0 $at, $12
		dli $t1, 1 << 29	# Enable CP1
		or $at, $at, $t1
		dli $t1, 1 << 26        # Put FPU into 64 bit mode
		or $at, $at, $t1
		mtc0 $at, $12 
		nop
		nop
		nop 
		# Individual tests
		# START TEST
       
		# SQRT.S
		lui $t0, 0x4280     # 64.0
		mtc1 $t0, $f17
		sqrt.S $f17, $f17
		mfc1 $s0, $f17
		
		# SQRT.D
		# Loading 464.912
		add $s1, $0, $0
		ori $s1, $s1, 0x407D
		dsll $s1, $s1, 16
		ori $s1, $s1, 0x0E97
		dsll $s1, $s1, 16
		ori $s1, $s1, 0x8D4F
		dsll $s1, $s1, 16
		ori $s1, $s1, 0xDF3B
		dmtc1 $s1, $f0
		# Performing operation
		sqrt.d $f0, $f0
		dmfc1 $s1, $f0

		# SQRT.D (QNaN
		lui $t2, 0x7FF1
		dsll $t2, $t2, 32   # QNaN
		dmtc1 $t2, $f13
		sqrt.D $f13, $f13
		dmfc1 $s3, $f13

		# END TEST
 
		# Dump registers on the simulator (gxemul dumps regs on exit)
		mtc0 $at, $26
		nop
		nop

		# Terminate the simulator
		mtc0 $at, $23
end:
		b end
		nop
		.end start
