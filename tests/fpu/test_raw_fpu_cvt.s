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

# Test conversion works in the coprocessor
    
        .text
        .global start
        .ent start

start:
        # Enable CP1
        dli $t1, 1 << 29
        or $at, $at, $t1
        mtc0 $at, $12
        nop
        nop
        nop
        nop

        # START TEST

        # Convert to single from word
        li $t0, 1
        mtc1 $t0, $f0
        cvt.s.w $f0, $f0
        mfc1 $t0, $f0

        li $t1, 33558633 # 2 ^ 25 + 4201 - can't maintain precision
        mtc1 $t1, $f1
        cvt.s.w $f1, $f1
        mfc1 $t1, $f1

        li $t2, -23
        mtc1 $t2, $f2
        cvt.s.w $f2, $f2
        mfc1 $t2, $f2

        # Convert to single from double

        li $s0, 0x3FF00000 # 1
        dsll $s0, $s0, 32
        dmtc1 $s0, $f3
        cvt.s.d $f3, $f3
        mfc1 $s0, $f3

        li $s1, 0x3FC55555 # ~ 1/6
        dsll $s1, $s1, 32 # shift top bits to correct place
        li $t3, 0x55555555 # load bottom bits
        or $s1, $s1, $t3
        dmtc1 $s1, $f4
        cvt.s.d $f4, $f4
        mfc1 $s1, $f4

        li $s2, 0xC06D5431 # -234.6311
        dsll $s2, $s2, 32
        li $t3, 0xF8A0902E
        and $s2, $s2, $t3 # and because it's sign extended
        dmtc1 $s2, $f5
        cvt.s.d $f5, $f5
        mfc1 $s2, $f5

        li $s3, 0x41E1808E # large number
        dsll $s3, $s3, 32
        li $t3, 0x6C666666
        or $s3, $s3, $t3
        dmtc1 $s3, $f6
        cvt.s.d $f6, $f6
        mfc1 $s3, $f6

        # Convert to double from single

        li $s4, 0x3F800000 # 1
        mtc1 $s4, $f7
        cvt.d.s $f7, $f7
        dmfc1 $s4, $f7

        li $s5, 0x3E4CCCCD # 0.2
        mtc1 $s5, $f8
        cvt.d.s $f8, $f8
        dmfc1 $s5, $f8

        li $s6, 0xC68EE746 # -18291.636
        mtc1 $s6, $f9
        cvt.d.s $f9, $f9
        dmfc1 $s6, $f9

        cfc1 $s7, $f31          # Get floating point rounding mode

       # END TEST

        # Dump reigsters and terminate
        mtc0 $at, $26
        nop
        nop
        
        mtc0 $at, $23

end:
        b end
        nop
        .end start
