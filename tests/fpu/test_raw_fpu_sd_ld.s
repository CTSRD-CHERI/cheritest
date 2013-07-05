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

        dla $t0, preload
        ldc1 $f0, 0($t0)
        dmfc1 $s0, $f0

        dla $t0, loc1
        lui $t1, 0xBED0
        dsll $t1, 32
        dmtc1 $t1, $f0
        sdc1 $f0, 0($t0)
        ldc1 $f1, 0($t0)
        dmfc1 $s1, $f1
        lui $t1, 0x1212
        dsll $t1, 32
        dmtc1 $t1, $f0
        sdc1 $f0, 8($t0)
        ldc1 $f2, 8($t0)
        dmfc1 $s2, $f2

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
preload:    .dword   0x0123456789abcdef
loc1:       .dword   0x0000000000000000
loc2:       .dword   0x0000000000000000
