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

        .text
        .global start
        .ent start

start:
        # Enable CP1
        dli $t1, 1 << 29
        or $t0, $t1, $t1
        mtc0 $t0, $12
        nop
        nop
        nop
        nop
        nop

        # BEGIN TESTS
        lui $s0, 0x3F80 # 1
        mtc1 $s0, $f0 # move 1 to copro
        dla $t0, positive # load the address
        swc1 $f0, 0($t0) # store 1 in the memory
        lwc1 $f0, 0($t0) # load it back out from the memory
        lwc1 $f1, 4($t0) # load it surroundings
        dla $t0, padding
        ldc1 $f2, 0($t0)
        mfc1 $s0, $f0 # move it back into s0
        mfc1 $s4, $f1
        dmfc1 $s5, $f2

        lui $s1, 0xBF80 # -1
        mtc1 $s1, $f1
        dla $t0, negative
        swc1 $f1, 0($t0)
        lwc1 $f1, 0($t0)
        mfc1 $s1, $f1

        lui $s2, 0x4180 # 16
        lui $s3, 0x3D80 # 0.0625 = 1/16
        mtc1 $s2, $f2
        mtc1 $s3, $f3
        dla $t0, loc1
        swc1 $f2, 0($t0)
        swc1 $f3, 4($t0)
        lwc1 $f2, 0($t0)
        lwc1 $f3, 4($t0)
        mfc1 $s2, $f2
        mfc1 $s3, $f3
        # END TESTS

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
        

        .data
padding:    .dword  0x2020202030303030
positive:   .dword  0xdeadbeef10101010
negative:   .word   0xdeadbeef
loc1:       .word   0xdeadbeef
loc2:       .word   0xdeadbeef
