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

# Tests to exercise the comparison (unordered or less than or equal) ALU instructions.

        .text
        .global start
        .ent start
start:     
        # First enable CP1 
        dli $t1, 1 << 29
        or $at, $at, $t1    # Enable CP1    
	    mtc0 $at, $12 
        nop
        nop
        nop
        nop
        nop
    
	    # Setup parameters
	    
	    mtc1 $0, $f31
        lui $t0, 0x4000     # 2.0
        mtc1 $t0, $f3
        lui $t0, 0x3F80     # 1.0
        mtc1 $t0, $f4
        lui $t0, 0x4000     
        dsll $t0, $t0, 32
        dmtc1 $t0, $f13
        ori $t1, $0, 0x3F80
        dsll $t1, $t1, 16
        or $t0, $t0, $t1    # 2.0, 1.0
        dmtc1 $t0, $f23
        lui $t0, 0x3FF0
        dsll $t0, $t0, 32
        dmtc1 $t0, $f14
        ori $t1, $0, 0x4000
        dsll $t1, $t1, 16
        or $t0, $t0, $t1    # 1.0, 2.0
        dmtc1 $t0, $f24

        # Individual tests
        
        # C.ULE.S (True)
        c.ule.S $f3, $f3
        cfc1 $s0, $f25
        
        # C.ULE.D (True)
        c.ule.D $f13, $f13
        cfc1 $s1, $f25
        
        # C.ULE.PS (True)
        c.ule.PS $f23, $f23
        cfc1 $s2, $f25
        ctc1 $0, $f31
        
        # C.ULE.S (False)
        c.ule.S $f3, $f4
        cfc1 $s3, $f25
        
        # C.ULE.D (False)
        c.ule.D $f13, $f14
        cfc1 $s4, $f25
        
        # C.ULE.PS
        c.ule.PS $f24, $f23
        cfc1 $s5, $f25
        ctc1 $0, $f31
        
        # C.ULE.S (True)
        c.ule.S $f4, $f3
        cfc1 $s6, $f25
        
        # C.ULE.D (True)
        c.ule.D $f14, $f13
        cfc1 $s7, $f25
        
        # C.ULE.PS
        c.ule.PS $f23, $f24
        cfc1 $a0, $f25
        ctc1 $0, $f31
        
        # C.ULE.S (QNaN)
        lui $t0, 0x7F81
        mtc1 $t0, $f5
        c.ule.S $f3, $f5
        cfc1 $a1, $f25
        
        # C.ULE.D (QNaN)
        lui $t0, 0x7FF1
        dsll $t0, $t0, 32
        dmtc1 $t0, $f15
        c.ule.D $f15, $f15
        cfc1 $a2, $f25
        
        # C.ULE.PS (QNaN)
        c.ule.PS $f5, $f5
        cfc1 $a3, $f25
        
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
