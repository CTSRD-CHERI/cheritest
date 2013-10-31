#-
# Copyright (c) 2012 Ben Thorner
# Copyright (c) 2013 Colin Rothwell
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

# Tests to exercise the multiplication ALU instruction.

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

        # Individual tests
        
        # START TEST
        # MUL.D
        lui $t3, 0x4000
        dsll $t3, $t3, 32   # 2.0
        dmtc1 $t3, $f29
        mul.D $f27, $f29, $f29
        dmfc1 $s0, $f27
 
        # MUL.S
        lui $t2, 0x4080     # 4.0
        mtc1 $t2, $f20
        mul.S $f20, $f20, $f20

        # MUL.PS (QNaN)
        lui $t2, 0x7F81
        dsll $t2, $t2, 32   # QNaN
        ori $t1, $0, 0x4000
        dsll $t1, $t1, 16   # 2.0
        or $t2, $t2, $t1
        dmtc1 $t2, $f13
        mul.PS $f13, $f13, $f13
        dmfc1 $s3, $f13
        
        # MUL.S (Denorm)
        lui $t0, 0x0100
        mtc1 $t0, $f31      # Enable flush to zero on denorm.
        lui $t1, 0x1
        dmtc1 $t1, $f22
        mul.S $f22, $f22, $f22
        dmfc1 $s4, $f22        
       dmfc1 $s1, $f20

        # Loading (3, 4.89)
        add $s2, $0, $0
        ori $s2, $s2, 0x4040
        dsll $s2, $s2, 32
        ori $s2, $s2, 0x409C
        dsll $s2, $s2, 16
        ori $s2, $s2, 0x7AE1
        dmtc1 $s2, $f0
        # Loading (4, 47.3)
        add $s2, $0, $0
        ori $s2, $s2, 0x4080
        dsll $s2, $s2, 32
        ori $s2, $s2, 0x423D
        dsll $s2, $s2, 16
        ori $s2, $s2, 0x3333
        dmtc1 $s2, $f1
        # Performing operation
        mul.ps $f0, $f0, $f1
        dmfc1 $s2, $f0
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
