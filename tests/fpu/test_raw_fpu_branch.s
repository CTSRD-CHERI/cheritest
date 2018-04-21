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
# Tests to ensure branching works as expected
#

		.text
		.global start
		.ent start
start:     
		# First enable CP1
		mfc0 $at, $12
		dli $t1, 1 << 29
		or $at, $at, $t1	# Enable CP1    
		mtc0 $at, $12 
		nop
		nop
		nop
		nop

		li $t0, 1
		ctc1 $t0, $25		# Set cc[0]=1
		bc1t branch_taken
		nop			# branch delay slot
		b end_test

branch_taken:
		li $s4, 0x0FEEDBED

		# Individual tests
		
		# BC1F (Taken)
		ctc1 $0, $31
		li $t2, 4
		mtc1 $t2, $f3
		li $t1, 3
		bc1f 8
		li $s0, 0
		mtc1 $t1, $f3
		mfc1 $s0, $f3
		
		# BC1T (Not Taken)
		mtc1 $t2, $f3
		bc1t 8
		li $s1, 0
		mtc1 $t1, $f3
		mfc1 $s1, $f3
		
		# Set FCSR (FCC[0] == 1)
		lui $t0, 0x0080
		ctc1 $t0, $31
		
		# BC1F (Not Taken)
		mtc1 $t2, $f4
		bc1f 8
		li $s2, 0
		mtc1 $t1, $f4
		mfc1 $s2, $f4
		
		# BC1T (Taken)
		mtc1 $t2, $f5
		bc1t 8
		li $s3, 0
		mtc1 $t1, $f5
		mfc1 $s3, $f5

end_test:
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
