#-
# Copyright (c) 2013 Colin Rothwell
# All rights reserved.
#
# This software was developed by Colin Rothwell as part of his summer internship
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
    
# This is a bit special. It is only meant to work when run in conjunction with
# cherictl.

.set mips64
.set noreorder
.set nobopt
.set noat

        .text
        .global start
        .ent start

start:
    # 12 should be t0: easier to confirm 12 in cherictl.
    li $12, 0 # loop while t0 hasn't been kicked externally.
poll:
    beq $12, $0, poll
    nop

    li $t1, 234 # shouldn't be traced
    add $t1, $t1, $t1
    addi $t1, $t1, 100

	li $t2, 1
	mtc0 $t2, $9, 6 # register 9, sel 6 is the "tracing enabled" register
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	add $t2, $t2, $t2 # something to trace
	add $t2, $t2, $t2 
    li $t2, 0 # set t2 to zero
	mtc0 $t2, $9, 6 # disable tracing
    nop
    nop
    addi $t2, 345 # shouldn't be traced
	ori $t2, 255 # likewise

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
