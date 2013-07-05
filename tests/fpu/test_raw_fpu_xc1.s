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


        # BEGIN TESTS
        dla $t0, word1
        dla $t1, double1
        li $t2, 4 # word single offset
        li $t3, 8 # double single offset

        lui $a0, 0xABCD
        lui $a1, 0x4321
        mtc1 $a0, $f0
        mtc1 $a1, $f1
        swxc1 $f0, $0($t0)
        swxc1 $f1, $t2($t0)
        lwxc1 $f2, $0($t0)
        lwxc1 $f3, $t2($t0)
        mfc1 $s0, $f2
        mfc1 $s1, $f3

        lui $a0, 0xFEED
        dsll $a0, $a0, 32
        lui $a1, 0xFACE
        dsll $a1, $a1, 16 
        dmtc1 $a0, $f0
        dmtc1 $a1, $f1
        sdxc1 $f0, $0($t1)
        sdxc1 $f1, $t3($t1)
        ldxc1 $f2, $0($t1)
        ldxc1 $f3, $t3($t1)
        dmfc1 $s2, $f2
        dmfc1 $s3, $f3
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
word1:      .word   0x00000000
word2:      .word   0x00000000
double1:    .dword  0x0000000000000000
double2:    .dword  0x0000000000000000
