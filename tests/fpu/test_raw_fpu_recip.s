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

# Tests to exercise the reciprocal square root ALU instruction.

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

        # Individual tests
        # START TEST

        # RECIP.D
        lui $t0, 0x4030
        dsll $t0, $t0, 32   # 16.0
        dmtc1 $t0, $f19
        recip.D $f19, $f19
        dmfc1 $s0, $f19
        
        # RECIP.S
        mtc1 $0, $f19       # 0.0
        recip.S $f19, $f19
        mfc1 $s1, $f19
        
        # RECIP.D (QNaN)
        lui $t2, 0x7FF1
        dsll $t2, $t2, 32   # QNaN
        dmtc1 $t2, $f13
        recip.D $f13, $f13
        dmfc1 $s3, $f13
        
        # RECIP.S (Denorm)
        lui $t0, 0x0100
        ctc1 $t0, $f31      # Enable flush to zero on denorm.
        lui $t0, 0x7F7F     # Some single greater than 2^(e_max-1)
        mtc1 $t0, $f7

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
            
        
        
