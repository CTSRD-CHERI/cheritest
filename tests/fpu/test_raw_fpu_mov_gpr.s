#-
# Copyright (c) 2013-2013 Ben Thorner, Colin Rothwell
# All rights reserved.
#
# This software was developed by Ben Thorner as part of his summer internship
# and Colin Rothwell as part of his final year undergraduate project.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
.set mips64
.set noreorder
.set nobopt
.set noat

# Tests to exercise the conditional GPR move instructions.

        .text
        .global start
        .ent start
start:     
        # First enable CP1 
        dli $t1, 1 << 29
        or $at, $at, $t1    # Enable CP1    
	    mtc0 $at, $12 

        # Individual tests
        
        # MOVN.S (True)
        lui $t1, 0x4100
        mtc1 $t1, $f4
        movn.S $f3, $f4, $t1
        mfc1 $s0, $f3
        
        # MOVN.D (True)
        lui $t2, 0x4000
        dsll $t2, $t2, 32
        dmtc1 $t2, $f7
        movn.D $f3, $f7, $t2
        dmfc1 $s1, $f3
        
        # MOVN.PS (True)
        or $t0, $t1, $t2
        dmtc1 $t0, $f5
        movn.PS $f3, $f5, $t2
        dmfc1 $s2, $f3
        
        # MOVN.S (False)
        lui $t1, 0x4100
        mtc1 $t1, $f4
        dmtc1 $0, $f3
        movn.S $f3, $f4, $0
        mfc1 $s3, $f3
        
        # MOVN.D (False)
        lui $t2, 0x4000
        dsll $t2, $t2, 32
        dmtc1 $t2, $f7
        dmtc1 $0, $f3
        movn.D $f3, $f7, $0
        dmfc1 $s4, $f3
        
        # MOVN.PS (False)
        or $t0, $t1, $t2
        dmtc1 $t0, $f5
        dmtc1 $0, $f3
        movn.PS $f3, $f5, $0
        dmfc1 $s5, $f3
        
        # MOVZ.S (True)
        lui $t1, 0x4100
        mtc1 $t1, $f4
        movz.S $f3, $f4, $0
        mfc1 $s6, $f3
        
        # MOVZ.D (True)
        lui $t2, 0x4000
        dsll $t2, $t2, 32
        dmtc1 $t2, $f7
        movz.D $f3, $f7, $0
        dmfc1 $s7, $f3
        
        # MOVZ.PS (True)
        or $t0, $t1, $t2
        dmtc1 $t0, $f5
        movz.PS $f3, $f5, $0
        dmfc1 $a0, $f3
        
        # MOVZ.S (False)
        lui $t1, 0x4100
        mtc1 $t1, $f4
        dmtc1 $0, $f3
        movz.S $f3, $f4, $t1
        mfc1 $a1, $f3
        
        # MOVZ.D (False)
        lui $t2, 0x4000
        dsll $t2, $t2, 32
        dmtc1 $t2, $f7
        dmtc1 $0, $f3
        movz.D $f3, $f7, $t2
        dmfc1 $a2, $f3
        
        # MOVZ.PS (False)
        or $t0, $t1, $t2
        dmtc1 $t0, $f5
        dmtc1 $0, $f3
        movz.PS $f3, $f5, $t2
        dmfc1 $a3, $f3
        
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
        
        
