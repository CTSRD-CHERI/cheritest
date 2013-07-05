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

# Tests to exercise the pairwise merging instructions.

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
        nop

        # Individual tests
        
        # PLL.PS
        lui $t0, 0x3F80
        mtc1 $t0, $f7
        lui $t0, 0x4000
        mtc1 $t0, $f8
        pll.PS $f7, $f7, $f8
        dmfc1 $a0, $f7
        
        # PLU.PS
        lui $t0, 0xBF80
        mtc1 $t0, $f13
        lui $t0, 0x3F80
        dsll $t0, $t0, 32
        dmtc1 $t0, $f23
        plu.PS $f14, $f13, $f23
        dmfc1 $a1, $f14
        
        # PUL.PS
        lui $t0, 0x7F80
        dsll $t0, $t0, 32
        dmtc1 $t0, $f5
        mtc1 $0, $f6
        pul.PS $f5, $f5, $f6
        dmfc1 $a2, $f5
        
        # PUU.PS
        puu.PS $f5, $f5, $f23
        dmfc1 $a3, $f5
        
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
        
        
