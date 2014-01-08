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
# Test for pipeline hazard when a floating point compare is immediately
# followed by movt.s.
#
        .text
        .global start
        .ent start
start:     
	mfc0 $t0, $12
        lui $t1, 0x2000		# Enable CP1
        or $t0, $t0, $t1    
	mtc0 $t0, $12 
        nop
        nop
        nop

        
	li $a0, 0

	li $t0, 0 		# 0.0
	mtc1 $t0, $f10

	lui $t0, 0x3f80 	# 1.0
	mtc1 $t0, $f12

	lui $t0, 0x4000		# 2.0	
	mtc1 $t0, $f14

	c.eq.s $f14, $f12
	nop
	nop
	nop
	c.eq.s $f12, $f12
	movt.s $f10, $f12, $fcc0

	nop
	nop
	nop

	mfc1 $a0, $f10

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
