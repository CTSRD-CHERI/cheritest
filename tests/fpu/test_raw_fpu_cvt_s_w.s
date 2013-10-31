#-
# Copyright (c) 2012 Ben Thorner
# Copyright (c) 2013 Colin Rothwell
# Copyright (c) 2013 Michael Roe
# All rights reserved.
#
# This software was developed by Ben Thorner as part of his summer internship
# and Colin Rothwell as part of his final year undergraduate project.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
# ("CTSRD"), as part of the DARPA CRASH research programme.
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

        li $t0, 1
        mtc1 $t0, $f0
        cvt.s.w $f0, $f0
        mfc1 $a0, $f0

        li $t0, 33558633 # 2 ^ 25 + 4201 - can't maintain precision
        mtc1 $t0, $f1
        cvt.s.w $f1, $f1
        mfc1 $a1, $f1

        li $t0, -23
        mtc1 $t0, $f2
        cvt.s.w $f2, $f2
        mfc1 $a2, $f2

	li $t0, 0
	mtc1 $t0, $f2
        cvt.s.w $f2, $f2
        mfc1 $a3, $f2

        # Dump reigsters and terminate
        mtc0 $at, $26
        nop
        nop
        
        mtc0 $at, $23

end:
        b end
        nop
        .end start
