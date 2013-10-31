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

        .text
        .global start
        .ent start

start:
        # Enable CP1
	mfc0 $t0, $12
        dli $t1, 1 << 29
        or $t0, $t0, $t1
        mtc0 $t0, $12
        nop
        nop
        nop
        nop
        nop

        # BEGIN TESTS

	#
	# Write 1.0 to memory; check that we get the same value when we
	# read it back, and the memory locations before and after it have
	# not be overwritten.
	#

        lui $s0, 0x3F80 	# 1.0
        mtc1 $s0, $f0
        dla $t0, variable 	# Address to store the value at
        swc1 $f0, 0($t0)	# store 1 in memory
        lwc1 $f0, 0($t0)	# load it back out from the memory
        mfc1 $s1, $f0		# Should be 1.0
	dli  $t1, 4
	dadd $t0, $t0, $t1
        lwc1 $f1, 0($t0)	# load the word after it
        mfc1 $s2, $f1		# Should be 0x10101010
	dsub $t0, $t0, $t1
	dsub $t0, $t0, $t1
        lwc1 $f2, 0($t0)	# load the word before it
        mfc1 $s3, $f2		# Should be 0x20202020
	dadd $t0, $t0, $t1	# $t0 points at 'variable' again

	#
	# Test that we can store and load a negative number (-1)
	#

        lui $s4, 0xBF80		# -1
        mtc1 $s4, $f1
        swc1 $f1, 0($t0)
        lwc1 $f1, 0($t0)
        mfc1 $s4, $f1		# Should be -1.0

	#
	# Test that we can load a floating point number at an offset
	#

        lui $s5, 0x4180 	# 16
        mtc1 $s5, $f1
        dla $t1, loc1
        swc1 $f1, 0($t1)
	lwc1 $f2, 8($t0)
	mfc1 $s5, $f2
	
	#
	# Test that we can store a floating point number at an offset
	#

        lui $s6, 0x3D80 	# 0.0625 = 1/16
        mtc1 $s6, $f1
        swc1 $f1, 8($t0)
        lwc1 $f2, 0($t1)
	mfc1 $s6, $f2

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
	.align 2
padding:	.word   0x30303030
before:		.word   0x20202020
variable:	.word   0xdeadbeef
after:		.word   0x10101010
loc1:		.word	0
