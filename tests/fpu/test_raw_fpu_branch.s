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

# Tests to ensure branching works as expected

        .text
        .global start
        .ent start
start:     
        # First enable CP1 
        dli $t1, 1 << 29
        or $at, $at, $t1   # Enable CP1    
	    mtc0    $at, $12 
        nop
        nop
        nop
        nop

        li $t0, 1
        ctc1 $t0, $f25 # Set cc[0]=1
        bc1t branch_taken
        nop # branch delay slot
        b end_test

branch_taken:
        li $s4, 0x0FEEDBED

        # Individual tests
        
        # BC1F (Taken)
        ctc1 $0, $f31
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
        ctc1 $t0, $f31
        
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
