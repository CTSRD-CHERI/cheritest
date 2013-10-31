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

# Test conversion from single to word works in the coprocessor
    
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

        # Loading 1
        li $s0, 0x3F800000
        mtc1 $s0, $f0
        # Performing operation
        trunc.w.s $f0, $f0
        mfc1 $s0, $f0

        # Loading -1
        li $s1, 0xBF800000
        mtc1 $s1, $f0
        # Performing operation
        trunc.w.s $f0, $f0
        mfc1 $s1, $f0

        # Loading 1073741824 = 2^30
        li $s2, 0x4E800000
        mtc1 $s2, $f0
        # Performing operation
        trunc.w.s $f0, $f0
        mfc1 $s2, $f0

        # Loading 107.325
        li $s3, 0x42D6A666
        mtc1 $s3, $f0
        # Performing operation
        trunc.w.s $f0, $f0
        mfc1 $s3, $f0

        # Loading 6.66
        li $s4, 0x40D51EB8
        mtc1 $s4, $f0
        # Performing operation
        trunc.w.s $f0, $f0
        mfc1 $s4, $f0

        # END TEST

# Dump registers and terminate
        mtc0 $at, $26
        nop
        nop
        
        mtc0 $at, $23

end:
        b end
        nop
        .end start


