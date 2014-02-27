#-
# Copyright (c) 2014 Michael Roe
# All rights reserved.
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

#
# Test abs.s of a "Quiet Not a Number" (QNaN)
#
# In the MIPS spec, abs is what the IEEE floating point standard calls
# 'arithmetic'.
#
        .text
	.global start
        .ent start
start:     
	mfc0 $t0, $12
        li $t1, 1 << 29		# Enable CP1
        or $t0, $t0, $t1    
	mtc0 $t0, $12 
        nop
        nop
        nop

	lui $t0, 0xff90		# QNaN, with the sign bit set
	mtc1 $t0, $f1

	abs.s $f1, $f1
	mfc1 $a0, $f1

        cfc1 $a1, $31           # FCSR
        dsrl $a1, $a1, 19       # ABS2008 bit. 1 if abs behaves as in 
        andi $a1, 0x01          # IEEE 754-2008, 0 for legacy MIPS.

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